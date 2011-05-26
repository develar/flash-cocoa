package cocoa.text {
import cocoa.tableView.ListViewItemRendererFactory;
import cocoa.tableView.TextLineLinkedList;

import flash.display.DisplayObjectContainer;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;

public class TextLineRendererFactory implements ListViewItemRendererFactory {
  private static const textElement:TextElement = new TextElement();
  private static const textBlock:TextBlock = new TextBlock(textElement);

  public var numberOfUsers:int;

  private var textFormat:TextFormat;
  private var postLayoutCallCount:int;

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

  public function reuse(list:TextLineLinkedList, rowCountDelta:int, finalPass:Boolean):void {
    var line:TextLine;
    if (finalPass) {
      if (rowCountDelta > 0) {
        orphanLines.length = orphanCount + rowCountDelta;
        while (rowCountDelta-- > 0) {
          line = list.removeFirst().line;
          _container.removeChild(line);
          orphanLines[orphanCount++] = line;
        }
      }
      else {
        orphanLines.length = orphanCount - rowCountDelta;
        while (rowCountDelta++ < 0) {
          line = list.removeLast().line;
          _container.removeChild(line);
          orphanLines[orphanCount++] = line;
        }
      }
    }
    else {
      if (rowCountDelta > 0) {
        youngOrphanLines.length = youngOrphanCount + rowCountDelta;
        while (rowCountDelta-- > 0) {
          line = list.removeFirst().line;
          youngOrphanLines[youngOrphanCount++] = line;
        }
      }
      else {
        youngOrphanLines.length = youngOrphanCount - rowCountDelta;
        while (rowCountDelta++ < 0) {
          line = list.removeLast().line;
          youngOrphanLines[youngOrphanCount++] = line;
        }
      }
    }
  }

  public function create(text:String, customTextFormat:TextFormat = null):TextLine {
    var actualFormat:TextFormat = customTextFormat || textFormat;
    textElement.elementFormat = actualFormat.format;
    textElement.text = text;

    var line:TextLine;
    if (youngOrphanCount != 0) {
      line = youngOrphanLines[--youngOrphanCount];
      TextLineUtil.recreate(textBlock, actualFormat.swfContext, line);
    }
    else {
      if (orphanCount != 0) {
        line = orphanLines[--orphanCount];
        TextLineUtil.recreate(textBlock, actualFormat.swfContext, line);
      }
      else {
        line = TextLineUtil.create(textBlock, actualFormat.swfContext);
      }
      _container.addChild(line);
    }

    line.userData = text;
    return line;
  }

  public function postLayout():void {
    if (++postLayoutCallCount == numberOfUsers) {
      postLayoutCallCount = 0;

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
}