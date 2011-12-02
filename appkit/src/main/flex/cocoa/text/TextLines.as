package cocoa.text {
import flash.text.engine.ElementFormat;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import flash.utils.Dictionary;

public final class TextLines {
  private static const TRUNCATION_INDICATOR:String = "…";

  private static var truncationIndicatorMap:Dictionary;
  private static var textLineForTruncationIndicator:TextLine;

  private static const textBlockCreateTextLineArgs:Array = [null, 0];
  private static const textBlockRecreateTextLineArgs:Array = [null, null, 0];
  
  private static const textElement:TextElement = new TextElement();
  private static const textBlock:TextBlock = new TextBlock(textElement);
  private static var textLine:TextLine;

  // see usage in LabelHelper/EditableTextView
  public static function create(textBlock:TextBlock, swfContext:SwfContext, availableWidth:Number = 100000):TextLine {
    if (swfContext == null) {
      return textBlock.createTextLine(null, availableWidth);
    }
    else {
      textBlockCreateTextLineArgs[1] = availableWidth;
      return swfContext.callInContext(textBlock.createTextLine, textBlock, textBlockCreateTextLineArgs);
    }
  }

  public static function recreate(textBlock:TextBlock, swfContext:SwfContext, textLine:TextLine, availableWidth:Number = 100000):void {
    if (swfContext == null) {
      textBlock.recreateTextLine(textLine, null, availableWidth);
    }
    else {
      textBlockRecreateTextLineArgs[0] = textLine;
      textBlockRecreateTextLineArgs[2] = availableWidth;
      swfContext.callInContext(textBlock.recreateTextLine, textBlock, textBlockRecreateTextLineArgs);
    }
  }

  public static function calculateLineHeight(lineHeightAsNumberOrPercent:Object, charHeight:Number):Number {
    if (lineHeightAsNumberOrPercent == null) {
      return charHeight * 1.2;
    }
    else if (lineHeightAsNumberOrPercent is Number) {
      return Number(lineHeightAsNumberOrPercent);
    } // If 'value' is a percentage String like "10.5%", return that percentage of 'n'.
    else {
      var s:String = String(lineHeightAsNumberOrPercent);
      return (Number(s.substring(0, s.length - 1)) / 100) * charHeight;
    }
  }
  
  public static function measureText(text:String, elementFormat:ElementFormat, swfContext:SwfContext = null):TextLine {
    textElement.elementFormat = elementFormat;
    textElement.text = text;

    if (textLine == null) {
      textLine = create(textBlock, swfContext);
    }
    else {
      recreate(textBlock, swfContext, textLine);
    }

    textElement.elementFormat = null;
    return textLine;
  }

  public static function truncate(text:String, textElement:TextElement, textLine:TextLine, swfContext:SwfContext, availableWidth:Number):void {
    textElement.text = text.slice(0, getTruncationPosition(textLine, availableWidth - getTruncationIndicatorWidth(textElement, textElement.elementFormat, swfContext))) + TRUNCATION_INDICATOR;
    recreate(textElement.textBlock, swfContext, textLine);
  }

  private static function getTruncationIndicatorWidth(textElement:TextElement, format:ElementFormat, swfContext:SwfContext):Number {
    if (truncationIndicatorMap == null) {
      truncationIndicatorMap = new Dictionary(true);
    }

    var width:Number = truncationIndicatorMap[format];
    if (width != width) {
      textElement.text = TRUNCATION_INDICATOR;

      if (textLineForTruncationIndicator == null) {
        textLineForTruncationIndicator = TextLines.create(textElement.textBlock, swfContext);
      }
      else {
        TextLines.recreate(textElement.textBlock, swfContext, textLineForTruncationIndicator);
      }

      truncationIndicatorMap[format] = width = textLineForTruncationIndicator.textWidth;
    }

    return width;
  }

  private static function getTruncationPosition(line:TextLine, allowedWidth:Number):int {
    var consumedWidth:Number = 0;
    var charPosition:int = line.textBlockBeginIndex;
    var n:int = charPosition + line.rawTextLength;
    while (charPosition < n) {
      const atomIndex:int = line.getAtomIndexAtCharIndex(charPosition);
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