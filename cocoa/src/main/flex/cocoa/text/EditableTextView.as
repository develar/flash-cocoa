package cocoa.text
{
import cocoa.AbstractView;

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
import flash.text.engine.FontPosture;
import flash.text.engine.FontWeight;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import flash.ui.Keyboard;

import flashx.textLayout.compose.ISWFContext;
import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.conversion.ConversionType;
import flashx.textLayout.conversion.ITextExporter;
import flashx.textLayout.conversion.ITextImporter;
import flashx.textLayout.conversion.TextConverter;
import flashx.textLayout.edit.EditManager;
import flashx.textLayout.edit.EditingMode;
import flashx.textLayout.edit.IEditManager;
import flashx.textLayout.edit.ISelectionManager;
import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.edit.SelectionState;
import flashx.textLayout.elements.Configuration;
import flashx.textLayout.elements.GlobalSettings;
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
import spark.core.IViewport;
import spark.core.NavigationUnit;
import spark.events.TextOperationEvent;
import spark.utils.TextUtil;

use namespace mx_internal;
use namespace tlf_internal;

public class EditableTextView extends AbstractView implements IFocusManagerComponent, IIMESupport, ISystemCursorClient, IViewport
{
	private static const sourceText:int = 0;
	private static const sourceTextFlow:int = 1;
	private static const sourceContent:int = 2;
	
	// from RET
	private static var classInitialized:Boolean = false;

	/**
	 *  @private
	 *  Create a single Configuration used by all Text instances.
	 *  It tells the TextContainerManager that we don't want it
	 *  to handle the ENTER key, because we need the ENTER key to behave
	 *  differently based on the 'multiline' property.
	 */
	private static var configuration:Configuration;

	private static var plainTextImporter:ITextImporter;
	private static var plainTextExporter:ITextExporter;

	/**
	 *  Regular expression which matches all newlines in the text.  Used
	 *  to strip newlines when pasting text when multiline is false.
	 */
	private static const ALL_NEWLINES_REGEXP:RegExp = /\n/g;

	/**
	 *  It is set to NaN by stylesInitialized() and styleChanged(),
	 *  and recreated whenever necessary in calculateFontMetrics().
	 */
	private var ascent:Number = NaN;

	/**
	 *  It is set to NaN by stylesInitialized() and styleChanged(),
	 *  and recreated whenever necessary in calculateFontMetrics().
	 */
	private var descent:Number = NaN;

	/**
	 *  @private
	 *  Source of text: one of "text", "textFlow" or "content".
	 */
	private var source:int = sourceText;

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

	mx_internal var embeddedFontContext:IFlexModuleFactory;

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
	 *  True if this component sizes itself based on its actual
	 *  contents.
	 */
	mx_internal var autoSize:Boolean = false;

	public function EditableTextView()
	{
		super();

		if (!classInitialized)
		{
			initClass();
		}

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

	/**
	 *  @private
	 *  This method initializes the static vars of this class.
	 *  Rather than calling it at static initialization time,
	 *  we call it in the constructor to do the class initialization
	 *  when the first instance is created.
	 *  (It does an immediate return if it has already run.)
	 *  By doing so, we avoid any static initialization issues
	 *  related to whether this class or the TLF classes
	 *  that it uses are initialized first.
	 */
	private static function initClass():void
	{
		// Set the TLF hook used for localizing runtime error messages.
		// TLF itself has English-only messages,
		// but higher layers like Flex can provide localized versions.
		GlobalSettings.resourceStringFunction = TextUtil.getResourceString;

		// Set the TLF hook used to specify the callback used for changing
		// the FontLookup based on SWFContext.
		GlobalSettings.resolveFontLookupFunction = TextUtil.resolveFontLookup;

		// Pre-FP10.1, set default tab stops in TLF.  Without this, if there
		// is a tab and TLF is measuring width, the tab will
		// measure as the rest of the remaining width up to 10000.
		GlobalSettings.enableDefaultTabStops = !Configuration.playerEnablesArgoFeatures;

		configuration = Configuration(TextContainerManager.defaultConfiguration).clone();
		configuration.manageEnterKey = false; // default is true
		configuration.manageTabKey = false;   // default is false

		plainTextImporter = TextConverter.getImporter(TextConverter.PLAIN_TEXT_FORMAT, configuration);

		// Throw import errors rather than return a null textFlow.
		// Alternatively, the error strings are in the Vector, importer.errors.
		plainTextImporter.throwOnError = true;

		plainTextExporter = TextConverter.getExporter(TextConverter.PLAIN_TEXT_FORMAT);

		classInitialized = true;
	}

	private static function splice(str:String, start:int, end:int, strToInsert:String):String
	{
		return str.substring(0, start) + strToInsert + str.substring(end, str.length);
	}

	private var _textFormat:ITextLayoutFormat;
	public function set textFormat(value:ITextLayoutFormat):void
	{
		assert(_textFormat == null);
		_textFormat = value;

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

	private var _clipAndEnableScrolling:Boolean = false;
	private var clipAndEnableScrollingChanged:Boolean = false;

	public function get clipAndEnableScrolling():Boolean
	{
		return _clipAndEnableScrolling;
	}

	public function set clipAndEnableScrolling(value:Boolean):void
	{
		if (value == _clipAndEnableScrolling)
			return;

		_clipAndEnableScrolling = value;
		clipAndEnableScrollingChanged = true;

		invalidateProperties();
	}

	private var _contentHeight:Number = 0;

	[Bindable("propertyChange")]
	public function get contentHeight():Number
	{
		return _contentHeight;
	}

	private var _contentWidth:Number = 0;
	[Bindable("propertyChange")]
	public function get contentWidth():Number
	{
		return _contentWidth;
	}

	private var _horizontalScrollPosition:Number = 0;
	private var horizontalScrollPositionChanged:Boolean = false;

	[Bindable("propertyChange")]
	public function get horizontalScrollPosition():Number
	{
		return _horizontalScrollPosition;
	}

	public function set horizontalScrollPosition(value:Number):void
	{
		// Convert NaN to 0 to keep TCM happy.
		if (isNaN(value))
			value = 0;

		if (value == _horizontalScrollPosition)
			return;

		_horizontalScrollPosition = value;
		horizontalScrollPositionChanged = true;

		invalidateProperties();

		// Note:  TLF takes care of updating the container when the scroll
		// position is set so there is no need for us to invalidate the
		// display list.
	}

	private var _verticalScrollPosition:Number = 0;
	private var verticalScrollPositionChanged:Boolean = false;

	[Bindable("propertyChange")]

	public function get verticalScrollPosition():Number
	{
		return _verticalScrollPosition;
	}

	public function set verticalScrollPosition(value:Number):void
	{
		// Convert NaN to 0 to keep TCM happy.
		if (isNaN(value))
			value = 0;

		if (value == _verticalScrollPosition)
			return;

		_verticalScrollPosition = value;
		verticalScrollPositionChanged = true;

		invalidateProperties();

		// Note:  TLF takes care of updating the container when the scroll
		// position is set so there is no need for us to invalidate the
		// display list.
	}


	private var _content:Object;
	private var contentChanged:Boolean = false;

	/**
	 *  @private
	 *  This metadata tells the MXML compiler to disable some of its default
	 *  interpretation of the value specified for the 'content' property.
	 *  Normally, for properties of type Object, it assumes that things
	 *  looking like numbers are numbers and things looking like arrays
	 *  are arrays. But <content>1</content> should generate code to set the
	 *  content to  the String "1", not the int 1, and <content>[1]</content>
	 *  should set it to the String "[1]", not the Array [ 1 ].
	 *  However, {...} continues to be interpreted as a databinding
	 *  expression, and @Resource(...), @Embed(...), etc.
	 *  as compiler directives.
	 *  Similar metadata on TLF classes causes the same rules to apply
	 *  within <p>, <span>, etc.
	 */
	[RichTextContent]

	/**
	 *  This property is intended for use in MXML at compile time;
	 *  to get or set rich text content at runtime,
	 *  please use the <code>textFlow</code> property instead.
	 *
	 *  <p>The <code>content</code> property is the default property
	 *  for RichEditableText, so that you can write MXML such as
	 *  <pre>
	 *  &lt;s:RichEditableText&gt;Hello &lt;s:span fontWeight="bold"/&gt;World&lt;/s:span&gt;&lt;/s:RichEditableText&gt;
	 *  </pre>
	 *  and have the String and SpanElement that you specify
	 *  as the content be used to create a TextFlow.</p>
	 *
	 *  <p>This property is typed as Object because you can set it to
	 *  to a String, a FlowElement, or an Array of Strings and FlowElements.
	 *  In the example above, you are specifying the content
	 *  to be a 2-element Array whose first element is the String
	 *  "Hello" and whose second element is a SpanElement with the text
	 *  "World" in boldface.</p>
	 *
	 *  <p>No matter how you specify the content, it gets converted
	 *  into a TextFlow, and when you get this property, you will get
	 *  the resulting TextFlow.</p>
	 *
	 *  <p>Adobe recommends using <code>textFlow</code> property
	 *  to get and set rich text content at runtime,
	 *  because it is strongly typed as a TextFlow
	 *  rather than as an Object.
	 *  A TextFlow is the canonical representation
	 *  for rich text content in the Text Layout Framework.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get content():Object
	{
		return textFlow;
	}

	/**
	 *  @private
	 */
	public function set content(value:Object):void
	{
		// Treat setting the 'content' to null
		// as if 'text' were being set to the empty String
		// (which is the default state).
		if (value == null)
		{
			text = "";
			return;
		}

		if (value == _content)
			return;

		_content = value;
		contentChanged = true;
		source = sourceContent;

		// Of 'text', 'textFlow', and 'content', the last one set wins.
		textChanged = false;
		textFlowChanged = false;

		// The other two are now invalid and must be recalculated when needed.
		_text = null;
		_textFlow = null;

		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();

		dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
	}

	//----------------------------------
	//  displayAsPassword
	//----------------------------------

	/**
	 *  @private
	 */
	private var _displayAsPassword:Boolean = false;

	/**
	 *  @private
	 */
	private var displayAsPasswordChanged:Boolean = false;

	/**
	 *  @copy flash.text.TextField#displayAsPassword
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get displayAsPassword():Boolean
	{
		return _displayAsPassword;
	}

	/**
	 *  @private
	 */
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

	//----------------------------------
	//  editable
	//----------------------------------

	/**
	 *  @private
	 */
	private var _editable:Boolean = true;

	/**
	 *  @private
	 */
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

	//----------------------------------
	//  editingMode
	//----------------------------------

	/**
	 *  @private
	 *  The editingMode of this component's TextContainerManager.
	 *  Note that this is not a public property
	 *  and does not use the invalidation mechanism.
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

	/**
	 *  @private
	 */
	private function set editingMode(value:String):void
	{
		var lastEditingMode:String = _textContainerManager.editingMode;

		if (lastEditingMode == value)
			return;

		_textContainerManager.editingMode = value;

		// Make sure the selection manager selection is in sync with the
		// current selection.
		if (value != EditingMode.READ_ONLY && _selectionAnchorPosition != -1 && _selectionActivePosition != -1)
		{
			var selectionManager:ISelectionManager = _textContainerManager.beginInteraction();

			selectionManager.selectRange(_selectionAnchorPosition, _selectionActivePosition);

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
	 *
	 *  @default 0
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get maxChars():int
	{
		return _maxChars;
	}

	/**
	 *  @private
	 */
	public function set maxChars(value:int):void
	{
		_maxChars = value;
	}

	//----------------------------------
	//  multiline
	//----------------------------------

	/**
	 *  @private
	 */
	private var _multiline:Boolean = true;

	/**
	 *  Determines whether the user can enter multiline text.
	 *
	 *  <p>If <code>true</code>, the Enter key starts a new paragraph.
	 *  If <code>false</code>, the Enter key doesn't affect the text
	 *  but causes the RichEditableText to dispatch an <code>"enter"</code>
	 *  event.  If you paste text into the RichEditableText with a multiline
	 *  value of <code>true</code>, newlines are stripped out of the text. </p>
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get multiline():Boolean
	{
		return _multiline;
	}

	/**
	 *  @private
	 */
	public function set multiline(value:Boolean):void
	{
		_multiline = value;
	}

	//----------------------------------
	//  restrict
	//----------------------------------

	/**
	 *  @private
	 */
	private var _restrict:String = null;

	/**
	 *  @copy flash.text.TextField#restrict
	 *
	 *  @default null
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get restrict():String
	{
		return _restrict;
	}

	/**
	 *  @private
	 */
	public function set restrict(value:String):void
	{
		_restrict = value;
	}

	//----------------------------------
	//  selectable
	//----------------------------------

	/**
	 *  @private
	 */
	private var _selectable:Boolean = true;

	/**
	 *  @private
	 */
	private var selectableChanged:Boolean = false;

	/**
	 *  A flag indicating whether the content is selectable
	 *  with the mouse, or with the keyboard when the control
	 *  has the keyboard focus.
	 *
	 *  <p>Making the text selectable lets you copy text from the control.</p>
	 *
	 *  <p>This property is ignored if the <code>editable</code>
	 *  property is <code>true</code>.</p>
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get selectable():Boolean
	{
		return _selectable;
	}

	/**
	 *  @private
	 */
	public function set selectable(value:Boolean):void
	{
		if (value == _selectable)
			return;

		_selectable = value;
		selectableChanged = true;

		invalidateProperties();
		invalidateDisplayList();
	}

	//----------------------------------
	//  selectionActivePosition
	//----------------------------------

	/**
	 *  @private
	 */
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
	 */ public function get selectionActivePosition():int
	{
		return _selectionActivePosition;
	}

	//----------------------------------
	//  selectionAnchorPosition
	//----------------------------------

	/**
	 *  @private
	 */
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
	 */ public function get selectionAnchorPosition():int
	{
		return _selectionAnchorPosition;
	}

	private var _selectionHighlighting:String = TextSelectionHighlighting.WHEN_FOCUSED;

	/**
	 *  @private
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

	/**
	 *  @private
	 */
	public function set selectionHighlighting(value:String):void
	{
		if (value == _selectionHighlighting)
			return;

		_selectionHighlighting = value;
		selectionFormatsChanged = true;

		invalidateProperties();
		invalidateDisplayList();
	}

	//----------------------------------
	//  text
	//----------------------------------

	/**
	 *  @private
	 */
	private var _text:String = "";

	/**
	 *  @private
	 */
	private var textChanged:Boolean = false;

	[Bindable("change")]
	[Inspectable(category="General")]

	/**
	 *  The text String displayed by this component.
	 *
	 *  <p>Setting this property affects the <code>textFlow</code> property
	 *  and vice versa.</p>
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
	 *  <p>If you set the <code>textFlow</code> and get the <code>text</code>,
	 *  the text in each paragraph will be separated by a single
	 *  LF ("\n").</p>
	 *
	 *  <p>Setting this property also affects the properties
	 *  specifying the control's scroll position and the text selection.
	 *  It resets the <code>horizontalScrollPosition</code>
	 *  and <code>verticalScrollPosition</code> to 0,
	 *  and it sets the <code>selectionAnchorPosition</code>
	 *  and <code>selectionActivePosition</code>
	 *  to -1 to clear the selection.</p>
	 *
	 *  @default ""
	 *
	 *  @see #textFlow
	 *  @see #horizontalScrollPosition
	 *  @see #verticalScrollPosition
	 *  @see #selectionAnchorPosition
	 *  @see #selectionActivePosition
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ public function get text():String
	{
		// Extracting the plaintext from a TextFlow is somewhat expensive,
		// as it involves iterating over the leaf FlowElements in the TextFlow.
		// Therefore we do this extraction only when necessary, namely when
		// you first set the 'content' or the 'textFlow'
		// (or mutate the TextFlow), and then get the 'text'.
		if (_text == null)
		{
			// If 'content' was last set,
			// we have to first turn that into a TextFlow.
			if (_content != null)
				_textFlow = createTextFlowFromContent(_content);

			// Once we have a TextFlow, we can export its plain text.
			//noinspection ReservedWordAsName
			_text = plainTextExporter.export(_textFlow, ConversionType.STRING_TYPE) as String;
		}

		return _text;
	}

	/**
	 *  @private
	 *  This will create a TextFlow with a single paragraph with a single span
	 *  with exactly the text specified.  If there is whitespace and line
	 *  breaks in the text, they will remain, regardless of the settings of
	 *  the lineBreak and whiteSpaceCollapse styles.
	 */
	public function set text(value:String):void
	{
		// Treat setting the 'text' to null
		// as if it were set to the empty String
		// (which is the default state).
		if (value == null)
		{
			value = "";
		}

		// If value is the same as _text, make sure if was not produced from
		// setting 'textFlow' or 'content'.  For example, if you set a TextFlow
		// corresponding to "Hello <span color="OxFF0000">World</span>"
		// and then get the 'text', it will be the String "Hello World"
		// But if you then set the 'text' to "Hello World"
		// this represents a change: the "World" should no longer be red.
		//
		// Note: this is needed to stop two-binding from recursing.
		if (source == sourceText && text == value)
		{
			return;
		}

		_text = value;
		textChanged = true;
		source = sourceText;

		// Of 'text', 'textFlow', and 'content', the last one set wins.
		textFlowChanged = false;
		contentChanged = false;

		// The other two are now invalid and must be recalculated when needed.
		_textFlow = null;
		_content = null;

		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();

		dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
	}

	//----------------------------------
	//  textContainerManager
	//----------------------------------

	/**
	 *  @private
	 */
	private var _textContainerManager:EditableTextContainerManager;

	/**
	 *  @private
	 *  The TLF TextContainerManager instance that displays,
	 *  scrolls, and edits the text in this component.
	 */
	mx_internal function get textContainerManager():TextContainerManager
	{
		return _textContainerManager;
	}

	//----------------------------------
	//  textFlow
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the textFlow property.
	 */
	private var _textFlow:TextFlow;

	/**
	 *  @private
	 */
	private var textFlowChanged:Boolean = false;

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
	public function get textFlow():TextFlow
	{
		// Note: this could be called before all properties are committed.

		// We might not have a valid _textFlow for two reasons:
		// either because the 'text' was set (which is the state
		// after construction) or because the 'content' was set.
		if (!_textFlow)
		{
			if (_content != null)
			{
				_textFlow = createTextFlowFromContent(_content);
				_content = null;
			}
			else
			{
				_textFlow = plainTextImporter.importToFlow(_text);
			}
		}

		// Make sure the interactionManager is added to this textFlow.
		if (textChanged || contentChanged || textFlowChanged)
		{
			_textContainerManager.setTextFlow(_textFlow);
			textChanged = contentChanged = textFlowChanged = false;
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

	/**
	 *  @private
	 */
	public function set textFlow(value:TextFlow):void
	{
		// Treat setting the 'textFlow' to null
		// as if 'text' were being set to the empty String
		// (which is the default state).
		if (value == null)
		{
			text = "";
			return;
		}

		if (value == _textFlow)
			return;

		_textFlow = value;
		textFlowChanged = true;
		source = sourceTextFlow;

		// Of 'text', 'textFlow', and 'content', the last one set wins.
		textChanged = false;
		contentChanged = false;

		// The other two are now invalid and must be recalculated when needed.
		_text = null;
		_content = null;

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
		// will be true; the other two will be false because each setter
		// guarantees this.

		if (textChanged)
		{
			// If the text has linebreaks (CR, LF, or CF+LF)
			// create a multi-paragraph TextFlow from it
			// and use the TextFlowTextLineFactory to render it.
			// Otherwise the StringTextLineFactory will put
			// all of the lines into a single paragraph
			// and FTE performance will degrade on a large paragraph.
			if (_text.indexOf("\n") != -1 || _text.indexOf("\r") != -1)
			{
				_textFlow = plainTextImporter.importToFlow(_text);
				_textContainerManager.setTextFlow(_textFlow);
			}
			else
			{
				_textContainerManager.setText(_text);
			}
		} else if (textFlowChanged)
		{
			_textContainerManager.setTextFlow(_textFlow);
		} else if (contentChanged)
		{
			_textFlow = createTextFlowFromContent(_content);
			_textContainerManager.setTextFlow(_textFlow);

			// Content converted to textFlow.
			_content = null;
		}

		if (textChanged || textFlowChanged || contentChanged)
		{
			lastGeneration = _textFlow ? _textFlow.generation : 0;
			lastContentBoundsGeneration = 0;

			// Handle the case where the initial text, textFlow or content
			// is displayed as a password.
			if (displayAsPassword)
				displayAsPasswordChanged = true;

			textChanged = false;
			textFlowChanged = false;
			contentChanged = false;
		}

		// If displayAsPassword changed, it only applies to the display,
		// not the underlying text.
		if (displayAsPasswordChanged)
		{
			var oldAnchorPosition:int = _selectionAnchorPosition;
			var oldActivePosition:int = _selectionActivePosition;

			// If there is any text, convert it to the passwordChar.
			if (displayAsPassword)
			{
				// Make sure _text is set with the actual text before we
				// change the displayed text.
				_text = text;

				// Paragraph terminators are lost during this substitution.
				var textToDisplay:String = StringUtil.repeat(passwordChar, _text.length);

				_textContainerManager.setText(textToDisplay);
			}
			else
			{
				// Text was displayed as password.  Now display as plain text.
				_textContainerManager.setText(_text);
			}

			if (editingMode != EditingMode.READ_ONLY)
			{
				// Must preserve the selection, if there was one.
				var selManager:ISelectionManager = _textContainerManager.beginInteraction();

				// The visible selection will be refreshed during the update.
				selManager.selectRange(oldAnchorPosition, oldActivePosition);

				_textContainerManager.endInteraction();
			}

			displayAsPasswordChanged = false;
		}

		if (clipAndEnableScrollingChanged)
		{
			// The TLF code seems to check for !off.
			_textContainerManager.horizontalScrollPolicy = "auto";
			_textContainerManager.verticalScrollPolicy = "auto";

			clipAndEnableScrollingChanged = false;
		}

		if (horizontalScrollPositionChanged)
		{
			var oldHorizontalScrollPosition:Number = _textContainerManager.horizontalScrollPosition;

			_textContainerManager.horizontalScrollPosition = _horizontalScrollPosition;

			dispatchPropertyChangeEvent("horizontalScrollPosition", oldHorizontalScrollPosition, _horizontalScrollPosition);

			horizontalScrollPositionChanged = false;
		}

		if (verticalScrollPositionChanged)
		{
			var oldVerticalScrollPosition:Number = _textContainerManager.verticalScrollPosition;

			_textContainerManager.verticalScrollPosition = _verticalScrollPosition;

			dispatchPropertyChangeEvent("verticalScrollPosition", oldVerticalScrollPosition, _verticalScrollPosition);

			verticalScrollPositionChanged = false;
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
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		// Check if the auto-size text is constrained in some way and needs
		// to be remeasured.  If one of the dimension changes, the text may
		// compose differently and have a different size which the layout
		// manager needs to know.
		if (autoSize && remeasureText(unscaledWidth, unscaledHeight))
		{
			return;
		}

		super.updateDisplayList(unscaledWidth, unscaledHeight);

		// If we're autoSizing we're telling the layout manager one set of
		// values and TLF another set of values so there is room for the text
		// to grow.

		// autoSize for blockProgression=="rl" is implemented
		if (!autoSize)
		{
			_textContainerManager.compositionWidth = unscaledWidth;
			_textContainerManager.compositionHeight = unscaledHeight;
		}

		// If scrolling, always compose with the composer so we get consistent
		// measurements.  The factory and the composer produce slightly
		// different results which can confuse the scroller.  If there isn't a
		// composer, this calls updateContainer so do it here now that the
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

	//--------------------------------------------------------------------------
	//
	//  Methods: IViewport
	//
	//--------------------------------------------------------------------------

	public function getHorizontalScrollPositionDelta(navigationUnit:uint):Number
	{
		var scrollR:Rectangle = scrollRect;
		if (!scrollR)
		{
			return 0;
		}

		// maxDelta is the horizontalScrollPosition delta required to scroll to the RIGHT and minDelta scrolls to LEFT.
		var maxDelta:Number = contentWidth - scrollR.right;
		var minDelta:Number = -scrollR.left;

		// Scroll by a "character" which is 1 em (matches widthInChars()).
		var em:Number = effectiveTextFormat.fontSize;

		switch (navigationUnit)
		{
			case NavigationUnit.LEFT:
				return (scrollR.left <= 0) ? 0 : Math.max(minDelta, -em);

			case NavigationUnit.RIGHT:
				return (scrollR.right >= contentWidth) ? 0 : Math.min(maxDelta, em);

			case NavigationUnit.PAGE_LEFT:
				return Math.max(minDelta, -scrollR.width);

			case NavigationUnit.PAGE_RIGHT:
				return Math.min(maxDelta, scrollR.width);

			case NavigationUnit.HOME:
				return minDelta;

			case NavigationUnit.END:
				return maxDelta;

			default:
				return 0;
		}
	}

	/**
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function getVerticalScrollPositionDelta(navigationUnit:uint):Number
	{
		var scrollR:Rectangle = scrollRect;
		if (!scrollR)
			return 0;

		// maxDelta is the horizontalScrollPosition delta required
		// to scroll to the END and minDelta scrolls to HOME.
		var maxDelta:Number = contentHeight - scrollR.bottom;
		var minDelta:Number = -scrollR.top;

		switch (navigationUnit)
		{
			case NavigationUnit.UP:
				return _textContainerManager.getScrollDelta(-1);

			case NavigationUnit.DOWN:
				return _textContainerManager.getScrollDelta(1);

			case NavigationUnit.PAGE_UP:
				return Math.max(minDelta, -scrollR.height);

			case NavigationUnit.PAGE_DOWN:
				return Math.min(maxDelta, scrollR.height);

			case NavigationUnit.HOME:
				return minDelta;

			case NavigationUnit.END:
				return maxDelta;

			default:
				return 0;
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

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
		// depending on whether it is container-, paragraph-,
		// or character-level. Note that these can remain null.
		var containerFormat:TextLayoutFormat;
		var paragraphFormat:TextLayoutFormat;
		var characterFormat:TextLayoutFormat;

		// This internal TLF object maps the names of format properties
		// to Property instances.
		// Each Property instance has a category property which tells
		// whether it is container-, paragraph-, or character-level.
		var description:Object = TextLayoutFormat.description;

		for (var p:String in description)
		{
			if (format[p] === undefined)
				continue;

			var category:String = description[p].category;

			if (category == Category.CONTAINER)
			{
				if (containerFormat == null)
				{
					containerFormat = new TextLayoutFormat();
				}
				containerFormat[p] = format[p];
			}
			else if (category == Category.PARAGRAPH)
			{
				if (paragraphFormat == null)
				{
					paragraphFormat = new TextLayoutFormat();
				}
				paragraphFormat[p] = format[p];
			}
			else if (category == Category.CHARACTER)
			{
				if (characterFormat == null)
				{
					characterFormat = new TextLayoutFormat();
				}
				characterFormat[p] = format[p];
			}
		}

		// If the selection isn't specified, use the current one.
		if (anchorPosition == -1 && activePosition == -1)
		{
			anchorPosition = _selectionAnchorPosition;
			activePosition = _selectionActivePosition;
		}

		// Apply the three format objects to the current selection if
		// selectionState is null, else the specified selection.
		_textContainerManager.applyFormatOperation(characterFormat, paragraphFormat, containerFormat, anchorPosition, activePosition);
	}

	private function getEmbeddedFontContext():IFlexModuleFactory
	{
		if (effectiveTextFormat.fontLookup != FontLookup.DEVICE)
		{
			return getFontContext(effectiveTextFormat.fontFamily, effectiveTextFormat.fontWeight == FontWeight.BOLD, effectiveTextFormat.fontStyle == FontPosture.ITALIC, true);
		}
		else
		{
			return null;
		}
	}

	private function get effectiveTextFormat():ITextLayoutFormat
	{
		return _textFormat == null ? _textFlow.computedFormat : _textFormat;
	}

	/**
	 *  @private
	 *  Return true if there is a width and height to use for the measure.
	 */
	mx_internal function isMeasureFixed():Boolean
	{
		if (effectiveTextFormat.blockProgression != BlockProgression.TB)
		{
			return true;
		}

		// Is there some sort of width and some sort of height?
		return  (!isNaN(explicitWidth) || !isNaN(_widthInChars) || !isNaN(widthConstraint)) && (!isNaN(explicitHeight) || !isNaN(_heightInLines) || !isNaN(heightConstraint));
	}

	/**
	 *  @private
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

		// If it's an empty text flow, there is one line with one
		// character so the height is good for the line but we
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
	 *  @private
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

	private static const textElement:TextElement = new TextElement();
	private static const textBlock:TextBlock = new TextBlock(textElement);
	/**
	 *  @private
	 *  This method is called when anything affecting the
	 *  default font, size, weight, etc. changes.
	 *  It calculates the 'ascent', 'descent', and
	 *  instance variables, which are used in measure().
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
		var swfContext:ISWFContext = ISWFContext(embeddedFontContext);
		if (swfContext != null)
		{
			return swfContext.callInContext(textBlock.createTextLine, textBlock, [null, 1000]);
		}
		else
		{
			return textBlock.createTextLine(null, 1000);
		}
	}

	private function calculateWidthInChars():Number
	{
		var effectiveWidthInChars:int;
		// If both height and width are NaN use 10 chars.  Otherwise if only width is NaN, use 1.
		if (isNaN(_widthInChars))
		{
			effectiveWidthInChars = isNaN(_heightInLines) ? 10 : 1;
		}
		else
		{
			effectiveWidthInChars = _widthInChars;
		}

		// Without the explicit casts, if padding values are non-zero, the
		// returned width is a very large number.
		return effectiveTextFormat.paddingLeft + (effectiveWidthInChars * effectiveTextFormat.fontSize) + effectiveTextFormat.paddingRight;
	}

	/**
	 *  Calculates the height needed for heightInLines lines using the default
	 *  font.
	 */
	private function calculateHeightInLines():Number
	{
		var height:Number = effectiveTextFormat.paddingTop + effectiveTextFormat.paddingBottom;

		if (_heightInLines == 0)
			return height;

		var effectiveHeightInLines:int;

		// If both height and width are NaN use 10 lines.  Otherwise if
		// only height is NaN, use 1.
		if (isNaN(_heightInLines))
			effectiveHeightInLines = isNaN(_widthInChars) ? 10 : 1;
		else
			effectiveHeightInLines = _heightInLines;

		// Position of the baseline of first line in the container.
		value = effectiveTextFormat.firstBaselineOffset;
		if (value == lineHeight)
			height += lineHeight; else if (value is Number)
			height += Number(value);
		else
			height += ascent;

		// Distance from baseline to baseline.  Can be +/- number or
		// or +/- percent (in form "120%") or "undefined".
		if (effectiveHeightInLines > 1)
		{
			var value:Object = effectiveTextFormat.lineHeight;
			var lineHeight:Number = TextUtil.getNumberOrPercentOf(value, effectiveTextFormat.fontSize);

			// Default is 120%
			if (isNaN(lineHeight))
				lineHeight = effectiveTextFormat.fontSize * 1.2;

			height += (effectiveHeightInLines - 1) * lineHeight;
		}

		// Add in descent of last line.
		height += descent;

		return height;
	}

	private function createTextFlowFromContent(content:Object):TextFlow
	{
		var textFlow:TextFlow;

		if (content is TextFlow)
		{
			textFlow = content as TextFlow;
		}
		else if (content is Array)
		{
			textFlow = new TextFlow();
			textFlow.whiteSpaceCollapse = effectiveTextFormat.whiteSpaceCollapse;
			textFlow.mxmlChildren = content as Array;
			textFlow.whiteSpaceCollapse = undefined;
		}
		else
		{
			textFlow = new TextFlow();
			textFlow.whiteSpaceCollapse = effectiveTextFormat.whiteSpaceCollapse;
			textFlow.mxmlChildren = [content];
			textFlow.whiteSpaceCollapse = undefined;
		}

		return textFlow;
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
		else
		{
			// Insert requires a selection, or it is a noop.
			if (_selectionAnchorPosition == -1 || _selectionActivePosition == -1)
				return;
		}

		// This will update the selection after the operation is done.
		var success:Boolean = _textContainerManager.insertTextOperation(newText, _selectionAnchorPosition, _selectionActivePosition);

		if (success)
			dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
	}

	/**
	 *  @private
	 */
	private function handlePasteOperation(op:PasteOperation):void
	{
		var hasConstraints:Boolean = restrict != null || maxChars > 0 || displayAsPassword;

		// If there are no constraints and multiline text is allowed
		// there is nothing that needs to be done.
		if (!hasConstraints && multiline)
			return;

		// If copied/cut from displayAsPassword field the pastedText
		// is '*' characters but this is correct.
		var pastedText:String = TextUtil.extractText(op.textScrap.textFlow);

		// If there are no constraints and no newlines there is nothing
		// more to do.
		if (!hasConstraints && pastedText.indexOf("\n") == -1)
			return;

		// Save this in case we modify the pasted text.  We need to know
		// how much text to delete.
		var textLength:int = pastedText.length;

		// If multiline is false, strip newlines out of pasted text
		// This will not strip newlines out of displayAsPassword fields
		// since the text is the passwordChar and newline won't be found.
		if (!multiline)
			pastedText = pastedText.replace(ALL_NEWLINES_REGEXP, "");

		// We know it's an EditManager or we wouldn't have gotten here.
		var editManager:IEditManager = EditManager(_textContainerManager.beginInteraction());

		// Generate a CHANGING event for the PasteOperation but not for the
		// DeleteTextOperation or the InsertTextOperation which are also part
		// of the paste.
		dispatchChangeAndChangingEvents = false;

		var selectionState:SelectionState = new SelectionState(op.textFlow, op.absoluteStart, op.absoluteStart + textLength);
		editManager.deleteText(selectionState);

		// Insert the same text, the same place where the paste was done.
		// This will go thru the InsertPasteOperation and do the right
		// things with restrict, maxChars and displayAsPassword.
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
	 *  @private
	 *  add listeners to focusManager
	 */
	private function addActivateHandlers():void
	{
		if (!focusManager)
		{
			return;
		}

		focusManager.addEventListener(FlexEvent.FLEX_WINDOW_ACTIVATE, _textContainerManager.activateHandler, false, 0, true);
		focusManager.addEventListener(FlexEvent.FLEX_WINDOW_DEACTIVATE, _textContainerManager.deactivateHandler, false, 0, true);
	}

	/**
	 *  @private
	 *  Called when a FocusManager is added to an IFocusManagerContainer.
	 *  We need to check that it belongs
	 *  to us before listening to it.
	 *  Because we listen to sandboxroot, you cannot assume the type of
	 *  the event.
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
	 *  @private
	 *  RichEditableTextContainerManager overrides focusInHandler and calls
	 *  this before executing its own focusInHandler.
	 */
	mx_internal function focusInHandler(event:FocusEvent):void
	{
		// When TCM is simulating a focusIn event, event will be null.
		// Ignore these and wait for the actual focus in event.
		if (event == null)
		{
			return;
		}

		//trace("focusIn handler");

		var fm:IFocusManager = focusManager;
		if (fm && editingMode == EditingMode.READ_WRITE)
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

		if (focusManager && multiline)
		{
			focusManager.defaultButtonEnabled = false;
		}
	}

	/**
	 *  @private
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
	 *  @private
	 *  Called when the TextContainerManager dispatches a 'compositionComplete'
	 *  event when it has recomposed the text into TextLines.
	 */
	private function textContainerManager_compositionCompleteHandler(event:CompositionCompleteEvent):void
	{
		//trace("compositionComplete");

		var oldContentWidth:Number = _contentWidth;
		var oldContentHeight:Number = _contentHeight;

		var newContentBounds:Rectangle = _textContainerManager.getContentBounds();

		// Try to prevent the scroller from getting into a loop while
		// adding/removing scroll bars.
		if (_textFlow && clipAndEnableScrolling)
			adjustContentBoundsForScroller(newContentBounds);

		var newContentWidth:Number = newContentBounds.width;
		var newContentHeight:Number = newContentBounds.height;

		if (newContentWidth != oldContentWidth)
		{
			_contentWidth = newContentWidth;

			//trace("composeWidth", _textContainerManager.compositionWidth, "contentWidth", oldContentWidth, newContentWidth);

			// If there is a scroller, this triggers the scroller layout.
			dispatchPropertyChangeEvent("contentWidth", oldContentWidth, newContentWidth);
		}

		if (newContentHeight != oldContentHeight)
		{
			_contentHeight = newContentHeight;

			//trace("composeHeight", _textContainerManager.compositionHeight, "contentHeight", oldContentHeight, newContentHeight);

			// If there is a scroller, this triggers the scroller layout.
			dispatchPropertyChangeEvent("contentHeight", oldContentHeight, newContentHeight);
		}
	}

	/**
	 *  @private
	 *  Called when the TextContainerManager dispatches a 'damage' event.
	 *  The TextFlow could have been modified interactively or programatically.
	 */
	private function textContainerManager_damageHandler(event:DamageEvent):void
	{
		if (ignoreDamageEvent || event.damageLength == 0)
			return;

		//trace("damageHandler", "generation", _textFlow ? _textFlow.generation : -1, "lastGeneration", lastGeneration);

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
		if (textChanged || textFlowChanged || contentChanged)
			return;

		// In this case we always maintain _text with the underlying text and
		// display the appropriate number of passwordChars.  If there are any
		// interactive editing operations _text is updated during the operation.
		if (displayAsPassword)
			return;

		// Invalidate _text and _content.
		_text = null;
		_content = null;
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
	 *  @private
	 *  Called when the TextContainerManager dispatches a 'scroll' event
	 *  as it autoscrolls.
	 */
	private function textContainerManager_scrollHandler(event:Event):void
	{
		var oldHorizontalScrollPosition:Number = _horizontalScrollPosition;
		var newHorizontalScrollPosition:Number = _textContainerManager.horizontalScrollPosition;

		if (newHorizontalScrollPosition != oldHorizontalScrollPosition)
		{
			//trace("hsp scroll", oldHorizontalScrollPosition, "->", newHorizontalScrollPosition);

			_horizontalScrollPosition = newHorizontalScrollPosition;

			dispatchPropertyChangeEvent("horizontalScrollPosition", oldHorizontalScrollPosition, newHorizontalScrollPosition);
		}

		var oldVerticalScrollPosition:Number = _verticalScrollPosition;
		var newVerticalScrollPosition:Number = _textContainerManager.verticalScrollPosition;

		if (newVerticalScrollPosition != oldVerticalScrollPosition)
		{
			//trace("vsp scroll", oldVerticalScrollPosition, "->", newVerticalScrollPosition);

			_verticalScrollPosition = newVerticalScrollPosition;

			dispatchPropertyChangeEvent("verticalScrollPosition", oldVerticalScrollPosition, newVerticalScrollPosition);
		}
	}

	/**
	 *  @private
	 *  Called when the TextContainerManager dispatches a 'selectionChange' event.
	 */
	private function textContainerManager_selectionChangeHandler(event:SelectionEvent):void
	{
		var oldAnchor:int = _selectionAnchorPosition;
		var oldActive:int = _selectionActivePosition;

		var selectionState:SelectionState = event.selectionState;

		if (selectionState)
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
		var changed:Boolean = oldAnchor != _selectionAnchorPosition || oldActive != _selectionActivePosition;
		if (changed)
		{
			//trace("selectionChangeHandler", _selectionAnchorPosition, _selectionActivePosition);
			dispatchEvent(new FlexEvent(FlexEvent.SELECTION_CHANGE));
		}
	}

	/**
	 *  @private
	 *  Called when the TextContainerManager dispatches an 'operationBegin'
	 *  event before an editing operation.
	 */
	private function textContainerManager_flowOperationBeginHandler(event:FlowOperationEvent):void
	{
		//trace("flowOperationBegin", "level", event.level);

		var op:FlowOperation = event.operation;

		// The text flow's generation will be incremented if the text flow
		// is modified in any way by this operation.

		if (op is InsertTextOperation)
		{
			var insertTextOperation:InsertTextOperation = InsertTextOperation(op);

			var textToInsert:String = insertTextOperation.text;

			// Note: Must process restrict first, then maxChars,
			// then displayAsPassword last.

			if (_restrict != null)
			{
				textToInsert = StringUtil.restrict(textToInsert, restrict);
				if (textToInsert.length == 0)
				{
					event.preventDefault();
					return;
				}
			}

			// The text deleted by this operation.  If we're doing our
			// own manipulation of the textFlow we have to take the deleted
			// text into account as well as the inserted text.
			var delSelOp:SelectionState = insertTextOperation.deleteSelectionState;

			var delLen:int = (delSelOp == null) ? 0 : delSelOp.absoluteEnd - delSelOp.absoluteStart;

			if (maxChars != 0)
			{
				var length1:int = text.length - delLen;
				var length2:int = textToInsert.length;
				if (length1 + length2 > maxChars)
					textToInsert = textToInsert.substr(0, maxChars - length1);
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
		} else if (op is PasteOperation)
		{
			// Paste is implemented in operationEnd.  The basic idea is to allow
			// the paste to go through unchanged, but group it together with a
			// second operation that modifies text as part of the same
			// transaction. This is vastly simpler for TLF to manage.
		} else if (op is DeleteTextOperation || op is CutOperation)
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

		// Dispatch a 'changing' event from the RichEditableText
		// as notification that an editing operation is about to occur.
		// The level will be 0 for single operations, and at the start
		// of a composite operation.
		if (dispatchChangeAndChangingEvents && event.level == 0)
		{
			var newEvent:TextOperationEvent = new TextOperationEvent(TextOperationEvent.CHANGING);
			newEvent.operation = op;
			dispatchEvent(newEvent);

			// If the event dispatched from this RichEditableText is canceled,
			// cancel the one from the EditManager, which will prevent
			// the editing operation from being processed.
			if (newEvent.isDefaultPrevented())
				event.preventDefault();
		}
	}

	/**
	 *  @private
	 *  Called when the TextContainerManager dispatches an 'operationEnd' event
	 *  after an editing operation.
	 */
	private function textContainerManager_flowOperationEndHandler(event:FlowOperationEvent):void
	{
		//trace("flowOperationEnd", "level", event.level);

		// Paste is a special case.  Any mods have to be made to the text
		// which includes what was pasted.
		if (event.operation is PasteOperation)
			handlePasteOperation(PasteOperation(event.operation));
	}

	/**
	 *  @private
	 *  Called when the TextContainerManager dispatches an 'operationComplete'
	 *  event after an editing operation.
	 */
	private function textContainerManager_flowOperationCompleteHandler(event:FlowOperationEvent):void
	{
		//trace("flowOperationComplete", "level", event.level);

		// Dispatch a 'change' event from the RichEditableText
		// as notification that an editing operation has occurred.
		// The flow is now in a state that it can be manipulated.
		// The level will be 0 for single operations, and at the end
		// of a composite operation.
		if (dispatchChangeAndChangingEvents && event.level == 0)
		{
			var newEvent:TextOperationEvent = new TextOperationEvent(TextOperationEvent.CHANGE);
			newEvent.operation = event.operation;
			dispatchEvent(newEvent);
		}
	}

	/**
	 *  Called when a InlineGraphicElement is resized due to having width or
	 *  height as auto or percent and the graphic has finished loading.  The
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