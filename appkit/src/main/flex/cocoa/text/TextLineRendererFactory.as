package cocoa.text {
import cocoa.TextLineLinkedList;

import flash.display.DisplayObjectContainer;
import flash.text.engine.ElementFormat;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import flash.text.engine.TextLineCreationResult;

public class TextLineRendererFactory {
  private static const textElement:TextElement = new TextElement();
  private static const textBlock:TextBlock = new TextBlock(textElement);

  private const youngOrphanLines:Vector.<TextLine> = new Vector.<TextLine>();
  private var youngOrphanCount:int;

  private const orphanLines:Vector.<TextLine> = new Vector.<TextLine>();
  private var orphanCount:int;

  private static var _instance:TextLineRendererFactory;
  public static function get instance():TextLineRendererFactory {
    if (_instance == null) {
      _instance = new TextLineRendererFactory();
    }
    return _instance;
  }

  public function reuse(container:DisplayObjectContainer, list:TextLineLinkedList, itemCountDelta:int, finalPass:Boolean):void {
    var line:TextLine;
    if (finalPass) {
      if (itemCountDelta > 0) {
        orphanLines.length = orphanCount + itemCountDelta;
        while (itemCountDelta-- > 0) {
          if ((line = list.removeFirst().line) != null) {
            container.removeChild(line);
            orphanLines[orphanCount++] = line;
          }
        }
      }
      else {
        orphanLines.length = orphanCount - itemCountDelta;
        while (itemCountDelta++ < 0) {
          if ((line = list.removeLast().line) != null) {
            container.removeChild(line);
            orphanLines[orphanCount++] = line;
          }
        }
      }
    }
    else {
      if (itemCountDelta > 0) {
        youngOrphanLines.length = youngOrphanCount + itemCountDelta;
        while (itemCountDelta-- > 0) {
          if ((line = list.removeFirst().line) != null) {
            youngOrphanLines[youngOrphanCount++] = line;
          }
        }
      }
      else {
        youngOrphanLines.length = youngOrphanCount - itemCountDelta;
        while (itemCountDelta++ < 0) {
          if ((line = list.removeLast().line) != null) {
            youngOrphanLines[youngOrphanCount++] = line;
          }
        }
      }
    }
  }

  public function create(container:DisplayObjectContainer, text:String, availableWidth:Number, elementFormat:ElementFormat, swfContext:SwfContext = null, useTruncationIndicator:Boolean = true):TextLine {
    textElement.elementFormat = elementFormat;
    textElement.text = text;

    var line:TextLine;
    if (youngOrphanCount != 0) {
      line = youngOrphanLines[--youngOrphanCount];
      TextLineUtil.recreate(textBlock, swfContext, line, availableWidth);
    }
    else {
      if (orphanCount != 0) {
        line = orphanLines[--orphanCount];
        TextLineUtil.recreate(textBlock, swfContext, line, availableWidth);
      }
      else {
        line = TextLineUtil.create(textBlock, swfContext, availableWidth);
      }
      container.addChild(line);
    }

    if (useTruncationIndicator && textBlock.textLineCreationResult == TextLineCreationResult.EMERGENCY) {
      TextLineUtil.truncate(text, textElement, line, swfContext, availableWidth);
    }

    return line;
  }

  public function postLayout(container:DisplayObjectContainer):void {
    if (youngOrphanCount == 0) {
      orphanLines.length = orphanCount;
      youngOrphanLines.length = 0;
      return;
    }

    orphanLines.length = orphanCount + youngOrphanCount;
    while (youngOrphanCount > 0) {
      var line:TextLine = youngOrphanLines[--youngOrphanCount];
      container.removeChild(line);
      orphanLines[orphanCount++] = line;
    }

    youngOrphanLines.length = 0;
  }
}
}