package cocoa {
import cocoa.plaf.TextFormatId;
import cocoa.text.TextFormat;

import flash.text.engine.FontDescription;
import flash.text.engine.TextLine;

public class Label extends ComponentWrapperImpl {
  private var fontDescription:FontDescription;

  private var textFormat:TextFormat;

  private var labelHelper:LabelHelper;

  public function Label() {
    labelHelper = new LabelHelper(null);
  }

  override public function get actualWidth():int {
    var textLine:TextLine = labelHelper.textLine;
    return textLine == null ? 0 : textLine.textWidth;
  }

  override public function get actualHeight():int {
    var textLine:TextLine = labelHelper.textLine;
    return textLine == null ? 0 : textLine.textHeight;
  }

  override public function getMinimumWidth(hHint:int = -1):int {
    return getPreferredWidth();
  }

  override public function getMinimumHeight(wHint:int = -1):int {
    return getPreferredHeight();
  }

  override public function getPreferredWidth(hHint:int = -1):int {
    labelHelper.validate();
    return labelHelper.textWidth;
  }

  override public function getPreferredHeight(wHint:int = -1):int {
    labelHelper.validate();
    return labelHelper.textHeight;
  }

  override public function getMaximumWidth(hHint:int = -1):int {
    return getPreferredWidth();
  }

  override public function getMaximumHeight(wHint:int = -1):int {
    return getPreferredHeight();
  }

  public function get title():String {
    return labelHelper.text;
  }

  public function set title(value:String):void {
    if (value != labelHelper.text) {
      labelHelper.text = value;
      //!! invalidateDisplayList();
    }
  }

  override public function init(container:Container):void {
    if (textFormat != null && fontDescription != null) {
      textFormat.format.fontDescription = fontDescription;
    }
    else {
      var lafTextFormat:TextFormat = container.laf.getTextFormat(TextFormatId.VIEW);
      if (textFormat == null) {
        textFormat = lafTextFormat;
      }
      else {
        textFormat.format.fontDescription = lafTextFormat.format.fontDescription;
        textFormat.swfContext = lafTextFormat.swfContext;
      }
    }

    labelHelper.container = container;
    labelHelper.textFormat = textFormat;
  }

  override public function setBounds(x:Number, y:Number, width:int, height:int):void {
    labelHelper.validate();
    labelHelper.move(x, y, false);
  }

  override public function get hasBaseline():Boolean {
    return true;
  }

  override public function getBaseline(width:int, height:int):int {
    if (labelHelper.hasText) {
      labelHelper.validate();
      return labelHelper.textLine.ascent;
    }
    else {
      return -1;
    }
  }
}
}