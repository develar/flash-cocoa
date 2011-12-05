package cocoa {
import cocoa.text.TextFormat;
import cocoa.text.TextLines;

import flash.display.DisplayObjectContainer;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import flash.text.engine.TextLineCreationResult;
import flash.text.engine.TextRotation;

/**
 * http://developer.apple.com/mac/library/DOCUMENTATION/UserExperience/Conceptual/AppleHIGuidelines/XHIGText/XHIGText.html#//apple_ref/doc/uid/TP30000365-TPXREF113
 */
public class LabelHelper {
  private static const textElement:TextElement = new TextElement();
  private static const textBlock:TextBlock = new TextBlock(textElement);

  private var availableWidth:Number = 1000000;

  private var invalid:Boolean;
  private var truncated:Boolean;

  private var _textLine:TextLine;
  
  public function LabelHelper(container:DisplayObjectContainer, textFormat:TextFormat = null) {
    this._container = container;
    _textFormat = textFormat;
  }

  public var textLineInsets:TextLineInsets;
  
  private var _container:DisplayObjectContainer;
  public function set container(value:DisplayObjectContainer):void {
    if (value != _container) {
      if (_textLine != null) {
        _container.removeChild(_textLine);
        if (value != null) {
          value.addChild(_textLine);
        }
      }
      
     _container = value; 
    }
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

  private var _textFormat:TextFormat;
  public function set textFormat(value:TextFormat):void {
    if (value != _textFormat) {
      _textFormat = value;
      invalid = true;
    }
  }

  private var _text:String;
  public function get text():String {
    return _text;
  }

  /**
   * Мы не рассчитываем на установку пустого текста для ui-компонента после того, как ему был назначен некий текст — то есть ли вы установили текст,
   * а потом установили его в null, то мы никак не скрываем с display list уже созданный textLine
   */
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

  public function move(x:Number, y:Number, isYLineRelated:Boolean = true):void {
    _textLine.x = x;
    _textLine.y = isYLineRelated ? y : (y + _textLine.ascent);
  }

  public function moveToCenter(w:Number, y:Number):void {
    _textLine.x = (w - _textLine.textWidth) * 0.5;
    _textLine.y = y;
  }
  
  public function moveToCenterWithXOffset(xOffset:Number, w:Number, y:Number):void {
    _textLine.x = xOffset + ((w - _textLine.textWidth) * 0.5);
    _textLine.y = y;
  }

  public function moveToHCenterByInsets(w:Number, h:Number, contentInsets:Insets):void {
    moveToCenter(w, h - contentInsets.bottom);
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

    if (_text == null) {
      return;
    }

    textElement.elementFormat = _textFormat.format;
    textElement.text = _text;
    if (textLineInsets != null && textLineInsets.rotation != null) {
      textBlock.lineRotation = textLineInsets.rotation;
    }

    if (_textLine == null) {
      _textLine = TextLines.create(textBlock, _textFormat.swfContext, availableWidth);
      _container.addChild(_textLine);
    }
    else {
      TextLines.recreate(textBlock, _textFormat.swfContext, _textLine, availableWidth);
    }

    if (_textLine == null) {
      trace(_container + " " + this + " " + textBlock.textLineCreationResult);
    }
    else {
      truncated = textBlock.textLineCreationResult == TextLineCreationResult.EMERGENCY;
      if (truncated && _useTruncationIndicator) {
        TextLines.truncate(_text, textElement, _textLine, _textFormat.swfContext, availableWidth);
      }
    }

    if (textLineInsets != null) {
      if (textLineInsets.rotation != null) {
        textBlock.lineRotation = TextRotation.ROTATE_0;
      }

      switch (textLineInsets.rotation) {
        case TextRotation.ROTATE_90:
          _textLine.x = textLineInsets.baseline;
          _textLine.y = textLineInsets.lineStartPadding;
          break;

        case null:
          _textLine.x = textLineInsets.lineStartPadding;
          _textLine.y = textLineInsets.baseline;
          break;

        default: throw new ArgumentError("unsupported rotation: " + textLineInsets.rotation);
      }
    }
  }

  public function measureHeight():Number {
    validate();
    var h:Number = Math.round(_textLine.height);
    if (textLineInsets.rotation == TextRotation.ROTATE_90) {
      h += textLineInsets.lineEndPadding + textLineInsets.lineEndPadding;
    }

    return h;
  }

  public function measureWidth():Number {
    validate();
    var w:Number = Math.round(_textLine.width);
    if (textLineInsets.rotation == null) {
      w += textLineInsets.lineEndPadding + textLineInsets.lineEndPadding;
    }

    return w;
  }
}
}