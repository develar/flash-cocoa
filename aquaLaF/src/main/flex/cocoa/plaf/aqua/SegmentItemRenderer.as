package cocoa.plaf.aqua {
import cocoa.FrameInsets;
import cocoa.border.BitmapBorderStateIndex;
import cocoa.border.Scale1BitmapBorder;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.basic.LabeledItemRenderer;

import flash.display.BitmapData;
import flash.display.Graphics;

public class SegmentItemRenderer extends LabeledItemRenderer {
  private static const leftIndex:int = 0;
  private static const middleIndex:int = leftIndex + 4;
  private static const rightIndex:int = middleIndex + 4;
  private static const separatorIndex:int = rightIndex + 4;
  private static const shadowIndex:int = separatorIndex + 2;

  override public function get lafPrefix():String {
    return "SegmentItem";
  }

  override public function set laf(value:LookAndFeel):void {
    super.laf = value;

    border = getBorder("b");
  }

  override protected function measure():void {
    super.measure();

    measuredMinHeight = measuredHeight = 20;
  }

  /**
   * Мы должны быть осторожны при отрисовке и учитывать, чтобы было корректное перекрытие разделителей.
   * Поэтому: всегда (за исключением последнего элемента) отрисовываем разделитель справа, а слева только если мы selected (нет разницы — highlighted или нет).
   * Так как мы добавляем элементы слева направо — самый левый имеет самый маленький индекс в display list,
   * то при отрисовке левого разделителя при selected Flash Player корректно отрисует его над старым разделителем (который отрисован предыдущим элементом).
   *
   * Но у нас есть полупрозрачные пиксели — при наложении получается плохо — поэтому background и separator по высоте меньше на 3 пикселя по высоте (снизу), мы отрисовываем их сами программно
   */
  override protected function updateDisplayList(w:Number, h:Number):void {
    var frameInsets:FrameInsets = border.frameInsets;
    var border:Scale1BitmapBorder = Scale1BitmapBorder(this.border);

    var isLast:Boolean = false;
    const isFirst:Boolean = itemIndex == 0;
    if (isFirst) {
      frameInsets.left = -2;
      frameInsets.right = 0;
    }
    else {
      frameInsets.left = 0;
      isLast = this.isLast;
      frameInsets.right = isLast ? -2 : 0;
    }

    labelHelper.validate();
    labelHelper.moveToHCenterByInsets(w, h, border.contentInsets);

    var g:Graphics = graphics;
    g.clear();

    const offset:int = ((state & HIGHLIGHTED) != 0) ? (selected ? BitmapBorderStateIndex.ON_HIGHLIGHT : BitmapBorderStateIndex.OFF_HIGHLIGHT) : (selected ? BitmapBorderStateIndex.ON : BitmapBorderStateIndex.OFF);
    const computedSepatatorIndex:int = separatorIndex + (offset % 2);

    var bitmaps:Vector.<BitmapData> = border.getBitmaps();
    var backgroundWidth:Number;
    var rightWidth:Number;
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

      if (isLast) {
        rightWidth = bitmaps[rightIndex + offset].width;
        backgroundWidth = w - rightWidth - frameInsets.right;
      }
      else {
        backgroundWidth = w;
      }
    }

    frameInsets.top = h;
    border.bitmapIndex = shadowIndex;
    border.draw(g, (isLast ? backgroundWidth : (backgroundWidth + 1)) + frameInsets.left + frameInsets.right, h);
    frameInsets.top = 0;

    border.bitmapIndex = middleIndex + offset;
    border.draw(g, backgroundWidth + frameInsets.left + frameInsets.right, h - 3);

    if (isLast) {
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