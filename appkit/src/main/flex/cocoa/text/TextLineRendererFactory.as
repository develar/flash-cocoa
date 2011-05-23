package cocoa.text {
import cocoa.tableView.ListViewRendererFactory;

import flash.display.DisplayObjectContainer;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;

public class TextLineRendererFactory implements ListViewRendererFactory {
  private static const textElement:TextElement = new TextElement();
  private static const textBlock:TextBlock = new TextBlock(textElement);

  private var textFormat:TextFormat;

  public function TextLineRendererFactory(textFormat:TextFormat) {
    this.textFormat = textFormat;
  }

  private var _container:DisplayObjectContainer;
  public function set container(value:DisplayObjectContainer):void {
    _container = value;
  }

  private var linePool:Vector.<TextLine>;

  public function create(text:String, customTextFormat:TextFormat = null):TextLine {
    var actualFormat:TextFormat = customTextFormat || textFormat;
    textElement.elementFormat = actualFormat.format;
    textElement.text = text;

    var line:TextLine = TextLineUtil.create(textBlock, actualFormat.swfContext);
    _container.addChild(line);
    return line;
  }
}
}