package cocoa {
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.text.EditableTextView;
import cocoa.text.TextUIModel;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;

import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.Spinner;

use namespace mx_internal;
use namespace ui;

public class NumericStepper extends Spinner implements UIPartController {
  private var textUIModel:TextUIModel;

  public function NumericStepper() {
    super();

    maximum = 10;
  }

  [SkinPart(required="true")]
  public var textDisplay:TextInput;

  private var maxChanged:Boolean = false;

  /**
   *  Number which represents the maximum value possible for
   *  <code>value</code>. If the values for either
   *  <code>minimum</code> or <code>value</code> are greater
   *  than <code>maximum</code>, they will be changed to
   *  reflect the new <code>maximum</code>
   *
   *  @default 10
   */
  override public function set maximum(value:Number):void {
    maxChanged = true;
    super.maximum = value;
  }

  private var stepSizeChanged:Boolean = false;

  override public function set stepSize(value:Number):void {
    stepSizeChanged = true;
    super.stepSize = value;
  }

  private var _valueFormatFunction:Function;
  private var valueFormatFunctionChanged:Boolean;

  /**
   *  Callback function that formats the value displayed
   *  in the skin's <code>textDisplay</code> property.
   *  The function takes a single Number as an argument
   *  and returns a formatted String.
   *
   *  <p>The function has the following signature:</p>
   *  <pre>
   *  funcName(value:Number):String
   *  </pre>

   *  @default undefined
   */
  public function get valueFormatFunction():Function {
    return _valueFormatFunction;
  }

  public function set valueFormatFunction(value:Function):void {
    _valueFormatFunction = value;
    valueFormatFunctionChanged = true;
    invalidateProperties();
  }

  private var _valueParseFunction:Function;
  private var valueParseFunctionChanged:Boolean;

  /**
   *  Callback function that extracts the numeric
   *  value from the displayed value in the
   *  skin's <code>textDisplay</code> field.
   *
   *  The function takes a single String as an argument
   *  and returns a Number.
   *
   *  <p>The function has the following signature:</p>
   *  <pre>
   *  funcName(value:String):Number
   *  </pre>

   *  @default undefined
   */
  public function get valueParseFunction():Function {
    return _valueParseFunction;
  }

  public function set valueParseFunction(value:Function):void {
    _valueParseFunction = value;
    valueParseFunctionChanged = true;
    invalidateProperties();
  }

  private var _imeMode:String = null;
  private var imeModeChanged:Boolean = false;

  /**
   *  Specifies the IME (Input Method Editor) mode.
   *  The IME enables users to enter text in Chinese, Japanese, and Korean.
   *  Flex sets the specified IME mode when the control gets the focus
   *  and sets it back to previous value when the control loses the focus.
   *
   * <p>The flash.system.IMEConversionMode class defines constants for the
   *  valid values for this property.
   *  You can also specify <code>null</code> to specify no IME.</p>
   *
   *  @see flash.system.IMEConversionMode
   *
   *  @default null
   */
  public function get imeMode():String {
    return _imeMode;
  }

  public function set imeMode(value:String):void {
    _imeMode = value;
    imeModeChanged = true;
    invalidateProperties();
  }

  override protected function commitProperties():void {
    super.commitProperties();

    if (maxChanged || stepSizeChanged || valueFormatFunctionChanged) {
      adjustTextWidthAndMaxChars();

      maxChanged = false;
      stepSizeChanged = false;

      if (valueFormatFunctionChanged) {
        applyDisplayFormatFunction();

        valueFormatFunctionChanged = false;
      }
    }

    if (valueParseFunctionChanged) {
      commitTextInput(false);
      valueParseFunctionChanged = false;
    }

    if (imeModeChanged) {
      textDisplay.textDisplay.imeMode = _imeMode;
      imeModeChanged = false;
    }
  }

  override protected function partAdded(partName:String, instance:Object):void {
    super.partAdded(partName, instance);

    if (instance == textDisplay) {
      var editableText:EditableTextView = textDisplay.textDisplay;
      editableText.addEventListener(FlexEvent.ENTER, textDisplay_enterHandler);
      editableText.addEventListener(FocusEvent.FOCUS_OUT, textDisplay_focusOutHandler);

      if (textUIModel == null) {
        textUIModel = new TextUIModel();
        textUIModel.restrict = "0-9\\-\\.\\,";
      }
      // Restrict to digits, minus sign, decimal point, and comma
      textDisplay.uiModel = textUIModel;
      textDisplay.text = value.toString();
    }
  }

  override public function setFocus():void {
    if (stage) {
      stage.focus = textDisplay.textDisplay;

      // Since the API ignores the visual editable and selectable
      // properties make sure the selection should be set first.
      if (textDisplay.textDisplay && (textDisplay.textDisplay.editable || textDisplay.textDisplay.selectable)) {
        textDisplay.textDisplay.selectAll();
      }
    }
  }

  override protected function isOurFocus(target:DisplayObject):Boolean {
    return target == textDisplay.textDisplay;
  }

  override protected function setValue(newValue:Number):void {
    super.setValue(newValue);

    applyDisplayFormatFunction();
  }

  /**
   *  Calls commitTextInput() before stepping.
   */
  override public function changeValueByStep(increase:Boolean = true):void {
    commitTextInput();

    super.changeValueByStep(increase);
  }

  /**
   *  @private
   *  Commits the current text of <code>textDisplay</code>
   *  to the <code>value</code> property.
   *  This method uses the <code>nearestValidValue()</code> method
   *  to round the input value to the closest valid value.
   *  Valid values are defined by the sum of the minimum
   *  with integer multiples of the snapInterval. It is also
   *  constrained by and includes the <code>maximum</code> property.
   */
  private function commitTextInput(dispatchChange:Boolean = false):void {
    var inputValue:Number = valueParseFunction != null ? valueParseFunction(textDisplay.text) : Number(textDisplay.text);
    var prevValue:Number = value;

    if ((textDisplay.text && textDisplay.text.length != value.toString().length) || textDisplay.text == "" || (inputValue != value && (Math.abs(inputValue - value) >= 0.000001 || isNaN(inputValue)))) {
      setValue(nearestValidValue(inputValue, snapInterval));

      // Dispatch valueCommit if the display needs to change.
      if (value == prevValue && inputValue != prevValue) {
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
      }
    }

    if (dispatchChange && value != prevValue) {
      dispatchEvent(new Event(Event.CHANGE));
    }
  }

  private function applyDisplayFormatFunction():void {
    textDisplay.text = valueFormatFunction == null ? value.toString() : valueFormatFunction(value);
  }

  override protected function focusInHandler(event:FocusEvent):void {
    super.focusInHandler(event);

    addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
  }

  override protected function focusOutHandler(event:FocusEvent):void {
    super.focusOutHandler(event);

    removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
  }

  /**
   *  @private
   *  When the enter key is pressed, NumericStepper commits the
   *  text currently displayed.
   */
  private function textDisplay_enterHandler(event:Event):void {
    commitTextInput(true);
  }

  /**
   *  @private
   *  When the enter key is pressed, NumericStepper commits the
   *  text currently displayed.
   */
  private function textDisplay_focusOutHandler(event:Event):void {
    commitTextInput(true);
  }

  override public function set enabled(value:Boolean):void {
    super.enabled = value;
    if (skin != null) {
      skin.enabled = value;
    }
  }

  override public function drawFocus(isFocused:Boolean):void {
    // skip
  }

  private function calculateWidestText():String {
    var widestNumber:Number = minimum.toString().length > maximum.toString().length ? minimum : maximum;
    var widestText:String;
    if (widestNumber < 0) {
      widestText = "-" + (StringUtil.repeat("9", widestNumber.toString().length - 1));
    }
    else {
      widestText = StringUtil.repeat("9", widestNumber.toString().length);
    }

    return valueFormatFunction == null ? widestText : valueFormatFunction(Number(widestText));
  }

  private function adjustTextWidthAndMaxChars():void {
    var widestText:String = calculateWidestText();
    textUIModel.maxChars = widestText.length;

    if (isNaN(explicitWidth)) {
      textDisplay.textDisplay.width = Math.ceil(textDisplay.textDisplay.measureText(widestText).width);
    }
  }

  override protected function nearestValidValue(value:Number, interval:Number):Number {
    if (interval == 0) {
      return Math.max(minimum, Math.min(maximum, value));
    }

    var minValue:Number = minimum;
    var maxValue:Number = maximum;
    var scale:Number = 1;

    // If interval isn't an integer, there's a possibility that the floating point
    // approximation of value or value/interval will be slightly larger or smaller
    // than the real value.  This can lead to errors in calculations like
    // floor(value/interval)*interval, which one might expect to just equal value,
    // when value is an exact multiple of interval.  Not so if value=0.58 and
    // interval=0.01, in that case the calculation yields 0.57!  To avoid problems,
    // we scale by the implicit precision of the interval and then round.  For
    // example if interval=0.01, then we scale by 100.

    if (interval != int(interval)) {
      const s:String = String(1 + interval);
      scale = Math.pow(10, s.length - s.indexOf(".") - 1);
      minValue *= scale;
      maxValue *= scale;
      value = Math.round(value * scale);
      interval = Math.round(interval * scale);
    }

    var lower:Number = Math.max(minValue, Math.floor(value / interval) * interval);
    var upper:Number = Math.min(maxValue, Math.floor((value + interval) / interval) * interval);
    return (((value - lower) >= ((upper - lower) / 2)) ? upper : lower) / scale;
  }

  // disable unwanted legacy
  include "../../unwantedLegacy.as";
  include "../../legacyConstraints.as";

  private var mySkin:UIComponent;
  override public function get skin():UIComponent {
    return mySkin;
  }

  private var skinClass:Class;

  override protected function createChildren():void {
    var laf:LookAndFeel = LookAndFeelProvider(parent).laf;
    skinClass = laf.getClass("NumericStepper");

    mySkin = new skinClass();
    if (mySkin is LookAndFeelProvider) {
      LookAndFeelProvider(mySkin).laf = laf;
    }

    addingChild(mySkin);
    $addChildAt(mySkin, 0);
    childAdded(mySkin);

    if (!(mySkin is UIPartProvider)) {
      findSkinParts();
    }
  }

  override protected function attachSkin():void {

  }

  override public function getStyle(styleProp:String):* {
    if (styleProp == "skinClass") {
      return skinClass;
    }
    else if (styleProp == "layoutDirection") {
      return layoutDirection;
    }
    else {
      return undefined;
    }
  }

  public function uiPartAdded(id:String, instance:Object):void {
    this[id] = instance;
    partAdded(id, instance);
  }

  override public function invalidateSkinState():void {
  }

  override mx_internal function initProtoChain():void
    {

    }

  override protected function stateChanged(oldState:String, newState:String, recursive:Boolean):void
    {

    }
}
}