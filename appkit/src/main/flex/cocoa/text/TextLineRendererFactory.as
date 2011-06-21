package cocoa.text {
import cocoa.tableView.TextLineLinkedList;

import flash.display.DisplayObjectContainer;
import flash.text.engine.ElementFormat;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import flash.text.engine.TextLineCreationResult;

public class TextLineRendererFactory {
  private static const textElement:TextElement = new TextElement();
  private static const textBlock:TextBlock = new TextBlock(textElement);

  private var textFormat:TextFormat;

  private const youngOrphanLines:Vector.<TextLine> = new Vector.<TextLine>();
  private var youngOrphanCount:int;

  private const orphanLines:Vector.<TextLine> = new Vector.<TextLine>();
  private var orphanCount:int;

  public function TextLineRendererFactory(textFormat:TextFormat) {
    this.textFormat = textFormat;
  }

  private var _container:DisplayObjectContainer;
  public function set container(value:DisplayObjectContainer):void {
    _container = value;
  }

  public function reuse(list:TextLineLinkedList, itemCountDelta:int, finalPass:Boolean):void {
    var line:TextLine;
    if (finalPass) {
      if (itemCountDelta > 0) {
        orphanLines.length = orphanCount + itemCountDelta;
        while (itemCountDelta-- > 0) {
          if ((line = list.removeFirst().line) != null) {
            _container.removeChild(line);
            orphanLines[orphanCount++] = line;
          }
        }
      }
      else {
        orphanLines.length = orphanCount - itemCountDelta;
        while (itemCountDelta++ < 0) {
          if ((line = list.removeLast().line) != null) {
            _container.removeChild(line);
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

  public function create(text:String, availableWidth:Number, customElementFormat:ElementFormat = null, useTruncationIndicator:Boolean = true):TextLine {
    var swfContext:SwfContext;
    if (customElementFormat == null) {
      textElement.elementFormat = textFormat.format;
      swfContext = textFormat.swfContext;
    }
    else {
      textElement.elementFormat = customElementFormat;
    }

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
      _container.addChild(line);
    }

    if (useTruncationIndicator && textBlock.textLineCreationResult == TextLineCreationResult.EMERGENCY) {
      TextLineUtil.truncate(text, textElement, line, swfContext, availableWidth);
    }

    return line;
  }

  public function postLayout():void {
    if (youngOrphanCount == 0) {
      orphanLines.length = orphanCount;
      youngOrphanLines.length = 0;
      return;
    }

    orphanLines.length = orphanCount + youngOrphanCount;
    while (youngOrphanCount > 0) {
      var line:TextLine = youngOrphanLines[--youngOrphanCount];
      _container.removeChild(line);
      orphanLines[orphanCount++] = line;
    }

    youngOrphanLines.length = 0;
  }
}
}