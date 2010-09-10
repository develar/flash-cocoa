package cocoa.util {
import flash.text.engine.TextBlock;
import flash.text.engine.TextLine;

import flashx.textLayout.compose.ISWFContext;

public final class TextLineUtil {
  private static const textBlockCreateTextLineArgs:Array = [null, 0];
  private static const textBlockRecreateTextLineArgs:Array = [null, null, 0];

  // see usage in LabelHelper/EditableTextView
  public static function create(textBlock:TextBlock, swfContext:ISWFContext, textLine:TextLine, availableWidth:Number = 100000):TextLine {
    if (swfContext == null) {
      if (textLine == null) {
        return textBlock.createTextLine(null, availableWidth);
      }
      else {
        textBlock.recreateTextLine(textLine, null, availableWidth);
        return null;
      }
    }
    else {
      if (textLine == null) {
        textBlockCreateTextLineArgs[1] = availableWidth;
        return swfContext.callInContext(textBlock.createTextLine, textBlock, textBlockCreateTextLineArgs);
      }
      else {
        textBlockRecreateTextLineArgs[0] = textLine;
        textBlockRecreateTextLineArgs[2] = availableWidth;
        swfContext.callInContext(textBlock.recreateTextLine, textBlock, textBlockRecreateTextLineArgs);
        return null;
      }
    }
  }

  public static function calculateLineHeight(lineHeightAsNumberOrPercent:Object, fontSize:Number):Number {
    if (lineHeightAsNumberOrPercent == null) {
      return fontSize * 1.2;
    }
    else if (lineHeightAsNumberOrPercent is Number) {
      return Number(lineHeightAsNumberOrPercent);
    } // If 'value' is a percentage String like "10.5%", return that percentage of 'n'.
    else {
      var s:String = String(lineHeightAsNumberOrPercent);
      return (Number(s.substring(0, s.length - 1)) / 100) * fontSize;
    }
  }
}
}