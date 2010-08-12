package cocoa {
import cocoa.text.TextFormat;

import flash.text.engine.ElementFormat;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import flash.text.engine.TextLineCreationResult;
import flash.text.engine.TextRotation;
import flash.utils.Dictionary;

import mx.core.mx_internal;

use namespace mx_internal;

/**
 * http://developer.apple.com/mac/library/DOCUMENTATION/UserExperience/Conceptual/AppleHIGuidelines/XHIGText/XHIGText.html#//apple_ref/doc/uid/TP30000365-TPXREF113
 */
public class LabelHelper {
  private static const emptyArgs:Array = [];
  private static const textBlockCreateTextLineArgs:Array = [null, 0];

  private static const TRUNCATION_INDICATOR:String = "…";

  private static var truncationIndicatorMap:Dictionary;

  private static const textElement:TextElement = new TextElement();
  private static const textBlock:TextBlock = new TextBlock(textElement);

  private var availableWidth:Number = 1000000;

  private var invalid:Boolean;
  private var truncated:Boolean;

  private var _textLine:TextLine;
  private var container:View;

  public function LabelHelper(container:View, textFormat:TextFormat = null) {
    this.container = container;
    _textFormat = textFormat;
  }

  /**
   * @see TextBlock#lineRotation
   */
  private var _rotation:String;
  public function set rotation(value:String):void {
    _rotation = value;
  }

  private var _useTruncationIndicator:Boolean = true;
  public function set useTruncationIndicator(value:Boolean):void {
    _useTruncationIndicator = value;
  }

  public function get hasText():Boolean {
    return _text != null;
  }

  public function get textWidth():Number {
    // _textLine.textWidth именно logical width of the text line, не учитывает rotation
    return _textLine.width;
  }

  public function get textHeight():Number {
    return _textLine.height;
  }

  public function get textLine():TextLine {
    return _textLine;
  }

  public function set alpha(value:Number):void {
    if (_textLine != null) {
      _textLine.alpha = value;
    }
  }

  private var _textFormat:TextFormat;
  public function set textFormat(value:TextFormat):void {
    if (value != _textFormat) {
      _textFormat = value;
      invalid = true;
    }
  }

  private var _text:String;
  public function get text():String {
    return _text
  }

  public function set text(value:String):void {
    if (value != _text) {
      invalid = true;
      _text = value;
    }
  }

  public function set x(value:Number):void {
    _textLine.x = value;
  }

  public function set y(value:Number):void {
    _textLine.y = value;
  }

  public function move(x:Number, y:Number):void {
    if (_rotation != null) {
      switch (_rotation) {
        case TextRotation.ROTATE_270:
        {
          y += _textLine.textWidth;
          x += _textLine.textHeight;
        }
          break;
      }
    }

    _textLine.x = x;
    _textLine.y = y;
  }

  public function moveToCenter(w:Number, y:Number):void {
    _textLine.x = (w - _textLine.textWidth) * 0.5;
    _textLine.y = y;
  }

  public function moveToCenterByInsets(w:Number, h:Number, contentInsets:Insets):void {
    _textLine.x = (w - _textLine.textWidth) * 0.5;
    _textLine.y = h - contentInsets.bottom;
  }

  public function moveByInsets(h:Number, contentInsets:Insets):void {
    _textLine.x = contentInsets.left;
    _textLine.y = h - contentInsets.bottom;
  }

  public function moveByVerticalInsets(h:Number, contentInsets:Insets, x:Number):void {
    _textLine.x = x;
    _textLine.y = h - contentInsets.bottom;
  }

  public function adjustWidth(newWidth:Number):void {
    if (isNaN(newWidth)) {
      newWidth = 1000000;
    }

    if (newWidth < availableWidth || (truncated && newWidth > availableWidth)) {
      invalid = true;
    }

    availableWidth = newWidth;
  }

  public function validate():void {
    if (!invalid) {
      return;
    }

    invalid = false;

    if (_textLine != null) {
      container.removeDisplayObject(_textLine);
    }

    if (_text != null) {
      textElement.elementFormat = _textFormat.format;
      textElement.text = _text;
      if (_rotation != null) {
        textBlock.lineRotation = _rotation;
      }

      if (_textFormat.swfContext == null) {
        _textLine = textBlock.createTextLine(null, availableWidth);
      }
      else {
        textBlockCreateTextLineArgs[1] = availableWidth;
        _textLine = _textFormat.swfContext.callInContext(textBlock.createTextLine, textBlock, textBlockCreateTextLineArgs);
      }

      if (_textLine == null) {
        trace(container + " " + this + " " + textBlock.textLineCreationResult);
      }
      else {
        truncated = textBlock.textLineCreationResult == TextLineCreationResult.EMERGENCY;
        if (truncated && _useTruncationIndicator) {
          textElement.text = _text.slice(0, getTruncationPosition(_textLine, availableWidth - getTruncationIndicatorWidth(textElement.elementFormat))) + TRUNCATION_INDICATOR;

          _textLine = _textFormat.swfContext == null ? textBlock.createTextLine() : _textFormat.swfContext.callInContext(textBlock.createTextLine, textBlock, emptyArgs);
        }

        textBlock.releaseLines(_textLine, _textLine);
        _textLine.mouseEnabled = false;
        _textLine.mouseChildren = false;
        container.addDisplayObject(_textLine);
      }

      if (_rotation != null) {
        textBlock.lineRotation = TextRotation.ROTATE_0;
      }
    }
    else {
      _textLine = null;
    }
  }

  private function getTruncationIndicatorWidth(format:ElementFormat):Number {
    if (truncationIndicatorMap == null) {
      truncationIndicatorMap = new Dictionary(true);
    }

    var width:Number = truncationIndicatorMap[format];
    if (isNaN(width)) {
      textElement.text = TRUNCATION_INDICATOR;
      var textLine:TextLine = textBlock.createTextLine();
      textBlock.releaseLines(textLine, textLine);

      width = textLine.textWidth;
      truncationIndicatorMap[format] = width;
      return width;
    }
    else {
      return truncationIndicatorMap[format];
    }
  }

  private function getTruncationPosition(line:TextLine, allowedWidth:Number):int {
    var consumedWidth:Number = 0;
    var charPosition:int = line.textBlockBeginIndex;

    var n:Number = line.textBlockBeginIndex + line.rawTextLength;
    while (charPosition < n) {
      var atomIndex:int = line.getAtomIndexAtCharIndex(charPosition);
      consumedWidth += line.getAtomBounds(atomIndex).width;
      if (consumedWidth > allowedWidth) {
        break;
      }

      charPosition = line.getAtomTextBlockEndIndex(atomIndex);
    }

    return charPosition;
  }
}
}