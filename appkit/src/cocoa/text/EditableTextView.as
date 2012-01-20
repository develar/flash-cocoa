package cocoa.text {
import flash.display.Graphics;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.engine.ElementFormat;
import flash.text.engine.TextLine;
import flash.ui.Keyboard;

import flashx.textLayout.conversion.ConversionType;
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
import flashx.textLayout.formats.BaselineOffset;
import flashx.textLayout.formats.ITextLayoutFormat;
import flashx.textLayout.formats.LineBreak;
import flashx.textLayout.operations.CutOperation;
import flashx.textLayout.operations.DeleteTextOperation;
import flashx.textLayout.operations.FlowOperation;
import flashx.textLayout.operations.FlowTextOperation;
import flashx.textLayout.operations.InsertTextOperation;
import flashx.textLayout.operations.PasteOperation;
import flashx.textLayout.tlf_internal;
import flashx.undo.IUndoManager;

import mx.utils.StringUtil;

import spark.components.TextSelectionHighlighting;
import spark.events.TextOperationEvent;

use namespace tlf_internal;

public class EditableTextView extends AbstractTextView {
  private static const IGNORE_DAMAGE_EVENT:uint = 1 << 0;
  /**
   * If the selection was via the selectRange() or selectAll() api,
   * remember that until the next selection is set, either interactively or via the API.
   */
  private static const HAS_PROGRAMMATIC_SELECTION_RANGE:uint = 1 << 1;

   /**
   *  if this component sizes itself based on its actual contents
   */
  private static const AUTO_WIDTH:uint = 1 << 6;
  private static const AUTO_HEIGHT:uint = 1 << 7;

  private static const EDITABLE:uint = 1 << 2;

  /**
   * Regular expression which matches all newlines in the text. Used to strip newlines when pasting text when multiline is false.
   */
  private static const ALL_NEWLINES_REGEXP:RegExp = /\n/g;

  private static const DISPATCH_CHANGE_AND_CHANGING_EVENTS:uint = 1 << 3;
  /**
   * True if we've seen a MOUSE_DOWN event and haven't seen the corresponding MOUSE_UP event.
   */
  private static const MOUSE_DOWN:uint = 1 << 4;
  private static const ERROR_CAUGHT:uint = 1 << 5;

  private static const ENABLED_CHANGED:uint = 1 << 8;
  private static const EDITABLE_CHANGED:uint = 1 << 9;
  private static const SELECTABLE_CHANGED:uint = 1 << 10;

  protected var myFlags:uint = DISPATCH_CHANGE_AND_CHANGING_EVENTS | EDITABLE;

  /**
   *  Holds the last recorded value of the textFlow generation. Used to
   *  determine whether to return immediately from damage event if there
   *  have been no changes.
   */
  private var lastGeneration:uint = 0; // 0 means not set

  /**
   *  The generation of the text flow that last reported its content
   *  bounds.
   */
  private var lastContentBoundsGeneration:int = 0;  // 0 means not set

  private static const passwordChar:String = "*";

  internal var undoManager:IUndoManager;

  private var embeddedFontContext:SwfContext;

  protected var textContainerManager:EditableTextContainerManager;

  /**
   * The TLF edit manager will batch all inserted text until the next enter frame event.
   * This includes text inserted via the GUI as well as api calls to EditManager.insertText().
   * Set this to false if you want every keystroke to be inserted into the text immediately which will
   * result in a TextOperationEvent.CHANGE event for each character.
   * One place this is needed is for the type-ahead feature of the editable combo box.
   */
  public var batchTextInput:Boolean = true;

  public function EditableTextView() {
    super();

    flags |= HAS_BASELINE;

    textContainerManager = new EditableTextContainerManager(this, configuration);
    textContainerManager.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, compositionCompleteHandler);
    textContainerManager.addEventListener(DamageEvent.DAMAGE, damageHandler);
    textContainerManager.addEventListener(Event.SCROLL, scrollHandler);
    textContainerManager.addEventListener(SelectionEvent.SELECTION_CHANGE, selectionChangeHandler);
    textContainerManager.addEventListener(FlowOperationEvent.FLOW_OPERATION_BEGIN, flowOperationBeginHandler);
    textContainerManager.addEventListener(FlowOperationEvent.FLOW_OPERATION_END, flowOperationEndHandler);
    textContainerManager.addEventListener(FlowOperationEvent.FLOW_OPERATION_COMPLETE, flowOperationCompleteHandler);
    textContainerManager.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, inlineGraphicStatusChangeHandler);
  }

  override public function get text():String {
    if (_text == null) {
      _text = textContainerManager.getText();
    }
    return _text;
  }

  private static function splice(str:String, start:int, end:int, strToInsert:String):String {
    return str.substring(0, start) + strToInsert + str.substring(end, str.length);
  }

  protected function get heightInLines():int {
    return _uiModel is TextAreaUIModel ? TextAreaUIModel(_uiModel).heightInLines : 1;
  }

  protected var _uiModel:TextUIModel;
  public function set uiModel(value:TextUIModel):void {
    _uiModel = value;
  }

  public final function get multiline():Boolean {
    return _uiModel is TextAreaUIModel;
  }

  private function get displayAsPassword():Boolean {
    return _uiModel is TextInputUIModel && TextInputUIModel(_uiModel).displayAsPassword;
  }

  override protected function get scrollController():ScrollController {
    return textContainerManager;
  }

  override public function set textFormat(value:ITextLayoutFormat):void {
    super.textFormat = value;

    var cocoaTextFormat:SimpleTextLayoutFormat = _textFormat as SimpleTextLayoutFormat;
    embeddedFontContext = cocoaTextFormat != null ? cocoaTextFormat.textFormat.swfContext : null;
    textContainerManager.hostFormat = _textFormat;
    _charMetrics = null;
  }

  internal var _selectionFormat:SelectionFormat;
  public function set selectionFormat(value:SelectionFormat):void {
    assert(_selectionFormat == null);
    _selectionFormat = value;
  }

  override public function getBaseline(width:int, height:int):int {
    return effectiveTextFormat.paddingTop + charMetrics.ascent;
  }

  override public function set enabled(value:Boolean):void {
    if (value == super.enabled) {
      return;
    }

    super.enabled = value;
    flags |= ENABLED_CHANGED;

    invalidate();
  }

  /**
   *  A flag indicating whether the user is allowed to edit the text in this control.
   *
   *  <p>If <code>true</code>, the mouse cursor will change to an i-beam when over the bounds of this control.
   *  If <code>false</code>, the mouse cursor will remain an arrow.</p>
   *
   *  <p>If this property is <code>true</code>, the <code>selectable</code> property is ignored.</p>
   *
   *  @default true
   *
   *  @see #selectable
   */
  public function get editable():Boolean {
    return (myFlags & EDITABLE) != 0;
  }

  public function set editable(value:Boolean):void {
    if (value == ((myFlags & EDITABLE) == 0)) {
      value ? myFlags |= EDITABLE : myFlags &= ~EDITABLE;

      myFlags |= EDITABLE_CHANGED;
      invalidate();
    }
  }

  /**
   * The editingMode of this component's TextContainerManager.
   */
  private function get editingMode():String {
    // Note: this could be called before all properties are committed.
    commitForEditingMode();
    return textContainerManager.editingMode;
  }

  private function commitForEditingMode():void {
    if ((myFlags & ENABLED_CHANGED) != 0 || (myFlags & EDITABLE_CHANGED) != 0 || (myFlags & SELECTABLE_CHANGED) != 0) {
      updateEditingMode();

      myFlags &= ~ENABLED_CHANGED;
      myFlags &= ~EDITABLE_CHANGED;
      myFlags &= ~SELECTABLE_CHANGED;
    }
  }

  private function set editingMode(value:String):void {
    var lastEditingMode:String = textContainerManager.editingMode;
    if (lastEditingMode == value) {
      return;
    }

    textContainerManager.editingMode = value;

    // Make sure the selection manager selection is in sync with the current selection.
    if (value != EditingMode.READ_ONLY && _selectionAnchorPosition != -1 && _selectionActivePosition != -1) {
      textContainerManager.beginInteraction().selectRange(_selectionAnchorPosition, _selectionActivePosition);
      textContainerManager.endInteraction();
    }
  }

  public function set selectable(value:Boolean):void {
    if (value == _selectable) {
      return;
    }

    _selectable = value;
    myFlags |= SELECTABLE_CHANGED;

    invalidate();
  }

  private var _selectionActivePosition:int = -1;

  [Bindable("selectionChange")]
  /**
   *  A character position, relative to the beginning of the
   *  <code>text</code> String, specifying the end of the selection
   *  that moves when the selection is extended with the arrow keys.
   *
   *  <p>The active position may be either the start or the end of the selection.</p>
   *
   *  <p>For example, if you drag-select from position 12 to position 8, then <code>selectionAnchorPosition</code> will be 12
   *  and <code>selectionActivePosition</code> will be 8, and when you press Left-Arrow <code>selectionActivePosition</code> will become 7.</p>
   *
   *  <p>A value of -1 indicates "not set".</p>
   *
   *  @default -1
   *
   *  @see #selectionAnchorPosition
   */
  public function get selectionActivePosition():int {
    return _selectionActivePosition;
  }

  private var _selectionAnchorPosition:int = -1;

  [Bindable("selectionChange")]
  /**
   *  A character position, relative to the beginning of the <code>text</code> String, specifying the end of the selection
   *  that stays fixed when the selection is extended with the arrow keys.
   *
   *  <p>The anchor position may be either the start or the end of the selection.</p>
   *
   *  <p>For example, if you drag-select from position 12 to position 8, then <code>selectionAnchorPosition</code> will be 12
   *  and <code>selectionActivePosition</code> will be 8,
   *  and when you press Left-Arrow <code>selectionActivePosition</code> will become 7.</p>
   *
   *  <p>A value of -1 indicates "not set".</p>
   *
   *  @default -1
   *
   *  @see #selectionActivePosition
   */
  public function get selectionAnchorPosition():int {
    return _selectionAnchorPosition;
  }

  private var _selectionHighlighting:String = TextSelectionHighlighting.WHEN_FOCUSED;

  /**
   *  Determines when the text selection is highlighted.
   *
   *  <p>The allowed values are specified by the spark.components.TextSelectionHighlighting class.
   *  Possible values are <code>TextSelectionHighlighting.WHEN_FOCUSED</code>, <code>TextSelectionHighlighting.WHEN_ACTIVE</code>,
   *  and <code>TextSelectionHighlighting.ALWAYS</code>.</p>
   *
   *  <p><code>WHEN_FOCUSED</code> shows the text selection only when the component has keyboard focus.</p>
   *
   *  <p><code>WHEN_ACTIVE</code> shows the text selection whenever the component's window is active, even if the component
   *  doesn't have the keyboard focus.</p>
   *
   *  <p><code>ALWAYS</code> shows the text selection, even if the component doesn't have the keyboard focus
   *  or if the component's window isn't the active window.</p>
   *
   *  @default TextSelectionHighlighting.WHEN_FOCUSED
   *
   *  @see spark.components.TextSelectionHighlighting
   */
  public function get selectionHighlighting():String {
    return _selectionHighlighting;
  }

  public function set selectionHighlighting(value:String):void {
    if (value == _selectionHighlighting) {
      return;
    }

    _selectionHighlighting = value;

    //  мы пока что никак не используем это свойство
    //		invalidateProperties();
    //		invalidateDisplayList();
  }

  /**
   *  The TextFlow representing the rich text displayed by this component.
   *
   *  <p>Setting this property affects the <code>text</code> property and vice versa.</p>
   *
   *  <p>If the text contains explicit line breaks -- CR ("\r"), LF ("\n"), or CR+LF ("\r\n") --
   *  then the content will be set to a TextFlow which contains multiple paragraphs, each with one span.</p>
   *
   *  <p>Setting this property also affects the properties specifying the control's scroll position and the text selection.
   *  It resets the <code>horizontalScrollPosition</code> and <code>verticalScrollPosition</code> to 0,
   *  and it sets the <code>selectionAnchorPosition</code> and <code>selectionActivePosition</code>
   *  to -1 to clear the selection.</p>
   *
   *  <p>To turn a TextFlow object into TLF markup, use the <code>TextFlowUtil.export()</code> markup.</p>
   *
   *  <p>A single TextFlow cannot be shared by multiple instances of RichEditableText.
   *  To display the same text in a second instance, you must create a second TextFlow, either by using <code>TextFlowUtil.export()</code>
   *  and <code>TextFlowUtil.importFromXML()</code> or by using the <code>deepCopy()</code> method on TextFlow.</p>
   *
   *  @see spark.utils.TextFlowUtil.importFromString()
   *  @see spark.utils.TextFlowUtil.importFromXML()
   *  @see #text
   */
  override public function get textFlow():TextFlow {
    // Make sure the interactionManager is added to this textFlow.
    if (textChanged || textFlowChanged) {
      textContainerManager.setTextFlow(_textFlow);
      textChanged = textFlowChanged = false;
    }

    // If not read-only, make sure the textFlow has a composer in place so that it can be modified by the caller if desired.
    if (editingMode != EditingMode.READ_ONLY) {
      textContainerManager.beginInteraction();
      textContainerManager.endInteraction();
    }

    return _textFlow;
  }

  public function set textFlow(value:TextFlow):void {
    if (value == null) {
      text = "";
      return;
    }

    if (value == _textFlow) {
      return;
    }

    _textFlow = value;
    textFlowChanged = true;

    // Of 'text', 'textFlow' the last one set wins.
    textChanged = false;

    // The other two are now invalid and must be recalculated when needed.
    _text = null;
    sourceIsText = false;

    invalidate(true);

    //if (hasEventListener(FlexEvent.VALUE_COMMIT)) {
    //  dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    //}
  }

  private var _charMetrics:CharMetrics;
  protected function get charMetrics():CharMetrics {
    if (_charMetrics == null) {
      calculateFontMetrics();
    }
    return _charMetrics;
  }

  protected function commitProperties():void {
    // EditingMode needs to be current before attempting to set a selection below.
    commitForEditingMode();

    if (textChanged || textFlowChanged) {
      lastGeneration = _textFlow != null ? _textFlow.generation : 0;
      lastContentBoundsGeneration = 0;

      if (textFlowChanged) {
        textContainerManager.setTextFlow(_textFlow);

        textFlowChanged = false;
      }
      if (textChanged ) {
        if (displayAsPassword) {
          _text = text;
          textContainerManager.setText(StringUtil.repeat(passwordChar, _text.length));
        }
        else {
          textContainerManager.setText(_text);
        }

        textChanged = false;
      }
    }
  }

  override public function getPreferredWidth(hHint:int = -1):int {
    measure();
    return measuredWidth;
  }


  override public function getPreferredHeight(wHint:int = -1):int {
    measure();
    return measuredHeight;
  }

  private var measuredWidth:Number;
  private var measuredHeight:Number;

  private function measure():void {
    // don't want to trigger a another remeasure when we modify the textContainerManager or compose the text.
    myFlags |= IGNORE_DAMAGE_EVENT;

    myFlags &= ~AUTO_HEIGHT;
    myFlags &= ~AUTO_WIDTH;

    var composeWidth:Number = constraints == null ? NaN : constraints.horizontal.size.preferred.getValue();
    if (isNaN(composeWidth) && _uiModel.widthInChars != -1) {
      if (measuredWidth == 0) {
        measuredWidth = Math.ceil(calculateWidthInChars());
        //adjustMeasuredWidthToRange();
      }
      composeWidth = measuredWidth;
    }

    var composeHeight:Number = constraints == null ? NaN : constraints.vertical.size.preferred.getValue();
    if (isNaN(composeHeight) && heightInLines != -1) {
      if (measuredHeight == 0) {
        measuredHeight = Math.ceil(calculateHeightInLines());
        //adjustMeasuredHeightToRange();
      }
      composeHeight = measuredHeight;
    }

    if (!isNaN(composeWidth) && !isNaN(composeHeight)) {
      // skip
    }
    else {
     var bounds:Rectangle;
      if (!isNaN(composeWidth)) {
        bounds = measureTextSize(composeWidth, NaN);
        measuredHeight = Math.ceil(bounds.bottom);
        //if (adjustMeasuredHeightToRange() != MeasurementAdjustResult.MAX) {
          myFlags |= AUTO_HEIGHT;
        //}
      }
      else if (!isNaN(composeHeight)) {
        bounds = measureTextSize(NaN, composeHeight);
        measuredWidth = Math.ceil(bounds.right);
        //if (adjustMeasuredWidthToRange() != MeasurementAdjustResult.MAX) {
          myFlags |= AUTO_WIDTH;
        //}
      }
      else {
        myFlags |= AUTO_HEIGHT;
        myFlags |= AUTO_WIDTH;
        bounds = measureTextSize(NaN, NaN);
        measuredWidth = Math.ceil(bounds.right);
        measuredHeight = Math.ceil(bounds.bottom);
      }
    }

    // make sure we weren't previously scrolled.
//    if ((flags & AUTO_SIZE) != 0) {
//      textContainerManager.horizontalScrollPosition = 0;
//      textContainerManager.verticalScrollPosition = 0;
//    }

    myFlags &= ~IGNORE_DAMAGE_EVENT;
  }

  override protected function draw(w:int, h:int):void {
    commitProperties();

    textContainerManager.compositionWidth = (myFlags & AUTO_WIDTH) ? (w < measuredWidth ? w : NaN) : w;
    textContainerManager.compositionHeight = (myFlags & AUTO_HEIGHT) ? (h < measuredHeight ? h : NaN) : h;

    textContainerManager.updateContainer();
  }

  /**
   * Inserts the specified text as if you had typed it.
   *
   *  <p>If a range was selected, the new text replaces the selected text.
   *  If there was an insertion point, the new text is inserted there.</p>
   *
   *  <p>An insertion point is then set after the new text.
   *  If necessary, the text will scroll to ensure that the insertion point is visible.</p>
   *
   *  @param text The text to be inserted.
   */
  public function insertText(text:String):void {
    handleInsertText(text);
  }

  /**
   *  Appends the specified text to the end, as if you had clicked at the end and typed.
   *
   *  <p>An insertion point is then set after the new text.
   *  If necessary, the text will scroll to ensure that the insertion point is visible.</p>
   *
   *  @param text The text to be appended.
   */
  public function appendText(text:String):void {
    handleInsertText(text, true);
  }

  /**
   *  @copy flashx.textLayout.container.ContainerController#scrollToRange()
   */
  public function scrollToRange(anchorPosition:int, activePosition:int):void {
    // Make sure the properties are commited since the text could change.
    //validateProperties();

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
   */
  public function selectRange(anchorPosition:int, activePosition:int):void {
    // Make sure the properties are commited since the text could change.
    //validateProperties();

    if (editingMode == EditingMode.READ_ONLY) {
      selectionChangeHandler(new SelectionEvent(SelectionEvent.SELECTION_CHANGE, false, false, new SelectionState(_textFlow, anchorPosition, activePosition)));
    }
    else {
      var im:ISelectionManager = textContainerManager.beginInteraction();
      im.selectRange(anchorPosition, activePosition);
      im.refreshSelection();
      textContainerManager.endInteraction();
    }

    // Remember if the current selection is a range which was set programatically.
    (anchorPosition != activePosition) ? myFlags |= HAS_PROGRAMMATIC_SELECTION_RANGE : myFlags &= ~HAS_PROGRAMMATIC_SELECTION_RANGE;
  }

  /**
   *  Selects all of the text.
   */
  public function selectAll():void {
    selectRange(0, int.MAX_VALUE);
  }

  /**
   * Returns the bounds of the measured text. The initial composeWidth may be adjusted for minWidth or maxWidth.
   * The value used for the compose is in _textContainerManager.compositionWidth.
   */
  private function measureTextSize(composeWidth:Number, composeHeight:Number):Rectangle {
    textContainerManager.compositionWidth = composeWidth;
    textContainerManager.compositionHeight = composeHeight;

    // Compose only.  The display should not be updated.
    textContainerManager.compose();
    // Adjust width and height for text alignment.
    return textContainerManager.getContentBounds();
  }

  private function calculateFontMetrics():void {
    var textFormat:TextFormat = SimpleTextLayoutFormat(_textFormat).textFormat;
    if (textFormat.charMetrics == null) {
      textFormat.charMetrics = new CharMetrics(measureText("m", textFormat.format));
    }
    _charMetrics = textFormat.charMetrics;
  }

  public function measureText(text:String, elementFormat:ElementFormat = null):TextLine {
    return TextLines.measureText(text, elementFormat == null ? SimpleTextLayoutFormat(_textFormat).textFormat.format : elementFormat, embeddedFontContext);
  }

  private function calculateWidthInChars():Number {
    return int(effectiveTextFormat.paddingLeft) + (_uiModel.widthInChars * charMetrics.width) + int(effectiveTextFormat.paddingRight);
  }

  /**
   *  Calculates the height needed for heightInLines lines using the default font.
   */
  private function calculateHeightInLines():Number {
    var charMetrics:CharMetrics = this.charMetrics;
    const lineHeight:Number = TextLines.calculateLineHeight(effectiveTextFormat.lineHeight, charMetrics.height);
    const firstBaselineOffset:Object = effectiveTextFormat.firstBaselineOffset;
    var height:Number = int(effectiveTextFormat.paddingTop) + int(effectiveTextFormat.paddingBottom) + ((heightInLines - 1) * lineHeight) + charMetrics.descent /* add in descent of last line */;
    if (firstBaselineOffset == BaselineOffset.LINE_HEIGHT) {
      height += lineHeight;
    }
    else {
      height += firstBaselineOffset is Number ? Number(firstBaselineOffset) : charMetrics.ascent;
    }
    return height;
  }

  private function updateEditingMode():void {
    var newEditingMode:String = EditingMode.READ_ONLY;
    if (enabled) {
      if ((myFlags & EDITABLE) != 0) {
        newEditingMode = EditingMode.READ_WRITE;
      }
      else if (_selectable) {
        newEditingMode = EditingMode.READ_SELECT;
      }
    }

    editingMode = newEditingMode;
  }

  /**
   *  This is used when text is either inserted or appended via the API.
   */
  private function handleInsertText(newText:String, isAppend:Boolean = false):void {
    // Make sure all properties are committed.  The damage handler for the
    // insert will cause the remeasure and display update.
    //validateProperties();

    if (isAppend) {
      // Set insertion pt to the end of the current text.
      _selectionAnchorPosition = text.length;
      _selectionActivePosition = _selectionAnchorPosition;
    }
    // Insert requires a selection, or it is a noop.
    else if (_selectionAnchorPosition == -1 || _selectionActivePosition == -1) {
      return;
    }

    // This will update the selection after the operation is done.
    if (textContainerManager.insertTextOperation(newText, _selectionAnchorPosition, _selectionActivePosition)) {
      //dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }
  }

  private function handlePasteOperation(op:PasteOperation):void {
    var hasConstraints:Boolean = _uiModel.restrict != null || _uiModel.maxChars > 0 || displayAsPassword;
    // If there are no constraints and multiline text is allowed there is nothing that needs to be done.
    if (!hasConstraints && multiline) {
      return;
    }

    // If copied/cut from displayAsPassword field the pastedText is '*' characters but this is correct.
    //var pastedText:String = TextConverter.getExporter(TextConverter.PLAIN_TEXT_FORMAT).export(op.textScrap.textFlow, ConversionType.STRING_TYPE) as String;
    // http://youtrack.jetbrains.net/issue/AS-406
    var pastedText:String = TextConverter.getExporter(TextConverter.PLAIN_TEXT_FORMAT)["export"](op.textScrap.textFlow, ConversionType.STRING_TYPE) as String;
    // If there are no constraints and no newlines there is nothing more to do.
    if (!hasConstraints && pastedText.indexOf("\n") == -1) {
      return;
    }

    // Save this in case we modify the pasted text.  We need to know how much text to delete.
    var textLength:int = pastedText.length;

    // If multiline is false, strip newlines out of pasted text
    // This will not strip newlines out of displayAsPassword fields
    // since the text is the passwordChar and newline won't be found.
    if (!multiline) {
      pastedText = pastedText.replace(ALL_NEWLINES_REGEXP, "");
    }

    // We know it's an EditManager or we wouldn't have gotten here.
    var editManager:IEditManager = IEditManager(textContainerManager.beginInteraction());

    // Generate a CHANGING event for the PasteOperation but not for the
    // DeleteTextOperation or the InsertTextOperation which are also part of the paste.
    myFlags &= ~DISPATCH_CHANGE_AND_CHANGING_EVENTS;

    var selectionState:SelectionState = new SelectionState(op.textFlow, op.absoluteStart, op.absoluteStart + textLength);
    editManager.deleteText(selectionState);

    // Insert the same text, the same place where the paste was done.
    // This will go thru the InsertPasteOperation and do the right things with restrict, maxChars and displayAsPassword.
    selectionState = new SelectionState(op.textFlow, op.absoluteStart, op.absoluteStart);
    editManager.insertText(pastedText, selectionState);

    // All done with the edit manager.
    textContainerManager.endInteraction();

    myFlags |= DISPATCH_CHANGE_AND_CHANGING_EVENTS;
  }

  internal function focusInHandler(event:FocusEvent):void {
    //trace("focusIn handler");

    //var fm:IFocusManager = focusManager;
    //if (fm != null && editingMode == EditingMode.READ_WRITE) {
    //  fm.showFocusIndicator = true;
    //}

    // showFocusIndicator must be set before this is called.
    //super.focusInHandler(event);

    if (editingMode == EditingMode.READ_WRITE) {
      // If the focusIn was because of a mouseDown event, let TLF
      // handle the selection.  Otherwise it was because we tabbed in
      // or we programatically set the focus.
      if ((myFlags & MOUSE_DOWN) == 0) {
        var selectionManager:ISelectionManager = textContainerManager.beginInteraction();

        if (multiline) {
          if (!selectionManager.hasSelection()) {
            selectionManager.selectRange(0, 0);
          }
        }
        else if ((myFlags & HAS_PROGRAMMATIC_SELECTION_RANGE) == 0) {
          selectionManager.selectAll();
        }

        selectionManager.refreshSelection();

        textContainerManager.endInteraction();
      }
    }

    //if (focusManager != null && multiline) {
    //  focusManager.defaultButtonEnabled = false;
    //}
  }

  /**
   *  RichEditableTextContainerManager overrides focusOutHandler and calls
   *  this before executing its own focusOutHandler.
   */
  internal function focusOutHandler(event:FocusEvent):void {
    //trace("focusOut handler");

    //super.focusOutHandler(event);

    // By default, we clear the undo history when a RichEditableText loses focus.
    var clearUndoOnFocusOut:Boolean = true;
    if (clearUndoOnFocusOut && undoManager) {
      undoManager.clearAll();
    }

    //if (focusManager != null) {
    //  focusManager.defaultButtonEnabled = true;
    //}

    //dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
  }

  internal function keyDownHandler(event:KeyboardEvent):void {
    if (editingMode != EditingMode.READ_WRITE)
      return;

    // We always handle the 'enter' key since we would have to recreate
    // the container manager to change the configuration if multiline changes.
    if (event.keyCode == Keyboard.ENTER) {
      if (!multiline) {
        //dispatchEvent(new FlexEvent(FlexEvent.ENTER));
        event.preventDefault();
        return;
      }

      // Multiline.  Make sure there is room before acting on it.
      if (_uiModel.maxChars != 0 && text.length >= _uiModel.maxChars) {
        event.preventDefault();
        return;
      }

      var editManager:IEditManager = EditManager(textContainerManager.beginInteraction());

      if (editManager.hasSelection())
        editManager.splitParagraph();

      textContainerManager.endInteraction();

      event.preventDefault();
    }
  }

  internal function mouseDownHandler(event:MouseEvent):void {
    myFlags |= MOUSE_DOWN;

    // Need to get called even if mouse events are dispatched outside of this component. For example, when the user does
    // a mouse down in RET, drags the mouse outside of the component, and then releases the mouse.
    stage.addEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true /*useCapture*/);
  }

  private function systemManager_mouseUpHandler(event:MouseEvent):void {
    myFlags &= ~MOUSE_DOWN;

    stage.removeEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true /*useCapture*/);
  }

  /**
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
   *     if width is reduced the height should grow or stay the same
   *     if height is reduced the width should grow or stay the same
   *     if width and height are reduced then either the width or height
   *       should grow or stay the same.
   *
   *  toFit
   *    width     height
   *    smaller   smaller   height pinned to old height
   *    smaller   larger    ok
   *    larger    larger    ok
   *    larger    smaller   ok
   *
   *  explicit
   *    width     height
   *    smaller   smaller   width pinned to old width
   *    smaller   larger    width pinned to old width
   *    larger    larger    ok
   *    larger    smaller   ok
   */
  private function adjustContentBoundsForScroller(bounds:Rectangle):void {
    // Already reported bounds at least once for this generation of
    // the text flow so we have to be careful to mantain consistency for the scroller.
    if (_textFlow.generation == lastContentBoundsGeneration) {
      if (bounds.width < _contentWidth) {
        if (effectiveTextFormat.lineBreak == LineBreak.TO_FIT) {
          if (bounds.height < _contentHeight) {
            bounds.height = _contentHeight;
          }
        }
        else {
          // The width may get smaller if the compose height is reduced and fewer lines are composed.
          // Use the old content width which is more accurate.
          bounds.width = _contentWidth;
        }
      }
    }

    lastContentBoundsGeneration = _textFlow.generation;
  }

  /**
   *  Called when the TextContainerManager dispatches a 'compositionComplete' event when it has recomposed the text into TextLines.
   */
  private function compositionCompleteHandler(event:CompositionCompleteEvent):void {
    var oldContentWidth:Number = _contentWidth;
    var oldContentHeight:Number = _contentHeight;
    var newContentBounds:Rectangle = textContainerManager.getContentBounds();

    // Try to prevent the scroller from getting into a loop while adding/removing scroll bars.
    if (_textFlow != null && clipAndEnableScrolling) {
      adjustContentBoundsForScroller(newContentBounds);
    }

    var newContentWidth:Number = newContentBounds.width;
    var newContentHeight:Number = newContentBounds.height;
    if (newContentWidth != oldContentWidth) {
      _contentWidth = newContentWidth;
      // If there is a scroller, this triggers the scroller layout.
      //dispatchPropertyChangeEvent("contentWidth", oldContentWidth, newContentWidth);
    }

    if (newContentHeight != oldContentHeight) {
      _contentHeight = newContentHeight;
      // If there is a scroller, this triggers the scroller layout.
      //dispatchPropertyChangeEvent("contentHeight", oldContentHeight, newContentHeight);
    }
  }

  /**
   *  Called when the TextContainerManager dispatches a 'damage' event.
   *  The TextFlow could have been modified interactively or programatically.
   */
  private function damageHandler(event:DamageEvent):void {
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

    // If no changes, don't recompose/update. The TextFlowFactory createTextLines dispatches damage events
    // every time the textFlow is composed, even if there are no changes.
    // If there are pending changes, don't wipe them out. We have not gotten to commitProperties() yet.
    if ((myFlags & IGNORE_DAMAGE_EVENT) != 0 || event.damageLength == 0 || (_textFlow != null && _textFlow.generation == lastGeneration) || textChanged || textFlowChanged) {
      return;
    }

    // In this case we always maintain _text with the underlying text and display the appropriate number of passwordChars.
    // If there are any interactive editing operations _text is updated during the operation.
    if (displayAsPassword) {
      return;
    }

    if (sourceIsText) {
      _text = null;
      if (_textFlow == null) {
        _textFlow = textContainerManager.getTextFlow();
      }
    }

    lastGeneration = _textFlow.generation;
    // If the textFlow content is modified directly or if there is a style
    // change by changing the textFlow directly the size could change.
    invalidate(true);
  }

  /**
   * Called when the TextContainerManager dispatches a 'scroll' event as it autoscrolls.
   */
  private function scrollHandler(event:Event):void {
    var oldHorizontalScrollPosition:Number = _horizontalScrollPosition;
    var newHorizontalScrollPosition:Number = textContainerManager.horizontalScrollPosition;

    if (newHorizontalScrollPosition != oldHorizontalScrollPosition) {
      _horizontalScrollPosition = newHorizontalScrollPosition;
      //dispatchPropertyChangeEvent("horizontalScrollPosition", oldHorizontalScrollPosition, newHorizontalScrollPosition);
    }

    var oldVerticalScrollPosition:Number = _verticalScrollPosition;
    var newVerticalScrollPosition:Number = textContainerManager.verticalScrollPosition;
    if (newVerticalScrollPosition != oldVerticalScrollPosition) {
      _verticalScrollPosition = newVerticalScrollPosition;
      //dispatchPropertyChangeEvent("verticalScrollPosition", oldVerticalScrollPosition, newVerticalScrollPosition);
    }
  }

  /**
   *  Called when the TextContainerManager dispatches a 'selectionChange' event.
   */
  private function selectionChangeHandler(event:SelectionEvent):void {
    var oldAnchor:int = _selectionAnchorPosition;
    var oldActive:int = _selectionActivePosition;

    var selectionState:SelectionState = event.selectionState;
    if (selectionState != null) {
      _selectionAnchorPosition = selectionState.anchorPosition;
      _selectionActivePosition = selectionState.activePosition;
    }
    else {
      _selectionAnchorPosition = -1;
      _selectionActivePosition = -1;
    }

    // Selection changed so reset.
    myFlags |= HAS_PROGRAMMATIC_SELECTION_RANGE;

    // Only dispatch the event if the selection has really changed.
    if (oldAnchor != _selectionAnchorPosition || oldActive != _selectionActivePosition) {
      //dispatchEvent(new FlexEvent(FlexEvent.SELECTION_CHANGE));
    }
  }

  /**
   *  Called when the TextContainerManager dispatches an 'operationBegin' event before an editing operation.
   */
  private function flowOperationBeginHandler(event:FlowOperationEvent):void {
    var op:FlowOperation = event.operation;

    // The text flow's generation will be incremented if the text flow is modified in any way by this operation.
    if (op is InsertTextOperation) {
      var insertTextOperation:InsertTextOperation = InsertTextOperation(op);
      var textToInsert:String = insertTextOperation.text;
      // Note: Must process restrict first, then maxChars, then displayAsPassword last.
      if (_uiModel.restrict != null) {
        textToInsert = StringUtil.restrict(textToInsert, _uiModel.restrict);
        if (textToInsert.length == 0) {
          event.preventDefault();
          return;
        }
      }

      // The text deleted by this operation. If we're doing our own manipulation of the textFlow we have to take the deleted
      // text into account as well as the inserted text.
      var delSelOp:SelectionState = insertTextOperation.deleteSelectionState;
      var delLen:int = (delSelOp == null) ? 0 : delSelOp.absoluteEnd - delSelOp.absoluteStart;

      if (_uiModel.maxChars != 0) {
        var length1:int = text.length - delLen;
        var length2:int = textToInsert.length;
        if (length1 + length2 > _uiModel.maxChars) {
          textToInsert = textToInsert.substr(0, _uiModel.maxChars - length1);
        }
      }

      if (_uiModel is TextInputUIModel && TextInputUIModel(_uiModel).displayAsPassword) {
        // Remove deleted text.
        if (delLen > 0) {
          _text = splice(_text, delSelOp.absoluteStart, delSelOp.absoluteEnd, "");
        }

        // Add in the inserted text.
        _text = splice(_text, insertTextOperation.absoluteStart, insertTextOperation.absoluteEnd, textToInsert);

        // Display the passwordChar rather than the actual text.
        textToInsert = StringUtil.repeat(passwordChar, textToInsert.length);
      }

      insertTextOperation.text = textToInsert;
    }
    else if (op is PasteOperation) {
      // Paste is implemented in operationEnd.  The basic idea is to allow
      // the paste to go through unchanged, but group it together with a
      // second operation that modifies text as part of the same
      // transaction. This is vastly simpler for TLF to manage.
    }
    else if (op is DeleteTextOperation || op is CutOperation) {
      var flowTextOperation:FlowTextOperation = FlowTextOperation(op);

      // Eat 0-length deletion.  This can happen when insertion point is
      // at start of container when a backspace is entered
      // or when the insertion point is at the end of the
      // container and a delete key is entered.
      if (flowTextOperation.absoluteStart == flowTextOperation.absoluteEnd) {
        event.preventDefault();
        return;
      }

      if (displayAsPassword) {
        _text = splice(_text, flowTextOperation.absoluteStart, flowTextOperation.absoluteEnd, "");
      }
    }

    // Dispatch a 'changing' event from the RichEditableText as notification that an editing operation is about to occur.
    // The level will be 0 for single operations, and at the start of a composite operation.
    if ((myFlags & DISPATCH_CHANGE_AND_CHANGING_EVENTS) != 0 && event.level == 0) {
      var newEvent:TextOperationEvent = new TextOperationEvent(TextOperationEvent.CHANGING, false, true, op);
      dispatchEvent(newEvent);

      // If the event dispatched from this RichEditableText is canceled,
      // cancel the one from the EditManager, which will prevent the editing operation from being processed.
      if (newEvent.isDefaultPrevented()) {
        event.preventDefault();
      }
    }
  }

  private function flowOperationEndHandler(event:FlowOperationEvent):void {
    // Paste is a special case.  Any mods have to be made to the text which includes what was pasted.
    if (event.operation is PasteOperation) {
      handlePasteOperation(PasteOperation(event.operation));
    }
  }

  private function flowOperationCompleteHandler(event:FlowOperationEvent):void {
    // Dispatch a 'change' event from the this as notification that an editing operation has occurred.
    // The flow is now in a state that it can be manipulated.
    // The level will be 0 for single operations, and at the end of a composite operation.
    if ((myFlags & DISPATCH_CHANGE_AND_CHANGING_EVENTS) != 0 && event.level == 0) {
      dispatchEvent(new TextOperationEvent(TextOperationEvent.CHANGE, false, true, event.operation));
    }
  }

  /**
   *  Called when a InlineGraphicElement is resized due to having width or
   *  height as auto or percent and the graphic has finished loading. The size of the graphic is now known.
   */
  private function inlineGraphicStatusChangeHandler(event:StatusChangeEvent):void {
    if (event.status == InlineGraphicElementStatus.SIZE_PENDING && event.element is InlineGraphicElement) {
      // Force InlineGraphicElement.applyDelayedElementUpdate to execute and finish loading the graphic.
      // This is a workaround for the case when the image is in a compiled text flow.
      InlineGraphicElement(event.element).updateForMustUseComposer(textContainerManager.getTextFlow());
    }
    else if (event.status == InlineGraphicElementStatus.READY) {
      // Now that the actual size of the graphic is available need to optionally remeasure and updateContainer.
      if ((myFlags & AUTO_WIDTH) != 0 || (myFlags & AUTO_HEIGHT) != 0) {
        invalidate(true);
      }
      else {
        invalidate();
      }
    }
  }
}
}