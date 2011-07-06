package cocoa.plaf.aqua {
import cocoa.FrameInsets;
import cocoa.InteractiveTextRendererManager;
import cocoa.TextLineAndDisplayObjectLinkedListEntry;
import cocoa.TextLineAndDisplayObjectLinkedListEntryFactory;
import cocoa.TextLineLinkedListEntry;
import cocoa.border.BitmapBorderStateIndex;
import cocoa.border.Scale1BitmapBorder;
import cocoa.text.TextFormat;

import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.engine.TextLine;

public class SegmentRendererManager extends InteractiveTextRendererManager {
  private static const leftIndex:int = 0;
  private static const middleIndex:int = leftIndex + 4;
  private static const rightIndex:int = middleIndex + 4;
  private static const separatorIndex:int = rightIndex + 4;
  private static const shadowIndex:int = separatorIndex + 2;

  private var factory:TextLineAndDisplayObjectLinkedListEntryFactory;
  protected var border:Scale1BitmapBorder;

  private var textLineContainer:Sprite;

  public function SegmentRendererManager(textFormat:TextFormat, border:Scale1BitmapBorder) {
    super(textFormat, border.contentInsets);

    this.border = border;
    factory = new TextLineAndDisplayObjectLinkedListEntryFactory(Shape);
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

  override public function setSelecting(itemIndex:int, value:Boolean):void {
    super.setSelecting(itemIndex, value);
  }

  override protected function createEntry(itemIndex:int, x:Number, y:Number, w:Number, h:Number):TextLineLinkedListEntry {
    var line:TextLine = createTextLine(textLineContainer, itemIndex, w);
    _lastCreatedRendererWidth = Math.ceil(line.textWidth) + textInsets.width;
    line.x = x + textInsets.left;
    line.y = y + h - textInsets.bottom;
    var entry:TextLineAndDisplayObjectLinkedListEntry = factory.create(line);
    entry.itemIndex = itemIndex;

    var shape:Shape = Shape(entry.displayObject);
    if (shape.parent != _container) {
      _container.addChildAt(shape, _container.numChildren - 1);
    }

    shape.x = x;
    shape.y = y;

    var frameInsets:FrameInsets = border.frameInsets;

    var isLast:Boolean = false;
    const isFirst:Boolean = itemIndex == 0;
    if (isFirst) {
      frameInsets.left = -2;
      frameInsets.right = 0;
    }
    else {
      frameInsets.left = 0;
      isLast = this.isLast(itemIndex);
      frameInsets.right = isLast ? -2 : 0;
    }

    var g:Graphics = shape.graphics;
    draw(itemIndex, g, _lastCreatedRendererWidth, h, false, false);

    return entry;
  }

  override public function getItemIndexAt(x:Number):int {
    if (x < 0 || x > _container.width) {
      return -1;
    }

    var entry:TextLineAndDisplayObjectLinkedListEntry = TextLineAndDisplayObjectLinkedListEntry(cells.head);
    do {
      if (x >= entry.displayObject.x && x <= (entry.displayObject.x + entry.displayObject.width)) {
        return entry.itemIndex;
      }
    }
    while ((entry = TextLineAndDisplayObjectLinkedListEntry(entry.next)) != null);

    return -1;
  }

  private function draw(itemIndex:int, g:Graphics, w:Number, h:Number, selecting:Boolean, selected:Boolean):void {
    const offset:int = selecting ? (selected ? BitmapBorderStateIndex.ON_HIGHLIGHT : BitmapBorderStateIndex.OFF_HIGHLIGHT) : (selected ? BitmapBorderStateIndex.ON : BitmapBorderStateIndex.OFF);
    const computedSepatatorIndex:int = separatorIndex + (offset % 2);

    var frameInsets:FrameInsets = border.frameInsets;
    var bitmaps:Vector.<BitmapData> = border.getBitmaps();
    var backgroundWidth:Number;
    var rightWidth:Number;
    const isFirst:Boolean = itemIndex == 0;
    if (isFirst) {
      border.bitmapIndex = leftIndex + offset;
      var leftFrameWidth:Number = bitmaps[leftIndex + offset].width;
      border.draw(g, leftFrameWidth + frameInsets.left + frameInsets.right, h);

      backgroundWidth = w - leftFrameWidth - frameInsets.left;
      frameInsets.left += leftFrameWidth;
    }
    else {
      if (selected) {
        frameInsets.left = -1;
        border.bitmapIndex = computedSepatatorIndex;
        border.draw(g, 1 + frameInsets.left + frameInsets.right, h - 3);
        frameInsets.left = 0;
      }

      const last:Boolean = isLast(itemIndex);
      if (last) {
        rightWidth = bitmaps[rightIndex + offset].width;
        backgroundWidth = w - rightWidth - frameInsets.right;
      }
      else {
        backgroundWidth = w;
      }
    }

    frameInsets.top = h;
    border.bitmapIndex = shadowIndex;
    border.draw(g, (last ? backgroundWidth : (backgroundWidth + 1)) + frameInsets.left + frameInsets.right, h);
    frameInsets.top = 0;

    border.bitmapIndex = middleIndex + offset;
    border.draw(g, backgroundWidth + frameInsets.left + frameInsets.right, h - 3);

    if (last) {
      frameInsets.left = backgroundWidth;
      border.bitmapIndex = rightIndex + offset;
      border.draw(g, rightWidth + frameInsets.left + frameInsets.right, h);
    }
    else {
      frameInsets.left = w;
      border.bitmapIndex = computedSepatatorIndex;
      border.draw(g, 1 + frameInsets.left + frameInsets.right, h - 3);
    }
  }
}
}
