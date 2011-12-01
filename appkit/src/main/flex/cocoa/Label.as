package cocoa {
import cocoa.plaf.LookAndFeelUtil;
import cocoa.plaf.TextFormatId;
import cocoa.text.TextFormat;

import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.utils.Dictionary;

import flashx.textLayout.formats.TextAlign;
import flashx.textLayout.formats.VerticalAlign;

/**
 * Единственно правильным и нормальным способом ставить формат текста — это получение его из LaF.
 * В приложении свобода аля на уровне компонента что-то вписать — даром не нужно. Если все-таки нужен формат не входящий в предоставляемый системой — он выносится в LaF.
 * Поэтому мы допускаем установку таковых свойств, при этом для всех, кроме color, только один раз
 * (color меняется в ответ на состояние, то есть нечто типа color.normal="0xFFFFFF" color="0x000000")
 */
public class Label extends AbstractView {
  private var fontDescription:FontDescription;

  private var textFormat:TextFormat;

  private var labelHelper:LabelHelper;

  private static var textFormatDictionary:Dictionary;

  public function Label() {
    super();

    mouseEnabled = false;
    mouseChildren = false;

    labelHelper = new LabelHelper(this);
  }

  public function get color():uint {
    return textFormat.format.color;
  }

  public function set color(value:uint):void {
    if (textFormat == null) {
      textFormat = new TextFormat(new ElementFormat(null, 12, value));
    }
    else if (!textFormat.format.locked) // то есть еще идет фаза инициализации — а не установка цвета в результате смены состояни
    {
      textFormat.format.color = value;
    }
    else if (textFormat.format.color != value) {
      if (textFormatDictionary == null) {
        textFormatDictionary = new Dictionary();
      }

      textFormatDictionary[textFormat.format.color] = textFormat;
      textFormat = new TextFormat(new ElementFormat(fontDescription, textFormat.format.fontSize, value));
      textFormatDictionary[value] = textFormat;

      labelHelper.textFormat = textFormat;
    }

    invalidateDisplayList();
  }

  public function set fontFamily(value:String):void {
    if (fontDescription == null) {
      fontDescription = new FontDescription();
    }

    fontDescription.fontName = value;
  }

  public function set fontWeight(value:String):void {
    if (fontDescription == null) {
      fontDescription = new FontDescription();
    }

    fontDescription.fontWeight = value;
  }

  public function set fontSize(value:Number):void {
    if (textFormat == null) {
      textFormat = new TextFormat(new ElementFormat(null, value));
    }
    else {
      textFormat.format.fontSize = value;
    }
  }

  public function get title():String {
    return labelHelper.text;
  }

  public function set title(value:String):void {
    if (value != labelHelper.text) {
      labelHelper.text = value;
      invalidateDisplayList();
    }
  }

  override protected function createChildren():void {
    super.createChildren();

    if (textFormat != null && fontDescription != null) {
      textFormat.format.fontDescription = fontDescription;
    }
    else {
      var lafTextFormat:TextFormat = LookAndFeelUtil.find(parent).getTextFormat(TextFormatId.VIEW);
      if (textFormat == null) {
        textFormat = lafTextFormat;
      }
      else {
        textFormat.format.fontDescription = lafTextFormat.format.fontDescription;
        textFormat.swfContext = lafTextFormat.swfContext;
      }
    }

    labelHelper.textFormat = textFormat;
  }

  override protected function measure():void {
    if (labelHelper.hasText) {
      labelHelper.validate();
      measuredWidth = labelHelper.textWidth ;
      measuredHeight = labelHelper.textHeight;
    }
    else {
      measuredWidth = 0;
      measuredHeight = 0;
    }
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    super.updateDisplayList(w, h);
    if (!labelHelper.hasText) {
      return;
    }

    labelHelper.validate();

    // verticalAlign = top
    var textY:Number = labelHelper.textLine.ascent;

    switch (_textAlign) {
      case TextAlign.START:
      case TextAlign.LEFT:
        labelHelper.move(0, textY);
        break;

      case TextAlign.CENTER:
        labelHelper.moveToCenter(w, textY);
        break;
    }
  }

  override public function get baselinePosition():Number {
    if (labelHelper.hasText) {
      labelHelper.validate();
      return labelHelper.textLine.ascent;
    }
    else {
      return 0;
    }
  }
}
}