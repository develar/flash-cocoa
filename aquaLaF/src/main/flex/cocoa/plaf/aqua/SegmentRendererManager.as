package cocoa.plaf.aqua {
import cocoa.FrameInsets;
import cocoa.border.BorderStateIndex;
import cocoa.border.Scale1BitmapBorder;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.TextFormatId;
import cocoa.renderer.InteractiveGraphicsRendererManager;

import flash.display.BitmapData;
import flash.display.Graphics;

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

  override public function setSelecting(itemIndex:int, value:Boolean):void {
    super.setSelecting(itemIndex, value);
  }

  override protected function drawEntry(itemIndex:int, g:Graphics, w:Number, h:Number, x:Number, y:Number):void {
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

    draw(itemIndex, g, _lastCreatedRendererWidth, h, false, false);
  }

  private function draw(itemIndex:int, g:Graphics, w:Number, h:Number, selecting:Boolean, selected:Boolean):void {
    const offset:int = selecting ? (selected ? BorderStateIndex.ON_HIGHLIGHT : BorderStateIndex.OFF_HIGHLIGHT) : (selected ? BorderStateIndex.ON : BorderStateIndex.OFF);
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
