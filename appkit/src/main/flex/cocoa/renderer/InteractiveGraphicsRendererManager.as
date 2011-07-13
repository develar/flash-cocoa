package cocoa.renderer {
import cocoa.Insets;
import cocoa.text.TextFormat;

import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.engine.TextLine;

[Abstract]
public class InteractiveGraphicsRendererManager extends InteractiveTextRendererManager {
  protected var factory:TextLineAndDisplayObjectEntryFactory;

  public function InteractiveGraphicsRendererManager(textFormat:TextFormat = null, textInsets:Insets = null) {
    super(textFormat, textInsets);

    factory = new TextLineAndDisplayObjectEntryFactory(Shape, true);

    registerEntryFactory(factory);
  }

  protected var _textLineContainer:Sprite;
  override protected function get textLineContainer():DisplayObjectContainer {
    return _textLineContainer;
  }

  override public function set container(value:DisplayObjectContainer):void {
    super.container = value;

    if (textLineContainer == null) {
      _textLineContainer = new Sprite();
      _textLineContainer.mouseEnabled = false;
      _textLineContainer.mouseChildren = false;
    }

    value.addChild(textLineContainer);
  }

  protected function isLast(itemIndex:int):Boolean {
    return itemIndex == (_dataSource.itemCount - 1);
  }

  override protected function createEntry(itemIndex:int, x:Number, y:Number, w:Number, h:Number):TextLineEntry {
    var line:TextLine = createTextLine(itemIndex, 1000000 /* this renderer manager is not bounded */);
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

    drawEntry(itemIndex, shape.graphics, w == w ? w : _lastCreatedRendererWidth, h == h ? h : _lastCreatedRendererHeigth, x, y);

    return entry;
  }

  protected function drawEntry(itemIndex:int, g:Graphics, w:Number, h:Number, x:Number, y:Number):void {

  }

  override public function getItemIndexAt(x:Number, y:Number):int {
    var entry:TextLineAndDisplayObjectEntry = TextLineAndDisplayObjectEntry(cells.head);
    var tail:TextLineAndDisplayObjectEntry = TextLineAndDisplayObjectEntry(cells.tail);
    const totalWidth:Number = tail.displayObject.x + tail.displayObject.width;
    if (x < entry.displayObject.x || x > totalWidth) {
      return -1;
    }

    if (x < (totalWidth >> 1)) {
      do {
        if (x >= entry.displayObject.x && x <= (entry.displayObject.x + entry.displayObject.width) &&
            y >= entry.displayObject.y && y <= (entry.displayObject.y + entry.displayObject.height)) {
          return entry.itemIndex;
        }
      }
      while ((entry = TextLineAndDisplayObjectEntry(entry.next)) != null);
    }
    else {
      entry = tail;
      do {
        if (x >= entry.displayObject.x && x <= (entry.displayObject.x + entry.displayObject.width) &&
            y >= entry.displayObject.y && y <= (entry.displayObject.y + entry.displayObject.height)) {
          return entry.itemIndex;
        }
      }
      while ((entry = TextLineAndDisplayObjectEntry(entry.previous)) != null);
    }

    return -1;
  }
}
}