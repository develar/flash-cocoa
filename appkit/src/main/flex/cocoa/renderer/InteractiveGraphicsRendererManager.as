package cocoa.renderer {
import cocoa.Insets;
import cocoa.text.TextFormat;

import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.engine.TextLine;

[Abstract]
public class InteractiveGraphicsRendererManager extends InteractiveTextRendererManager {
  protected var textLineContainer:Sprite;
  protected var factory:TextLineAndDisplayObjectEntryFactory;

  public function InteractiveGraphicsRendererManager(textFormat:TextFormat, textInsets:Insets) {
    super(textFormat, textInsets);

    factory = new TextLineAndDisplayObjectEntryFactory(Shape, true);

    registerEntryFactory(factory);
  }

  override public function set container(value:DisplayObjectContainer):void {
    super.container = value;

    if (textLineContainer == null) {
      textLineContainer = new Sprite();
      textLineContainer.mouseEnabled = false;
      textLineContainer.mouseChildren = false;
    }

    value.addChild(textLineContainer);
  }

  protected function isLast(itemIndex:int):Boolean {
    return itemIndex == (_dataSource.itemCount - 1);
  }

  override protected function createEntry(itemIndex:int, x:Number, y:Number, w:Number, h:Number):TextLineEntry {
    var line:TextLine = createTextLine(textLineContainer, itemIndex, 1000000 /* this renderer manager is not bounded */);
    layoutTextLine(line, x, y, h);
    computeCreatingRendererSize(w, h, line);

    var entry:TextLineAndDisplayObjectEntry = factory.create(line);
    entry.itemIndex = itemIndex;

    var shape:Shape = Shape(entry.displayObject);
    if (shape.parent != _container) {
      _container.addChildAt(shape, _container.numChildren - 1);
    }

    shape.x = x;
    shape.y = y;

    drawEntry(itemIndex, shape, w == w ? w : _lastCreatedRendererWidth, h == h ? h : _lastCreatedRendererHeigth);

    return entry;
  }

  protected function drawEntry(itemIndex:int, shape:Shape, w:Number, h:Number):void {

  }
}
}
