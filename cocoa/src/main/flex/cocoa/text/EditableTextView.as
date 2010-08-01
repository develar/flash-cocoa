package cocoa.text
{
import cocoa.LabelHelper;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.system.IME;
import flash.system.IMEConversionMode;
import flash.text.engine.FontLookup;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import flash.ui.Keyboard;

import flashx.textLayout.compose.ISWFContext;
import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.conversion.ITextImporter;
import flashx.textLayout.conversion.TextConverter;
import flashx.textLayout.edit.EditManager;
import flashx.textLayout.edit.EditingMode;
import flashx.textLayout.edit.IEditManager;
import flashx.textLayout.edit.ISelectionManager;
import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.edit.SelectionState;
import flashx.textLayout.elements.InlineGraphicElement;
import flashx.textLayout.elements.InlineGraphicElementStatus;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.CompositionCompleteEvent;
import flashx.textLayout.events.DamageEvent;
import flashx.textLayout.events.FlowOperationEvent;
import flashx.textLayout.events.SelectionEvent;
import flashx.textLayout.events.StatusChangeEvent;
import flashx.textLayout.formats.BlockProgression;
import flashx.textLayout.formats.Category;
import flashx.textLayout.formats.ITextLayoutFormat;
import flashx.textLayout.formats.LineBreak;
import flashx.textLayout.formats.TextLayoutFormat;
import flashx.textLayout.operations.CutOperation;
import flashx.textLayout.operations.DeleteTextOperation;
import flashx.textLayout.operations.FlowOperation;
import flashx.textLayout.operations.FlowTextOperation;
import flashx.textLayout.operations.InsertTextOperation;
import flashx.textLayout.operations.PasteOperation;
import flashx.textLayout.tlf_internal;
import flashx.undo.IUndoManager;

import mx.core.IFlexModuleFactory;
import mx.core.IIMESupport;
import mx.core.ISystemCursorClient;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.IFocusManager;
import mx.managers.IFocusManagerComponent;
import mx.utils.StringUtil;

import spark.components.TextSelectionHighlighting;
import spark.events.TextOperationEvent;
import spark.utils.TextUtil;

use namespace mx_internal;
use namespace tlf_internal;

public class EditableTextView extends AbstractTextView implements IFocusManagerComponent, IIMESupport, ISystemCursorClient
{
	private static const textElement:TextElement = new TextElement();
	private static const textBlock:TextBlock = new TextBlock(textElement);

	private static var plainTextImporter:ITextImporter;

	/**
	 *  Regular expression which matches all newlines in the text.  Used
	 *  to strip newlines when pasting text when multiline is false.
	 */
	private static const ALL_NEWLINES_REGEXP:RegExp = /\n/g;

	private var ascent:Number = NaN;
	private var descent:Number = NaN;

	/**
	 *  @private
	 *  Holds the last recorded value of the textFlow generation.  Used to
	 *  determine whether to return immediately from damage event if there
	 *  have been no changes.
	 */
	private var lastGeneration:uint = 0;    // 0 means not set

	/**
	 *  The generation of the text flow that last reported its content
	 *  bounds.
	 */
	private var lastContentBoundsGeneration:int = 0;  // 0 means not set

	/**
	 *  True if TextOperationEvent.CHANGING and TextOperationEvent.CHANGE
	 *  events should be dispatched.
	 */
	private var dispatchChangeAndChangingEvents:Boolean = true;

	mx_internal var ignoreDamageEvent:Boolean = false;
	mx_internal var passwordChar:String = "*";

	mx_internal var undoManager:IUndoManager;
	mx_internal var clearUndoOnFocusOut:Boolean = true;

	private var embeddedFontContext:IFlexModuleFactory;

	/**
	 *  @private
	 *  The TLF edit manager will batch all inserted text until the next
	 *  enter frame event.  This includes text inserted via the GUI as well
	 *  as api calls to EditManager.insertText().  Set this to false if you
	 *  want every keystroke to be inserted into the text immediately which will
	 *  result in a TextOperationEvent.CHANGE event for each character.  One
	 *  place this is needed is for the type-ahead feature of the editable combo
	 *  box.
	 */
	mx_internal var batchTextInput:Boolean = true;

	/**
	 *  True if we've seen a MOUSE_DOWN event and haven't seen the
	 *  corresponding MOUSE_UP event.
	 */
	private var mouseDown:Boolean = false;

	private var errorCaught:Boolean = false;

	/**
	 *  Cache the width constraint as set by the layout in setLayoutBoundsSize()
	 *  so that text reflow can be calculated during a subsequent measure pass.
	 */
	private var widthConstraint:Number = NaN;

	/**
	 *  Cache the height constraint as set by the layout in setLayoutBoundsSize()
	 *  so that text reflow can be calculated during a subsequent measure pass.
	 */
	private var heightConstraint:Number = NaN;

	/**
	 *  If the selection was via the selectRange() or selectAll() api, remember
	 *  that until the next selection is set, either interactively or via the
	 *  API.
	 */
	private var hasProgrammaticSelectionRange:Boolean = false;

	/**
	 *  True if this component sizes itself based on its actual contents.
	 */
	private var autoSize:Boolean = false;

	public function EditableTextView()
	{
		super();

		_textContainerManager = new EditableTextContainerManager(this, configuration);
		_textContainerManager.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, textContainerManager_compositionCompleteHandler);
		_textContainerManager.addEventListener(DamageEvent.DAMAGE, textContainerManager_damageHandler);
		_textContainerManager.addEventListener(Event.SCROLL, textContainerManager_scrollHandler);
		_textContainerManager.addEventListener(SelectionEvent.SELECTION_CHANGE, textContainerManager_selectionChangeHandler);
		_textContainerManager.addEventListener(FlowOperationEvent.FLOW_OPERATION_BEGIN, textContainerManager_flowOperationBeginHandler);
		_textContainerManager.addEventListener(FlowOperationEvent.FLOW_OPERATION_END, textContainerManager_flowOperationEndHandler);
		_textContainerManager.addEventListener(FlowOperationEvent.FLOW_OPERATION_COMPLETE, textContainerManager_flowOperationCompleteHandler);
		_textContainerManager.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, textContainerManager_inlineGraphicStatusChangeHandler);
	}

	private static function splice(str:String, start:int, end:int, strToInsert:String):String
	{
		return str.substring(0, start) + strToInsert + str.substring(end, str.length);
	}

	override protected function get scrollController():ScrollController
	{
		return _textContainerManager;
	}

	private var _multiline:Boolean = true;
	/**
	 *  Determines whether the user can enter multiline text.
	 *
	 *  <p>If <code>true</code>, the Enter key starts a new paragraph. If <code>false</code>, the Enter key doesn't affect the text
	 *  but causes the RichEditableText to dispatch an <code>"enter"</code> event. If you paste text into the RichEditableText with a multiline
	 *  value of <code>true</code>, newlines are stripped out of the text. </p>
	 */
	public function get multiline():Boolean
	{
		return _multiline;
	}
	public function set multiline(value:Boolean):void
	{
		_multiline = value;
	}

	override public function set textFormat(value:ITextLayoutFormat):void
	{
		super.textFormat = value;

		_textContainerManager.hostFormat = _textFormat;

		if (isNaN(ascent) || isNaN(descent))
		{
			embeddedFontContext = getEmbeddedFontContext();
			_textContainerManager.swfContext = ISWFContext(embeddedFontContext);
			calculateFontMetrics();
		}
	}

	mx_internal var _selectionFormat:SelectionFormat;
	public function set selectionFormat(value:SelectionFormat):void
	{
		assert(_selectionFormat == null);
		_selectionFormat = value;
	}

	override public function get baselinePosition():Number
	{
		return effectiveTextFormat.paddingTop + ascent;
	}

	private var enabledChanged:Boolean = false;
	override public function set enabled(value:Boolean):void
	{
		if (value == super.enabled)
		{
			return;
		}

		super.enabled = value;

		enabledChanged = true;

		invalidateProperties();
		invalidateDisplayList();
	}

	override public function set explicitHeight(value:Number):void
	{
		super.explicitHeight = value;

		heightConstraint = NaN;

		// Because of autoSizing, the size and display might be impacted.
		invalidateSize();
		invalidateDisplayList();
	}

	override public function set explicitWidth(value:Number):void
	{
		super.explicitWidth = value;

		widthConstraint = NaN;

		// Because of autoSizing, the size and display might be impacted.
		invalidateSize();
		invalidateDisplayList();
	}

	override public function set percentHeight(value:Number):void
	{
		super.percentHeight = value;

		heightConstraint = NaN;

		// If we were autoSizing and now we are not we need to remeasure.
		invalidateSize();
		invalidateDisplayList();
	}

	override public function set percentWidth(value:Number):void
	{
		super.percentWidth = value;

		widthConstraint = NaN;

		// If we were autoSizing and now we are not we need to remeasure.
		invalidateSize();
		invalidateDisplayList();
	}

	public function get showSystemCursor():Boolean
	{
		return editable;
	}

	private var _displayAsPassword:Boolean = false;
	private var displayAsPasswordChanged:Boolean = false;
	public function get displayAsPassword():Boolean
	{
		return _displayAsPassword;
	}
	public function set displayAsPassword(value:Boolean):void
	{
		if (value == _displayAsPassword)
			return;

		_displayAsPassword = value;
		displayAsPasswordChanged = true;

		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();
	}

	private var _editable:Boolean = true;
	private var editableChanged:Boolean = false;

	/**
	 *  A flag indicating whether the user is allowed
	 *  to edit the text in this control.
	 *
	 *  <p>If <code>true</code>, the mouse cursor will change to an i-beam
	 *  when over the bounds of this control.
	 *  If <code>false</code>, the mouse cursor will remain an arrow.</p>
	 *
	 *  <p>If this property is <code>true</code>,
	 *  the <code>selectable</code> property is ignored.</p>
	 *
	 *  @default true
	 *
	 *  @see #selectable
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get editable():Boolean
	{
		return _editable;
	}

	/**
	 *  @private
	 */
	public function set editable(value:Boolean):void
	{
		if (value == _editable)
			return;

		_editable = value;
		editableChanged = true;

		invalidateProperties();
		invalidateDisplayList();
	}

	/**
	 *  The editingMode of this component's TextContainerManager.
	 */
	private function get editingMode():String
	{
		// Note: this could be called before all properties are committed.
		if (enabledChanged || editableChanged || selectableChanged)
		{
			updateEditingMode();

			enabledChanged = false;
			editableChanged = false;
			selectableChanged = false;
		}

		return _textContainerManager.editingMode;
	}

	private function set editingMode(value:String):void
	{
		var lastEditingMode:String = _textContainerManager.editingMode;
		if (lastEditingMode == value)
		{
			return;
		}

		_textContainerManager.editingMode = value;

		// Make sure the selection manager selection is in sync with the current selection.
		if (value != EditingMode.READ_ONLY && _selectionAnchorPosition != -1 && _selectionActivePosition != -1)
		{
			_textContainerManager.beginInteraction().selectRange(_selectionAnchorPosition, _selectionActivePosition);
			_textContainerManager.endInteraction();
		}
	}

	public function get enableIME():Boolean
	{
		return editable;
	}

	private var _heightInLines:Number = NaN;
	private var heightInLinesChanged:Boolean = false;

	/**
	 *  The default height of the control, measured in lines.
	 *
	 *  <p>The control's formatting styles, such as <code>fontSize</code>
	 *  and <code>lineHeight</code>, are used to calculate the line height
	 *  in pixels.</p>
	 *
	 *  <p>You would, for example, set this property to 5 if you want
	 *  the height of the RichEditableText to be sufficient
	 *  to display five lines of text.</p>
	 *
	 *  <p>If this property is <code>NaN</code> (the default),
	 *  then the component's default height will be determined
	 *  from the text to be displayed.</p>
	 *
	 *  <p>This property will be ignored if you specify an explicit height,
	 *  a percent height, or both <code>top</code> and <code>bottom</code>
	 *  constraints.</p>
	 *
	 *  <p>RichEditableText's <code>measure()</code> method uses
	 *  <code>widthInChars</code> and <code>heightInLines</code>
	 *  to determine the <code>measuredWidth</code>
	 *  and <code>measuredHeight</code>.
	 *  These are similar to the <code>cols</code> and <code>rows</code>
	 *  of an HTML TextArea.</p>
	 *
	 *  <p>Since both <code>widthInChars</code> and <code>heightInLines</code>
	 *  default to <code>NaN</code>, RichTextEditable "autosizes" by default:
	 *  it starts out very small if it has no text, grows in width as you
	 *  type, and grows in height when you press Enter to start a new line.</p>
	 *
	 *  @default NaN
	 *
	 *  @see #widthInChars
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get heightInLines():Number
	{
		return _heightInLines;
	}

	public function set heightInLines(value:Number):void
	{
		if (value == _heightInLines)
		{
			return;
		}

		_heightInLines = value;
		heightInLinesChanged = true;

		heightConstraint = NaN;

		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();
	}

	private var _imeMode:String = null;
	public function get imeMode():String
	{
		return _imeMode;
	}
	public function set imeMode(value:String):void
	{
		_imeMode = value;
	}

	private var _maxChars:int = 0;

	/**
	 *  @copy flash.text.TextField#maxChars
	 */
	public function get maxChars():int
	{
		return _maxChars;
	}
	public function set maxChars(value:int):void
	{
		_maxChars = value;
	}

	private var _restrict:String = null;

	/**
	 *  @copy flash.text.TextField#restrict
	 */
	public function get restrict():String
	{
		return _restrict;
	}
	public function set restrict(value:String):void
	{
		_restrict = value;
	}

	private var selectableChanged:Boolean = false;
	public function set selectable(value:Boolean):void
	{
		if (value == _selectable)
		{
			return;
		}

		_selectable = value;
		selectableChanged = true;

		invalidateProperties();
		invalidateDisplayList();
	}

	private var _selectionActivePosition:int = -1;

	[Bindable("selectionChange")]
	/**
	 *  A character position, relative to the beginning of the
	 *  <code>text</code> String, specifying the end of the selection
	 *  that moves when the selection is extended with the arrow keys.
	 *
	 *  <p>The active position may be either the start
	 *  or the end of the selection.</p>
	 *
	 *  <p>For example, if you drag-select from position 12 to position 8,
	 *  then <code>selectionAnchorPosition</code> will be 12
	 *  and <code>selectionActivePosition</code> will be 8,
	 *  and when you press Left-Arrow <code>selectionActivePosition</code>
	 *  will become 7.</p>
	 *
	 *  <p>A value of -1 indicates "not set".</p>
	 *
	 *  @default -1
	 *
	 *  @see #selectionAnchorPosition
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get selectionActivePosition():int
	{
		return _selectionActivePosition;
	}

	private var _selectionAnchorPosition:int = -1;

	[Bindable("selectionChange")]
	/**
	 *  A character position, relative to the beginning of the
	 *  <code>text</code> String, specifying the end of the selection
	 *  that stays fixed when the selection is extended with the arrow keys.
	 *
	 *  <p>The anchor position may be either the start
	 *  or the end of the selection.</p>
	 *
	 *  <p>For example, if you drag-select from position 12 to position 8,
	 *  then <code>selectionAnchorPosition</code> will be 12
	 *  and <code>selectionActivePosition</code> will be 8,
	 *  and when you press Left-Arrow <code>selectionActivePosition</code>
	 *  will become 7.</p>
	 *
	 *  <p>A value of -1 indicates "not set".</p>
	 *
	 *  @default -1
	 *
	 *  @see #selectionActivePosition
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get selectionAnchorPosition():int
	{
		return _selectionAnchorPosition;
	}

	private var _selectionHighlighting:String = TextSelectionHighlighting.WHEN_FOCUSED;

	/**
	 *  To indicate either selection highlighting or selection styles have
	 *  changed.
	 */
	private var selectionFormatsChanged:Boolean = false;

	/**
	 *  Determines when the text selection is highlighted.
	 *
	 *  <p>The allowed values are specified by the
	 *  spark.components.TextSelectionHighlighting class.
	 *  Possible values are <code>TextSelectionHighlighting.WHEN_FOCUSED</code>,
	 *  <code>TextSelectionHighlighting.WHEN_ACTIVE</code>,
	 *  and <code>TextSelectionHighlighting.ALWAYS</code>.</p>
	 *
	 *  <p><code>WHEN_FOCUSED</code> shows the text selection
	 *  only when the component has keyboard focus.</p>
	 *
	 *  <p><code>WHEN_ACTIVE</code> shows the text selection whenever
	 *  the component's window is active, even if the component
	 *  doesn't have the keyboard focus.</p>
	 *
	 *  <p><code>ALWAYS</code> shows the text selection,
	 *  even if the component doesn't have the keyboard focus
	 *  or if the component's window isn't the active window.</p>
	 *
	 *  @default TextSelectionHighlighting.WHEN_FOCUSED
	 *
	 *  @see spark.components.TextSelectionHighlighting
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get selectionHighlighting():String
	{
		return _selectionHighlighting;
	}
	public function set selectionHighlighting(value:String):void
	{
		if (value == _selectionHighlighting)
		{
			return;
		}

		_selectionHighlighting = value;
		selectionFormatsChanged = true;

		//  мы пока что никак не используем это свойство
//		invalidateProperties();
//		invalidateDisplayList();
	}

	private var _textContainerManager:EditableTextContainerManager;

	mx_internal function get textContainerManager():TextContainerManager
	{
		return _textContainerManager;
	}

	/**
	 *  The TextFlow representing the rich text displayed by this component.
	 *
	 *  <p>A TextFlow is the most important class
	 *  in the Text Layout Framework (TLF).
	 *  It is the root of a tree of FlowElements
	 *  representing rich text content.</p>
	 *
	 *  <p>You normally create a TextFlow from TLF markup
	 *  using the <code>TextFlowUtil.importFromString()</code>
	 *  or <code>TextFlowUtil.importFromXML()</code> methods.
	 *  Alternately, you can use TLF's TextConverter class
	 *  (which can import a subset of HTML) or build a TextFlow
	 *  using methods like <code>addChild()</code> on TextFlow.</p>
	 *
	 *  <p>Setting this property affects the <code>text</code> property
	 *  and vice versa.</p>
	 *
	 *  <p>If you set the <code>textFlow</code> and get the <code>text</code>,
	 *  the text in each paragraph will be separated by a single
	 *  LF ("\n").</p>
	 *
	 *  <p>If you set the <code>text</code> to a String such as
	 *  <code>"Hello World"</code> and get the <code>textFlow</code>,
	 *  it will be a TextFlow containing a single ParagraphElement
	 *  with a single SpanElement.</p>
	 *
	 *  <p>If the text contains explicit line breaks --
	 *  CR ("\r"), LF ("\n"), or CR+LF ("\r\n") --
	 *  then the content will be set to a TextFlow
	 *  which contains multiple paragraphs, each with one span.</p>
	 *
	 *  <p>Setting this property also affects the properties
	 *  specifying the control's scroll position and the text selection.
	 *  It resets the <code>horizontalScrollPosition</code>
	 *  and <code>verticalScrollPosition</code> to 0,
	 *  and it sets the <code>selectionAnchorPosition</code>
	 *  and <code>selectionActivePosition</code>
	 *  to -1 to clear the selection.</p>
	 *
	 *  <p>To turn a TextFlow object into TLF markup,
	 *  use the <code>TextFlowUtil.export()</code> markup.</p>
	 *
	 *  <p>A single TextFlow cannot be shared by multiple instances
	 *  of RichEditableText.
	 *  To display the same text in a second instance, you must create
	 *  a second TextFlow, either by using <code>TextFlowUtil.export()</code>
	 *  and <code>TextFlowUtil.importFromXML()</code> or by using
	 *  the <code>deepCopy()</code> method on TextFlow.</p>
	 *
	 *  @see spark.utils.TextFlowUtil.importFromString()
	 *  @see spark.utils.TextFlowUtil.importFromXML()
	 *  @see #text
	 */
	override public function get textFlow():TextFlow
	{
		if (_textFlow == null)
		{
			if (plainTextImporter == null)
			{
				plainTextImporter = TextConverter.getImporter(TextConverter.PLAIN_TEXT_FORMAT, configuration);
				plainTextImporter.throwOnError = true;
			}

			_textFlow = plainTextImporter.importToFlow(_text);
		}

		// Make sure the interactionManager is added to this textFlow.
		if (textChanged || textFlowChanged)
		{
			_textContainerManager.setTextFlow(_textFlow);
			textChanged = textFlowChanged = false;
		}

		// If not read-only, make sure the textFlow has a composer in
		// place so that it can be modified by the caller if desired.
		if (editingMode != EditingMode.READ_ONLY)
		{
			_textContainerManager.beginInteraction();
			_textContainerManager.endInteraction();
		}

		return _textFlow;
	}

	public function set textFlow(value:TextFlow):void
	{
		if (value == null)
		{
			text = "";
			return;
		}

		if (value == _textFlow)
		{
			return;
		}

		_textFlow = value;
		textFlowChanged = true;

		// Of 'text', 'textFlow', and 'content', the last one set wins.
		textChanged = false;

		// The other two are now invalid and must be recalculated when needed.
		_text = null;

		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();

		dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
	}

	//----------------------------------
	//  widthInChars
	//----------------------------------

	/**
	 *  @private
	 *  These are measured in ems.
	 */
	private var _widthInChars:Number = NaN;

	/**
	 *  @private
	 */
	private var widthInCharsChanged:Boolean = true;

	/**
	 *  The default width of the control, measured in em units.
	 *
	 *  <p>An em is a unit of typographic measurement
	 *  equal to the point size.
	 *  It is not necessarily exactly the width of the "M" character,
	 *  but in many fonts the "M" is about one em wide.
	 *  The control's <code>fontSize</code> style is used,
	 *  to calculate the em unit in pixels.</p>
	 *
	 *  <p>You would, for example, set this property to 20 if you want
	 *  the width of the RichEditableText to be sufficient
	 *  to display about 20 characters of text.</p>
	 *
	 *  <p>If this property is <code>NaN</code> (the default),
	 *  then the component's default width will be determined
	 *  from the text to be displayed.</p>
	 *
	 *  <p>This property will be ignored if you specify an explicit width,
	 *  a percent width, or both <code>left</code> and <code>right</code>
	 *  constraints.</p>
	 *
	 *  <p>RichEditableText's <code>measure()</code> method uses
	 *  <code>widthInChars</code> and <code>heightInLines</code>
	 *  to determine the <code>measuredWidth</code>
	 *  and <code>measuredHeight</code>.
	 *  These are similar to the <code>cols</code> and <code>rows</code>
	 *  of an HTML TextArea.</p>
	 *
	 *  <p>Since both <code>widthInChars</code> and <code>heightInLines</code>
	 *  default to <code>NaN</code>, RichTextEditable "autosizes" by default:
	 *  it starts out very samll if it has no text, grows in width as you
	 *  type, and grows in height when you press Enter to start a new line.</p>
	 *
	 *  @default NaN
	 *
	 *  @see spark.primitives.heightInLines
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get widthInChars():Number
	{
		return _widthInChars;
	}

	/**
	 *  @private
	 */
	public function set widthInChars(value:Number):void
	{
		if (value == _widthInChars)
			return;

		_widthInChars = value;
		widthInCharsChanged = true;

		widthConstraint = NaN;

		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden Methods: UIComponent
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override public function parentChanged(p:DisplayObjectContainer):void
	{
		if (focusManager)
		{
			focusManager.removeEventListener(FlexEvent.FLEX_WINDOW_ACTIVATE, _textContainerManager.activateHandler);
			focusManager.removeEventListener(FlexEvent.FLEX_WINDOW_DEACTIVATE, _textContainerManager.deactivateHandler);
		}

		super.parentChanged(p);

		if (focusManager)
		{
			addActivateHandlers();
		}
		else
		{
			// if no focusmanager yet, add capture phase to detect when it
			// gets added
			if (systemManager)
				systemManager.getSandboxRoot().addEventListener(FlexEvent.ADD_FOCUS_MANAGER, addFocusManagerHandler, true, 0, true);
			else
			// no systemManager yet?  Check again when added to stage
				addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}

	}

	/**
	 *  @private
	 */
	override public function removeChild(child:DisplayObject):DisplayObject
	{
		// not sure why this happens but it does if you just change
		// the embeddedFont context
		if (!child.parent)
			return child;

		if (child.parent == this)
			return super.removeChild(child);

		return child.parent.removeChild(child);
	}

	/**
	 *  @private
	 */
	override protected function commitProperties():void
	{
		super.commitProperties();

		// EditingMode needs to be current before attempting to set a selection below.
		if (enabledChanged || selectableChanged || editableChanged)
		{
			updateEditingMode();

			enabledChanged = false;
			editableChanged = false;
			selectableChanged = false;
		}

		// Only one of textChanged, textFlowChanged, and contentChanged
		// will be true; the other two will be false because each setter guarantees this.

		if (textChanged)
		{
			_textContainerManager.setText(_text);
		}
		else if (textFlowChanged)
		{
			_textContainerManager.setTextFlow(_textFlow);
		}

		if (textChanged || textFlowChanged)
		{
			lastGeneration = _textFlow != null ? _textFlow.generation : 0;
			lastContentBoundsGeneration = 0;

			// Handle the case where the initial text, textFlow or content
			// is displayed as a password.
			if (displayAsPassword)
			{
				displayAsPasswordChanged = true;
			}

			textChanged = false;
			textFlowChanged = false;
		}

		// If displayAsPassword changed, it only applies to the display, not the underlying text.
		if (displayAsPasswordChanged)
		{
			var oldAnchorPosition:int = _selectionAnchorPosition;
			var oldActivePosition:int = _selectionActivePosition;

			// If there is any text, convert it to the passwordChar.
			if (displayAsPassword)
			{
				// Make sure _text is set with the actual text before we change the displayed text.
				_text = text;
				// Paragraph terminators are lost during this substitution.
				_textContainerManager.setText(StringUtil.repeat(passwordChar, _text.length));
			}
			else
			{
				// Text was displayed as password.  Now display as plain text.
				_textContainerManager.setText(_text);
			}

			if (editingMode != EditingMode.READ_ONLY)
			{
				// Must preserve the selection, if there was one.
				// The visible selection will be refreshed during the update.
				_textContainerManager.beginInteraction().selectRange(oldAnchorPosition, oldActivePosition);
				_textContainerManager.endInteraction();
			}

			displayAsPasswordChanged = false;
		}
	}

	override protected function canSkipMeasurement():Boolean
	{
		autoSize = false;
		return super.canSkipMeasurement();
	}

	override protected function measure():void
	{
		// Don't want to trigger a another remeasure when we modify the
		// textContainerManager or compose the text.
		ignoreDamageEvent = true;

		super.measure();

		// percentWidth and/or percentHeight will come back in as constraints
		// on the remeasure if we're autoSizing.

		if (isMeasureFixed())
		{
			autoSize = false;

			// Go large.  For performance reasons, want to avoid a scrollRect
			// whenever possible in drawBackgroundAndSetScrollRect().  This is
			// particularly true for 1 line TextInput components.
			measuredWidth = !isNaN(explicitWidth) ? explicitWidth : Math.ceil(calculateWidthInChars());
			measuredHeight = !isNaN(explicitHeight) ? explicitHeight : Math.ceil(calculateHeightInLines());
		}
		else
		{
			var composeWidth:Number;
			var composeHeight:Number;

			var bounds:Rectangle;

			// If we're here, then at one or both of the width and height can
			// grow to fit the text.  It is important to figure out whether
			// or not autoSize should be allowed to continue.  If in
			// updateDisplayList(), autoSize is true, then the
			// compositionHeight is NaN to allow the text to grow.
			autoSize = true;

			if (!isNaN(widthConstraint) || !isNaN(explicitWidth) || !isNaN(widthInChars))
			{
				// width specified but no height
				// if no text, start at one line high and grow

				if (!isNaN(widthConstraint))
					composeWidth = widthConstraint; else if (!isNaN(explicitWidth))
					composeWidth = explicitWidth;
				else
					composeWidth = Math.ceil(calculateWidthInChars());

				// The composeWidth may be adjusted for minWidth/maxWidth
				// except if we're using the explicitWidth.
				bounds = measureTextSize(composeWidth);

				measuredWidth = _textContainerManager.compositionWidth;
				measuredHeight = Math.ceil(bounds.bottom);
			} else if (!isNaN(heightConstraint) || !isNaN(explicitHeight) || !isNaN(_heightInLines))
			{
				// if no text, 1 char wide with specified height and grow

				if (!isNaN(heightConstraint))
					composeHeight = heightConstraint; else if (!isNaN(explicitHeight))
					composeHeight = explicitHeight;
				else
					composeHeight = calculateHeightInLines();

				// The composeWidth may be adjusted for minWidth/maxWidth.
				bounds = measureTextSize(NaN, composeHeight);

				measuredWidth = Math.ceil(bounds.right);
				measuredHeight = composeHeight;

				// Have we already hit the limit with the existing text?  If we
				// are beyond the composeHeight we can assume we've maxed out on
				// the compose width as well (or the composeHeight isn't
				// large enough for even one line of text).
				if (bounds.bottom > composeHeight)
					autoSize = false;
			}
			else
			{
				// The composeWidth may be adjusted for minWidth/maxWidth.
				bounds = measureTextSize(NaN);

				measuredWidth = Math.ceil(bounds.right);
				measuredHeight = Math.ceil(bounds.bottom);
			}

			// Clamp the height, except if we're using the explicitHeight.
			if (isNaN(explicitHeight))
			{
				if (!isNaN(explicitMinHeight) && measuredHeight < explicitMinHeight)
					measuredHeight = explicitMinHeight;

				// Reached max height so can't grow anymore.
				if (!isNaN(explicitMaxHeight) && measuredHeight > explicitMaxHeight)
				{
					measuredHeight = explicitMaxHeight;
					autoSize = false;
				}
			}

			// Make sure we weren't previously scrolled.
			if (autoSize)
			{
				_textContainerManager.horizontalScrollPosition = 0;
				_textContainerManager.verticalScrollPosition = 0;
			}

			invalidateDisplayList();
		}

		ignoreDamageEvent = false;

		//trace("measure", measuredWidth, measuredHeight, "autoSize", autoSize);
	}

	/**
	 *  @private
	 */
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		// Check if the auto-size text is constrained in some way and needs to be remeasured.  If one of the dimension changes, the text may
		// compose differently and have a different size which the layout manager needs to know.
		if (autoSize && remeasureText(w, h))
		{
			return;
		}

		super.updateDisplayList(w, h);

		// If we're autoSizing we're telling the layout manager one set of values and TLF another set of values so there is room for the text to grow.
		// autoSize for blockProgression=="rl" is implemented
		if (!autoSize)
		{
			_textContainerManager.compositionWidth = w;
			_textContainerManager.compositionHeight = h;
		}

		// If scrolling, always compose with the composer so we get consistent measurements. The factory and the composer produce slightly
		// different results which can confuse the scroller.  If there isn't a composer, this calls updateContainer so do it here now that the
		// composition sizes are set so the results can be used.
		if (clipAndEnableScrolling && _textContainerManager.composeState != TextContainerManager.COMPOSE_COMPOSER)
		{
			_textContainerManager.convertToTextFlowWithComposer();
		}

		_textContainerManager.updateContainer();
	}

	/**
	 *  @private
	 *  This is called by the layout manager the first time this
	 *  component is measured, or later if its size changes. This
	 *  is not always called before updateDisplayList().  For example,
	 *  for recycled item renderers this is not called if the measured
	 *  size doesn't change.
	 *
	 *  width and height are NaN unless there are constraints on them.
	 */
	override public function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean = true):void
	{
		//trace("setLayoutBoundsSize", width, height);

		// Save these so when we are auto-sizing we know which dimensions
		// are constrained.  Without this it is not possible to differentiate
		// between a measured width/height that is the same as the
		// constrained width/height to know whether that dimension can
		// be sized or must be fixed at the constrained value.
		widthConstraint = width;
		heightConstraint = height;

		super.setLayoutBoundsSize(width, height, postLayoutTransform);
	}

	override public function setFocus():void
	{
		// We are about to set focus on this component.  If it is due to
		// a programmatic focus change we have to programatically do what the
		// mouseOverHandler and the mouseDownHandler do so that the user can
		// type in this component without using the mouse first.  We need to
		// put a textFlow with a composer in place.
		if (editingMode != EditingMode.READ_ONLY && _textContainerManager.composeState != TextContainerManager.COMPOSE_COMPOSER)
		{
			_textContainerManager.beginInteraction();
			_textContainerManager.endInteraction();
		}

		super.setFocus();
	}

	/**
	 *  Inserts the specified text into the RichEditableText
	 *  as if you had typed it.
	 *
	 *  <p>If a range was selected, the new text replaces the selected text.
	 *  If there was an insertion point, the new text is inserted there.</p>
	 *
	 *  <p>An insertion point is then set after the new text.
	 *  If necessary, the text will scroll to ensure
	 *  that the insertion point is visible.</p>
	 *
	 *  @param text The text to be inserted.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function insertText(text:String):void
	{
		handleInsertText(text);
	}

	/**
	 *  Appends the specified text to the end of the RichEditableText,
	 *  as if you had clicked at the end and typed.
	 *
	 *  <p>An insertion point is then set after the new text.
	 *  If necessary, the text will scroll to ensure
	 *  that the insertion point is visible.</p>
	 *
	 *  @param text The text to be appended.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function appendText(text:String):void
	{
		handleInsertText(text, true);
	}

	/**
	 *  @copy flashx.textLayout.container.ContainerController#scrollToRange()
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function scrollToRange(anchorPosition:int, activePosition:int):void
	{
		// Make sure the properties are commited since the text could change.
		validateProperties();

		// Scrolls so that the text position is visible in the container.
		textContainerManager.scrollToRange(anchorPosition, activePosition);
	}

	/**
	 *  Selects a specified range of characters.
	 *
	 *  <p>If either position is negative, it will deselect the text range.</p>
	 *
	 *  @param anchorPosition The character position specifying the end
	 *  of the selection that stays fixed when the selection is extended.
	 *
	 *  @param activePosition The character position specifying the end
	 *  of the selection that moves when the selection is extended.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function selectRange(anchorPosition:int, activePosition:int):void
	{
		// Make sure the properties are commited since the text could change.
		validateProperties();

		if (editingMode == EditingMode.READ_ONLY)
		{
			var selectionState:SelectionState = new SelectionState(textFlow, anchorPosition, activePosition);

			var selectionEvent:SelectionEvent = new SelectionEvent(SelectionEvent.SELECTION_CHANGE, false, false, selectionState);

			textContainerManager_selectionChangeHandler(selectionEvent);
		}
		else
		{
			var im:ISelectionManager = _textContainerManager.beginInteraction();

			im.selectRange(anchorPosition, activePosition);

			// Refresh the selection.  This does not cause a damage event.
			im.refreshSelection();

			_textContainerManager.endInteraction();
		}

		// Remember if the current selection is a range which was set
		// programatically.
		hasProgrammaticSelectionRange = (anchorPosition != activePosition);
	}

	/**
	 *  Selects all of the text.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function selectAll():void
	{
		selectRange(0, int.MAX_VALUE);
	}

	/**
	 *  Returns a TextLayoutFormat object specifying the formats
	 *  for the specified range of characters.
	 *
	 *  <p>If a format is not consistently set across the entire range,
	 *  its value will be <code>undefined</code>.</p>
	 *
	 *  <p>You can specify a Vector of Strings containing the names of the
	 *  formats that you care about; if you don't, all formats
	 *  will be computed.</p>
	 *
	 *  <p>If you don't specify a range, the selected range is used.</p>
	 *
	 *  @param requestedFormats A Vector of Strings specifying the names
	 *  of the requested formats, or <code>null</code> to request all formats.
	 *
	 *  @param anchorPosition A character position specifying
	 *  the fixed end of the selection.
	 *
	 *  @param activePosition A character position specifying
	 *   the movable end of the selection.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function getFormatOfRange(requestedFormats:Vector.<String> = null, anchorPosition:int = -1, activePosition:int = -1):TextLayoutFormat
	{
		var format:TextLayoutFormat = new TextLayoutFormat();

		// Make sure all properties are committed.
		validateProperties();

		// This internal TLF object maps the names of format properties
		// to Property instances.
		// Each Property instance has a category property which tells
		// whether it is container-, paragraph-, or character-level.
		var description:Object = TextLayoutFormat.description;

		var p:String;
		var category:String;

		// Based on which formats have been requested, determine which
		// of the getCommonXXXFormat() methods we need to call.

		var needContainerFormat:Boolean = false;
		var needParagraphFormat:Boolean = false;
		var needCharacterFormat:Boolean = false;

		if (!requestedFormats)
		{
			requestedFormats = new Vector.<String>;
			for (p in description)
			{
				requestedFormats.push(p);
			}

			needContainerFormat = true;
			needParagraphFormat = true;
			needCharacterFormat = true;
		}
		else
		{
			for each (p in requestedFormats)
			{
				if (!(p in description))
					continue;

				category = description[p].category;

				if (category == Category.CONTAINER)
					needContainerFormat = true; else if (category == Category.PARAGRAPH)
					needParagraphFormat = true; else if (category == Category.CHARACTER)
					needCharacterFormat = true;
			}
		}

		// Get the common formats.

		var containerFormat:ITextLayoutFormat;
		var paragraphFormat:ITextLayoutFormat;
		var characterFormat:ITextLayoutFormat;

		if (anchorPosition == -1 && activePosition == -1)
		{
			anchorPosition = _selectionAnchorPosition;
			activePosition = _selectionActivePosition;
		}

		if (needContainerFormat)
		{
			containerFormat = _textContainerManager.getCommonContainerFormat();
		}

		if (needParagraphFormat)
		{
			paragraphFormat = _textContainerManager.getCommonParagraphFormat(anchorPosition, activePosition);
		}

		if (needCharacterFormat)
		{
			characterFormat = _textContainerManager.getCommonCharacterFormat(anchorPosition, activePosition);
		}

		// Extract the requested formats to return.
		for each (p in requestedFormats)
		{
			if (!(p in description))
			{
				continue;
			}

			category = description[p].category;
			if (category == Category.CONTAINER && containerFormat)
			{
				format[p] = containerFormat[p];
			}
			else if (category == Category.PARAGRAPH && paragraphFormat)
			{
				format[p] = paragraphFormat[p];
			}
			else if (category == Category.CHARACTER && characterFormat)
			{
				format[p] = characterFormat[p];
			}
		}

		return format;
	}

	/**
	 *  Applies the specified format to the specified range.
	 *
	 *  <p>The supported formats are those in TextFormatLayout.
	 *  A value of <code>undefined</code> does not get applied.
	 *  If you don't specify a range, the selected range is used.</p>
	 *
	 *  <p>The following example sets the <code>fontSize</code> and <code>color</code> of the selection:
	 *  <pre>
	 *  var textLayoutFormat:TextLayoutFormat = new TextLayoutFormat();
	 *  textLayoutFormat.fontSize = 12;
	 *  textLayoutFormat.color = 0xFF0000;
	 *  myRET.setFormatOfRange(textLayoutFormat);
	 *  </pre>
	 *  </p>
	 *
	 *  @param format The TextLayoutFormat to apply to the selection.
	 *
	 *  @param anchorPosition A character position, relative to the beginning of the
	 *  text String, specifying the end of the selection that stays fixed when the
	 *  selection is extended with the arrow keys.
	 *
	 *  @param activePosition A character position, relative to the beginning of the
	 *  text String, specifying the end of the selection that moves when the
	 *  selection is extended with the arrow keys.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function setFormatOfRange(format:TextLayoutFormat, anchorPosition:int = -1, activePosition:int = -1):void
	{
		// Make sure all properties are committed.  The damage handler for the
		// applyTextFormat op will cause the remeasure and display update.
		validateProperties();

		// Assign each specified attribute to one of three format objects,
		// depending on whether it is container-, paragraph-, or character-level. Note that these can remain null.
		var containerFormat:TextLayoutFormat;
		var paragraphFormat:TextLayoutFormat;
		var characterFormat:TextLayoutFormat;

		// This internal TLF object maps the names of format properties to Property instances.
		// Each Property instance has a category property which tells whether it is container-, paragraph-, or character-level.
		var description:Object = TextLayoutFormat.description;

		for (var p:String in description)
		{
			if (format[p] === undefined)
			{
				continue;
			}

			switch (description[p].category)
			{
				case Category.CONTAINER:
				{
					if (containerFormat == null)
					{
						containerFormat = new TextLayoutFormat();
					}
					containerFormat[p] = format[p];
				}
				break;

				case Category.PARAGRAPH:
				{
					if (paragraphFormat == null)
					{
						paragraphFormat = new TextLayoutFormat();
					}
					paragraphFormat[p] = format[p];
				}
				break;

				case Category.CHARACTER:
				{
					if (characterFormat == null)
					{
						characterFormat = new TextLayoutFormat();
					}
					characterFormat[p] = format[p];
				}
			}
		}

		// If the selection isn't specified, use the current one.
		if (anchorPosition == -1 && activePosition == -1)
		{
			anchorPosition = _selectionAnchorPosition;
			activePosition = _selectionActivePosition;
		}

		// Apply the three format objects to the current selection if selectionState is null, else the specified selection.
		_textContainerManager.applyFormatOperation(characterFormat, paragraphFormat, containerFormat, anchorPosition, activePosition);
	}

	private function getEmbeddedFontContext():IFlexModuleFactory
	{
		if (effectiveTextFormat.fontLookup == FontLookup.DEVICE)
		{
			return null;
		}
		else
		{
			return LabelHelper.getEmbeddedFontContext(this, effectiveTextFormat.fontFamily, effectiveTextFormat.fontWeight, effectiveTextFormat.fontStyle);
		}
	}

	/**
	 *  Return true if there is a width and height to use for the measure.
	 */
	private function isMeasureFixed():Boolean
	{
		if (effectiveTextFormat.blockProgression != BlockProgression.TB)
		{
			return true;
		}

		// Is there some sort of width and some sort of height?
		return (!isNaN(explicitWidth) || !isNaN(_widthInChars) || !isNaN(widthConstraint)) && (!isNaN(explicitHeight) || !isNaN(_heightInLines) || !isNaN(heightConstraint));
	}

	/**
	 *  Returns the bounds of the measured text.  The initial composeWidth may
	 *  be adjusted for minWidth or maxWidth.  The value used for the compose
	 *  is in _textContainerManager.compositionWidth.
	 */
	private function measureTextSize(composeWidth:Number, composeHeight:Number = NaN):Rectangle
	{
		// Adjust for explicit min/maxWidth so the measurement is accurate.
		if (isNaN(explicitWidth))
		{
			if (!isNaN(explicitMinWidth) && isNaN(composeWidth) || composeWidth < minWidth)
			{
				composeWidth = minWidth;
			}
			if (!isNaN(explicitMaxWidth) && isNaN(composeWidth) || composeWidth > maxWidth)
			{
				composeWidth = maxWidth;
			}
		}

		// If the width is NaN it can grow up to TextLine.MAX_LINE_WIDTH wide.
		// If the height is NaN it can grow to allow all the text to fit.
		_textContainerManager.compositionWidth = composeWidth;
		_textContainerManager.compositionHeight = composeHeight;

		// If scrolling, always compose with the composer so we get consistent
		// measurements.  The factory and the composer produce slightly
		// different results which can confuse the scroller.  If there isn't a
		// composer, this calls updateContainer so do it here now that the
		// composition sizes are set so the results can be used.
		if (clipAndEnableScrolling && _textContainerManager.composeState != TextContainerManager.COMPOSE_COMPOSER)
		{
			_textContainerManager.convertToTextFlowWithComposer();
		}

		// Compose only.  The display should not be updated.
		_textContainerManager.compose();

		// Adjust width and height for text alignment.
		var bounds:Rectangle = _textContainerManager.getContentBounds();

		// If it's an empty text flow, there is one line with one character so the height is good for the line but we
		// need to give it some width other than optional padding.
		if (_textContainerManager.getText().length == 0)
		{
			// Empty text flow.  One Em wide so there
			// is a place to put the insertion cursor.
			bounds.width = bounds.width + effectiveTextFormat.fontSize;
		}

		//trace("measureTextSize", composeWidth, "->", bounds.width, composeHeight, "->", bounds.height);

		return bounds;
	}

	/**
	 *  If auto-sizing text, it may need to be remeasured if it is
	 *  constrained in one dimension by the layout manager.  If it is
	 *  constrained in both dimensions there is no need to remeasure.
	 *  Changing one dimension may change the size of the measured text
	 *  and the layout manager needs to know this.
	 */
	private function remeasureText(width:Number, height:Number):Boolean
	{
		// Neither dimensions changed.  If auto-sizing we're still auto-sizing.
		if (width == measuredWidth && height == measuredHeight)
		{
			return false;
		}

		// Either constraints are preventing auto-sizing or we need to
		// remeasure which will reset autoSize.
		autoSize = false;

		// If no width or height, there is nothing to remeasure since
		// there is no room for text.
		if (width == 0 || height == 0)
		{
			return false;
		}

		if (!isNaN(widthConstraint))
		{
			// Do we have a constrained width and an explicit height?
			// If so, the sizes are set so no need to remeasure now.
			if (!isNaN(explicitHeight) || !isNaN(_heightInLines) || !isNaN(heightConstraint))
			{
				return false;
			}

			// No reflow for explicit lineBreak
			if (_textContainerManager.hostFormat.lineBreak == "explicit")
			{
				return false;
			}
		}

		if (!isNaN(heightConstraint))
		{
			// Do we have a constrained height and an explicit width?
			// If so, the sizes are set so no need to remeasure now.
			if (!isNaN(explicitWidth) || !isNaN(_widthInChars))
			{
				return false;
			}
		}

		// Width or height is different than what was measured.  Since we're
		// auto-sizing, need to remeasure, so the layout manager leaves the
		// correct amount of space for the component.
		invalidateSize();

		return true;
	}

	/**
	 *  This method is called when anything affecting the default font, size, weight, etc. changes.
	 *  It calculates the 'ascent', 'descent', and instance variables, which are used in measure().
	 */
	private function calculateFontMetrics():void
	{
		textElement.elementFormat = TextFormat(effectiveTextFormat).elementFormat;
		var textLine:TextLine = measureText("M");
		ascent = textLine.ascent;
		descent = textLine.descent;
	}

	public function measureText(text:String):TextLine
	{
		textElement.text = text;
		if (embeddedFontContext == null)
		{
			return textBlock.createTextLine(null, 1000);
		}
		else
		{
			return embeddedFontContext.callInContext(textBlock.createTextLine, textBlock, [null, 1000]);
		}
	}

	private function calculateWidthInChars():Number
	{
		var effectiveWidthInChars:int = isNaN(_widthInChars) ? (isNaN(_heightInLines) ? 10 : 1) : _widthInChars;
		// Without the explicit casts, if padding values are non-zero, the returned width is a very large number.
		return effectiveTextFormat.paddingLeft + (effectiveWidthInChars * effectiveTextFormat.fontSize) + effectiveTextFormat.paddingRight;
	}

	/**
	 *  Calculates the height needed for heightInLines lines using the default font.
	 */
	private function calculateHeightInLines():Number
	{
		var height:Number = effectiveTextFormat.paddingTop + effectiveTextFormat.paddingBottom;
		if (_heightInLines == 0)
		{
			return height;
		}

		var effectiveHeightInLines:int;
		// If both height and width are NaN use 10 lines.  Otherwise if only height is NaN, use 1.
		effectiveHeightInLines = isNaN(_heightInLines) ? (isNaN(_widthInChars) ? 10 : 1) : _heightInLines;

		// Position of the baseline of first line in the container.
		value = effectiveTextFormat.firstBaselineOffset;
		if (value == lineHeight)
		{
			height += lineHeight;
		}
		else
		{
			height += value is Number ? Number(value) : ascent;
		}

		// Distance from baseline to baseline.  Can be +/- number or +/- percent (in form "120%") or "undefined".
		if (effectiveHeightInLines > 1)
		{
			var value:Object = effectiveTextFormat.lineHeight;
			var lineHeight:Number = TextUtil.getNumberOrPercentOf(value, effectiveTextFormat.fontSize);
			// Default is 120%
			if (isNaN(lineHeight))
			{
				lineHeight = effectiveTextFormat.fontSize * 1.2;
			}

			height += (effectiveHeightInLines - 1) * lineHeight;
		}

		// Add in descent of last line.
		height += descent;

		return height;
	}

	private function updateEditingMode():void
	{
		var newEditingMode:String = EditingMode.READ_ONLY;
		if (enabled)
		{
			if (_editable)
			{
				newEditingMode = EditingMode.READ_WRITE;
			}
			else if (_selectable)
			{
				newEditingMode = EditingMode.READ_SELECT;
			}
		}

		editingMode = newEditingMode;
	}

	/**
	 *  This is used when text is either inserted or appended via the API.
	 */
	private function handleInsertText(newText:String, isAppend:Boolean = false):void
	{
		// Make sure all properties are committed.  The damage handler for the
		// insert will cause the remeasure and display update.
		validateProperties();

		if (isAppend)
		{
			// Set insertion pt to the end of the current text.
			_selectionAnchorPosition = text.length;
			_selectionActivePosition = _selectionAnchorPosition;
		}
		// Insert requires a selection, or it is a noop.
		else if (_selectionAnchorPosition == -1 || _selectionActivePosition == -1)
		{
			return;
		}

		// This will update the selection after the operation is done.
		if (_textContainerManager.insertTextOperation(newText, _selectionAnchorPosition, _selectionActivePosition))
		{
			dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
	}

	private function handlePasteOperation(op:PasteOperation):void
	{
		var hasConstraints:Boolean = restrict != null || maxChars > 0 || displayAsPassword;

		// If there are no constraints and multiline text is allowed there is nothing that needs to be done.
		if (!hasConstraints && multiline)
		{
			return;
		}

		// If copied/cut from displayAsPassword field the pastedText is '*' characters but this is correct.
		var pastedText:String = TextUtil.extractText(op.textScrap.textFlow);

		// If there are no constraints and no newlines there is nothing more to do.
		if (!hasConstraints && pastedText.indexOf("\n") == -1)
		{
			return;
		}

		// Save this in case we modify the pasted text.  We need to know how much text to delete.
		var textLength:int = pastedText.length;

		// If multiline is false, strip newlines out of pasted text
		// This will not strip newlines out of displayAsPassword fields
		// since the text is the passwordChar and newline won't be found.
		if (!multiline)
		{
			pastedText = pastedText.replace(ALL_NEWLINES_REGEXP, "");
		}

		// We know it's an EditManager or we wouldn't have gotten here.
		var editManager:IEditManager = IEditManager(_textContainerManager.beginInteraction());

		// Generate a CHANGING event for the PasteOperation but not for the
		// DeleteTextOperation or the InsertTextOperation which are also part of the paste.
		dispatchChangeAndChangingEvents = false;

		var selectionState:SelectionState = new SelectionState(op.textFlow, op.absoluteStart, op.absoluteStart + textLength);
		editManager.deleteText(selectionState);

		// Insert the same text, the same place where the paste was done.
		// This will go thru the InsertPasteOperation and do the right things with restrict, maxChars and displayAsPassword.
		selectionState = new SelectionState(op.textFlow, op.absoluteStart, op.absoluteStart);
		editManager.insertText(pastedText, selectionState);

		// All done with the edit manager.
		_textContainerManager.endInteraction();

		dispatchChangeAndChangingEvents = true;
	}

	/**
	 *  find the right time to listen to the focusmanager
	 */
	private function addedToStageHandler(event:Event):void
	{
		if (event.target == this)
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			callLater(addActivateHandlers);
		}
	}

	/**
	 *  add listeners to focusManager
	 */
	private function addActivateHandlers():void
	{
		if (focusManager != null)
		{
			focusManager.addEventListener(FlexEvent.FLEX_WINDOW_ACTIVATE, _textContainerManager.activateHandler, false, 0, true);
			focusManager.addEventListener(FlexEvent.FLEX_WINDOW_DEACTIVATE, _textContainerManager.deactivateHandler, false, 0, true);
		}
	}

	/**
	 *  Called when a FocusManager is added to an IFocusManagerContainer.
	 *  We need to check that it belongs to us before listening to it.
	 *  Because we listen to sandboxroot, you cannot assume the type of the event.
	 */
	private function addFocusManagerHandler(event:Event):void
	{
		if (focusManager == event.target["focusManager"])
		{
			systemManager.getSandboxRoot().removeEventListener(FlexEvent.ADD_FOCUS_MANAGER, addFocusManagerHandler, true);
			addActivateHandlers();
		}
	}

	/**
	 *  RichEditableTextContainerManager overrides focusInHandler and calls this before executing its own focusInHandler.
	 */
	mx_internal function focusInHandler(event:FocusEvent):void
	{
		//trace("focusIn handler");

		var fm:IFocusManager = focusManager;
		if (fm != null && editingMode == EditingMode.READ_WRITE)
		{
			fm.showFocusIndicator = true;
		}

		// showFocusIndicator must be set before this is called.
		super.focusInHandler(event);

		if (editingMode == EditingMode.READ_WRITE)
		{
			// If the focusIn was because of a mouseDown event, let TLF
			// handle the selection.  Otherwise it was because we tabbed in
			// or we programatically set the focus.
			if (!mouseDown)
			{
				var selectionManager:ISelectionManager = _textContainerManager.beginInteraction();

				if (multiline)
				{
					if (!selectionManager.hasSelection())
					{
						selectionManager.selectRange(0, 0);
					}
				}
				else if (!hasProgrammaticSelectionRange)
				{
					selectionManager.selectAll();
				}

				selectionManager.refreshSelection();

				_textContainerManager.endInteraction();
			}

			if (_imeMode != null)
			{
				// When IME.conversionMode is unknown it cannot be
				// set to anything other than unknown(English)
				try
				{
					if (!errorCaught && IME.conversionMode != IMEConversionMode.UNKNOWN)
					{
						IME.conversionMode = _imeMode;
					}
					errorCaught = false;
				}
				catch(e:Error)
				{
					// Once an error is thrown, focusIn is called
					// again after the Alert is closed, throw error
					// only the first time.
					errorCaught = true;
					throw new Error("unsupportedMode: " + _imeMode);
				}
			}
		}

		if (focusManager != null && multiline)
		{
			focusManager.defaultButtonEnabled = false;
		}
	}

	/**
	 *  RichEditableTextContainerManager overrides focusOutHandler and calls
	 *  this before executing its own focusOutHandler.
	 */
	mx_internal function focusOutHandler(event:FocusEvent):void
	{
		//trace("focusOut handler");

		super.focusOutHandler(event);

		// By default, we clear the undo history when a RichEditableText loses focus.
		if (clearUndoOnFocusOut && undoManager)
		{
			undoManager.clearAll();
		}

		if (focusManager != null)
		{
			focusManager.defaultButtonEnabled = true;
		}

		dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
	}

	/**
	 *  @private
	 *  RichEditableTextContainerManager overrides keyDownHandler and calls
	 *  this before executing its own keyDownHandler.
	 */
	mx_internal function keyDownHandler(event:KeyboardEvent):void
	{
		if (editingMode != EditingMode.READ_WRITE)
			return;

		// We always handle the 'enter' key since we would have to recreate
		// the container manager to change the configuration if multiline
		// changes.
		if (event.keyCode == Keyboard.ENTER)
		{
			if (!multiline)
			{
				dispatchEvent(new FlexEvent(FlexEvent.ENTER));
				event.preventDefault();
				return;
			}

			// Multiline.  Make sure there is room before acting on it.
			if (_maxChars != 0 && text.length >= _maxChars)
			{
				event.preventDefault();
				return;
			}

			var editManager:IEditManager = EditManager(_textContainerManager.beginInteraction());

			if (editManager.hasSelection())
				editManager.splitParagraph();

			_textContainerManager.endInteraction();

			event.preventDefault();
		}
	}

	mx_internal function mouseDownHandler(event:MouseEvent):void
	{
		mouseDown = true;

		// Need to get called even if mouse events are dispatched
		// outside of this component.  For example, when the user does
		// a mouse down in RET, drags the mouse outside of the
		/// component, and then releases the mouse.
		systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true /*useCapture*/);
	}

	private function systemManager_mouseUpHandler(event:MouseEvent):void
	{
		mouseDown = false;

		systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true /*useCapture*/);
	}

	/**
	 *  @private
	 *  If the textFlow hasn't changed the generation remains the same.
	 *  Changing the composition width and/or height does not change the
	 *  generation.  The bounds can change as a result of different
	 *  composition dimensions or as a result of more of the text flow
	 *  being composed.  Only as much of the text flow as is displayed is
	 *  composed.  If not all of the text flow is composed, its content height
	 *  is estimated.  Until the entire text flow is composed its content
	 *  height can increase or decrease while scrolling thru the flow.
	 *
	 *  If the following conditions are met with the contentWidth and the
	 *  contentHeight reported to the scroller, the scroller can avoid the
	 *  situation we've seen where it tries to add a scroll bar which causes the
	 *  text to reflow, which changes the content bounds, which causes the
	 *  scroller to react, and potentially loop indefinately.
	 *
	 *	   if width is reduced the height should grow or stay the same
	 *	   if height is reduced the width should grow or stay the same
	 *	   if width and height are reduced then either the width or height
	 *		   should grow or stay the same.
	 *
	 *  toFit
	 *	  width	   height
	 *	  smaller	 smaller	 height pinned to old height
	 *	  smaller	 larger	  ok
	 *	  larger	  larger	  ok
	 *	  larger	  smaller	 ok
	 *
	 *  explicit
	 *	  width	   height
	 *	  smaller	 smaller	 width pinned to old width
	 *	  smaller	 larger	  width pinned to old width
	 *	  larger	  larger	  ok
	 *	  larger	  smaller	 ok
	 */
	private function adjustContentBoundsForScroller(bounds:Rectangle):void
	{
		// Already reported bounds at least once for this generation of
		// the text flow so we have to be careful to mantain consistency
		// for the scroller.
		if (_textFlow.generation == lastContentBoundsGeneration)
		{
			if (bounds.width < _contentWidth)
			{
				if (effectiveTextFormat.lineBreak == LineBreak.TO_FIT)
				{
					if (bounds.height < _contentHeight)
					{
						bounds.height = _contentHeight;
					}
				}
				else
				{
					// The width may get smaller if the compose height is
					// reduced and fewer lines are composed.  Use the old
					// content width which is more accurate.
					bounds.width = _contentWidth;
				}
			}
		}

		lastContentBoundsGeneration = _textFlow.generation;
	}

	/**
	 *  Called when the TextContainerManager dispatches a 'compositionComplete' event when it has recomposed the text into TextLines.
	 */
	private function textContainerManager_compositionCompleteHandler(event:CompositionCompleteEvent):void
	{
		var oldContentWidth:Number = _contentWidth;
		var oldContentHeight:Number = _contentHeight;
		var newContentBounds:Rectangle = _textContainerManager.getContentBounds();

		// Try to prevent the scroller from getting into a loop while adding/removing scroll bars.
		if (_textFlow && clipAndEnableScrolling)
		{
			adjustContentBoundsForScroller(newContentBounds);
		}

		var newContentWidth:Number = newContentBounds.width;
		var newContentHeight:Number = newContentBounds.height;
		if (newContentWidth != oldContentWidth)
		{
			_contentWidth = newContentWidth;

			// If there is a scroller, this triggers the scroller layout.
			dispatchPropertyChangeEvent("contentWidth", oldContentWidth, newContentWidth);
		}

		if (newContentHeight != oldContentHeight)
		{
			_contentHeight = newContentHeight;

			// If there is a scroller, this triggers the scroller layout.
			dispatchPropertyChangeEvent("contentHeight", oldContentHeight, newContentHeight);
		}
	}

	/**
	 *  Called when the TextContainerManager dispatches a 'damage' event.
	 *  The TextFlow could have been modified interactively or programatically.
	 */
	private function textContainerManager_damageHandler(event:DamageEvent):void
	{
		if (ignoreDamageEvent || event.damageLength == 0)
		{
			return;
		}

		// The following textContainerManager functions can trigger a damage
		// event:
		//    setText/setTextFlow
		//    set hostFormat
		//    set compositionWidth/compositionHeight
		//    set horizontalScrollPosition/veriticalScrollPosition
		//    set swfContext
		//    updateContainer or compose: always if TextFlowFactory, sometimes
		//        if flowComposer
		// or the textFlow can be modified directly.

		// If no changes, don't recompose/update.  The TextFlowFactory
		// createTextLines dispatches damage events every time the textFlow
		// is composed, even if there are no changes.
		if (_textFlow && _textFlow.generation == lastGeneration)
			return;

		// If there are pending changes, don't wipe them out.  We have
		// not gotten to commitProperties() yet.
		if (textChanged || textFlowChanged)
		{
			return;
		}

		// In this case we always maintain _text with the underlying text and
		// display the appropriate number of passwordChars.  If there are any
		// interactive editing operations _text is updated during the operation.
		if (displayAsPassword)
		{
			return;
		}

		// Invalidate _text and _content.
		_text = null;
		_textFlow = _textContainerManager.getTextFlow();

		lastGeneration = _textFlow.generation;

		// We don't need to call invalidateProperties()
		// because the hostFormat and the _textFlow are still valid.

		// If the textFlow content is modified directly or if there is a style
		// change by changing the textFlow directly the size could change.
		invalidateSize();

		invalidateDisplayList();
	}

	/**
	 *  Called when the TextContainerManager dispatches a 'scroll' event
	 *  as it autoscrolls.
	 */
	private function textContainerManager_scrollHandler(event:Event):void
	{
		var oldHorizontalScrollPosition:Number = _horizontalScrollPosition;
		var newHorizontalScrollPosition:Number = _textContainerManager.horizontalScrollPosition;

		if (newHorizontalScrollPosition != oldHorizontalScrollPosition)
		{
			_horizontalScrollPosition = newHorizontalScrollPosition;
			dispatchPropertyChangeEvent("horizontalScrollPosition", oldHorizontalScrollPosition, newHorizontalScrollPosition);
		}

		var oldVerticalScrollPosition:Number = _verticalScrollPosition;
		var newVerticalScrollPosition:Number = _textContainerManager.verticalScrollPosition;
		if (newVerticalScrollPosition != oldVerticalScrollPosition)
		{
			_verticalScrollPosition = newVerticalScrollPosition;
			dispatchPropertyChangeEvent("verticalScrollPosition", oldVerticalScrollPosition, newVerticalScrollPosition);
		}
	}

	/**
	 *  Called when the TextContainerManager dispatches a 'selectionChange' event.
	 */
	private function textContainerManager_selectionChangeHandler(event:SelectionEvent):void
	{
		var oldAnchor:int = _selectionAnchorPosition;
		var oldActive:int = _selectionActivePosition;

		var selectionState:SelectionState = event.selectionState;
		if (selectionState != null)
		{
			_selectionAnchorPosition = selectionState.anchorPosition;
			_selectionActivePosition = selectionState.activePosition;
		}
		else
		{
			_selectionAnchorPosition = -1;
			_selectionActivePosition = -1;
		}

		// Selection changed so reset.
		hasProgrammaticSelectionRange = false;

		// Only dispatch the event if the selection has really changed.
		if (oldAnchor != _selectionAnchorPosition || oldActive != _selectionActivePosition)
		{
			dispatchEvent(new FlexEvent(FlexEvent.SELECTION_CHANGE));
		}
	}

	/**
	 *  Called when the TextContainerManager dispatches an 'operationBegin' event before an editing operation.
	 */
	private function textContainerManager_flowOperationBeginHandler(event:FlowOperationEvent):void
	{
		var op:FlowOperation = event.operation;

		// The text flow's generation will be incremented if the text flow
		// is modified in any way by this operation.

		if (op is InsertTextOperation)
		{
			var insertTextOperation:InsertTextOperation = InsertTextOperation(op);
			var textToInsert:String = insertTextOperation.text;
			// Note: Must process restrict first, then maxChars, then displayAsPassword last.
			if (_restrict != null)
			{
				textToInsert = StringUtil.restrict(textToInsert, restrict);
				if (textToInsert.length == 0)
				{
					event.preventDefault();
					return;
				}
			}

			// The text deleted by this operation. If we're doing our own manipulation of the textFlow we have to take the deleted
			// text into account as well as the inserted text.
			var delSelOp:SelectionState = insertTextOperation.deleteSelectionState;
			var delLen:int = (delSelOp == null) ? 0 : delSelOp.absoluteEnd - delSelOp.absoluteStart;

			if (maxChars != 0)
			{
				var length1:int = text.length - delLen;
				var length2:int = textToInsert.length;
				if (length1 + length2 > maxChars)
				{
					textToInsert = textToInsert.substr(0, maxChars - length1);
				}
			}

			if (_displayAsPassword)
			{
				// Remove deleted text.
				if (delLen > 0)
				{
					_text = splice(_text, delSelOp.absoluteStart, delSelOp.absoluteEnd, "");
				}

				// Add in the inserted text.
				_text = splice(_text, insertTextOperation.absoluteStart, insertTextOperation.absoluteEnd, textToInsert);

				// Display the passwordChar rather than the actual text.
				textToInsert = StringUtil.repeat(passwordChar, textToInsert.length);
			}

			insertTextOperation.text = textToInsert;
		}
		else if (op is PasteOperation)
		{
			// Paste is implemented in operationEnd.  The basic idea is to allow
			// the paste to go through unchanged, but group it together with a
			// second operation that modifies text as part of the same
			// transaction. This is vastly simpler for TLF to manage.
		}
		else if (op is DeleteTextOperation || op is CutOperation)
		{
			var flowTextOperation:FlowTextOperation = FlowTextOperation(op);

			// Eat 0-length deletion.  This can happen when insertion point is
			// at start of container when a backspace is entered
			// or when the insertion point is at the end of the
			// container and a delete key is entered.
			if (flowTextOperation.absoluteStart == flowTextOperation.absoluteEnd)
			{
				event.preventDefault();
				return;
			}

			if (_displayAsPassword)
			{
				_text = splice(_text, flowTextOperation.absoluteStart, flowTextOperation.absoluteEnd, "");
			}
		}

		// Dispatch a 'changing' event from the RichEditableText as notification that an editing operation is about to occur.
		// The level will be 0 for single operations, and at the start of a composite operation.
		if (dispatchChangeAndChangingEvents && event.level == 0)
		{
			var newEvent:TextOperationEvent = new TextOperationEvent(TextOperationEvent.CHANGING, false, true, op);
			dispatchEvent(newEvent);

			// If the event dispatched from this RichEditableText is canceled,
			// cancel the one from the EditManager, which will prevent the editing operation from being processed.
			if (newEvent.isDefaultPrevented())
			{
				event.preventDefault();
			}
		}
	}

	/**
	 *  Called when the TextContainerManager dispatches an 'operationEnd' event after an editing operation.
	 */
	private function textContainerManager_flowOperationEndHandler(event:FlowOperationEvent):void
	{
		// Paste is a special case.  Any mods have to be made to the text which includes what was pasted.
		if (event.operation is PasteOperation)
		{
			handlePasteOperation(PasteOperation(event.operation));
		}
	}

	/**
	 *  Called when the TextContainerManager dispatches an 'operationComplete' event after an editing operation.
	 */
	private function textContainerManager_flowOperationCompleteHandler(event:FlowOperationEvent):void
	{
		// Dispatch a 'change' event from the this as notification that an editing operation has occurred.
		// The flow is now in a state that it can be manipulated.
		// The level will be 0 for single operations, and at the end of a composite operation.
		if (dispatchChangeAndChangingEvents && event.level == 0)
		{
			dispatchEvent(new TextOperationEvent(TextOperationEvent.CHANGE, false, true, event.operation));
		}
	}

	/**
	 *  Called when a InlineGraphicElement is resized due to having width or
	 *  height as auto or percent and the graphic has finished loading. The
	 *  size of the graphic is now known.
	 */
	private function textContainerManager_inlineGraphicStatusChangeHandler(event:StatusChangeEvent):void
	{
		if (event.status == InlineGraphicElementStatus.SIZE_PENDING && event.element is InlineGraphicElement)
		{
			// Force InlineGraphicElement.applyDelayedElementUpdate to
			// execute and finish loading the graphic.  This is a workaround
			// for the case when the image is in a compiled text flow.
			InlineGraphicElement(event.element).updateForMustUseComposer(_textContainerManager.getTextFlow());
		}
		else if (event.status == InlineGraphicElementStatus.READY)
		{
			// Now that the actual size of the graphic is available need to
			// optionally remeasure and updateContainer.
			if (autoSize)
			{
				invalidateSize();
			}

			invalidateDisplayList();
		}
	}

	public function drawFocus(isFocused:Boolean):void
	{
	}
}
}