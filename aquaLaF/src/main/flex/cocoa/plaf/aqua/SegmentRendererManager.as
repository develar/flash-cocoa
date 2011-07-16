package cocoa.plaf.aqua {
import cocoa.FrameInsets;
import cocoa.border.BorderStateIndex;
import cocoa.border.Scale1BitmapBorder;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.TextFormatId;
import cocoa.renderer.InteractiveGraphicsRendererManager;
import cocoa.renderer.TextLineAndDisplayObjectEntry;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Shape;

public class SegmentRendererManager extends InteractiveGraphicsRendererManager {
  private static const leftIndex:int = 0;
  private static const middleIndex:int = leftIndex + 4;
  private static const rightIndex:int = middleIndex + 4;
  private static const separatorIndex:int = rightIndex + 4;
  private static const shadowIndex:int = separatorIndex + 2;

  protected var border:Scale1BitmapBorder;

  public function SegmentRendererManager(laf:LookAndFeel, lafKey:String) {
    border = Scale1BitmapBorder(laf.getBorder(lafKey + ".b"));
    super(laf.getTextFormat(TextFormatId.SYSTEM), border.contentInsets);
  }

  override protected function drawEntry(itemIndex:int, g:Graphics, w:Number, h:Number, x:Number, y:Number):void {
    draw(itemIndex, g, _lastCreatedRendererDimension, h, false, _selectionModel.isItemSelected(itemIndex));
  }

  private function draw(itemIndex:int, g:Graphics, w:Number, h:Number, selecting:Boolean, selected:Boolean):void {
    const offset:int = selecting ? (selected ? BorderStateIndex.ON_SELECTING : BorderStateIndex.OFF_SELECTING) : (selected ? BorderStateIndex.ON : BorderStateIndex.OFF);
    const computedSepatatorIndex:int = separatorIndex + (offset % 2);

    var frameInsets:FrameInsets = border.frameInsets;
    var last:Boolean = false;
    const first:Boolean = isFirst(itemIndex);
    if (first) {
      frameInsets.left = -2;
      frameInsets.right = 0;
    }
    else {
      frameInsets.left = 0;
      last = isLast(itemIndex);
      frameInsets.right = last ? -2 : 0;
    }

    var bitmaps:Vector.<BitmapData> = border.getBitmaps();
    var backgroundWidth:Number;
    var rightWidth:Number;
    if (first) {
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

  private function drawOnInteract(itemIndex:int, selecting:Boolean, selected:Boolean):void {
    var entry:TextLineAndDisplayObjectEntry = findEntry2(itemIndex);
    var shape:Shape = Shape(entry.displayObject);
    var g:Graphics = shape.graphics;
    g.clear();
    draw(itemIndex, g, entry.line.userData, _fixedRendererDimension, selecting, selected);
  }

  override public function setSelecting(itemIndex:int, value:Boolean):void {
    super.setSelecting(itemIndex, value);

    drawOnInteract(itemIndex, value, _selectionModel.isItemSelected(itemIndex));
  }

  override public function setSelected(itemIndex:int, value:Boolean):void {
    super.setSelected(itemIndex, value);

    drawOnInteract(itemIndex, false, value);
    selectingItemIndex = -1;
  }
}
}
