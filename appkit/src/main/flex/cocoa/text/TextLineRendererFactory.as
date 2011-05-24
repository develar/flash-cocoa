package cocoa.text {
import cocoa.tableView.ListViewRendererFactory;

import flash.display.DisplayObjectContainer;
import flash.errors.IllegalOperationError;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;

public class TextLineRendererFactory implements ListViewRendererFactory {
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

  public function reuse(visibleRenderers:Vector.<TextLine>, numberOfRenderers:int):void {
    var absDelta:int = (numberOfRenderers ^ (numberOfRenderers >> 31)) - (numberOfRenderers >> 31);
    youngOrphanLines.length = youngOrphanCount + absDelta;
    for (var i:int = numberOfRenderers > 0 ? 0 : visibleRenderers.length - absDelta; i < absDelta; i++) {
      // clear (update length and delete old visible renderers) visibleRenderers later, see TextTableColumn#createAndLayoutRenderer
      const textLine:TextLine = visibleRenderers[i];
      if (textLine == null) {
        throw new IllegalOperationError();
      }
      youngOrphanLines[youngOrphanCount++] = textLine;
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
    }
  }
}
}