package cocoa.plaf.aqua {
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
  private static const firstIndex:int = 0;
  private static const middleIndex:int = firstIndex + 4;
  private static const lastIndex:int = middleIndex + 4;
  private static const separatorIndex:int = lastIndex + 4;

  protected var border:Scale1BitmapBorder;

  public function SegmentRendererManager(laf:LookAndFeel, lafKey:String) {
    border = Scale1BitmapBorder(laf.getBorder(lafKey + "." + (laf.controlSize || "regular")));
    super(laf.getTextFormat(laf.controlSize == null ? TextFormatId.SYSTEM : TextFormatId.SMALL_SYSTEM), border.contentInsets);
  }

  override protected function drawEntry(entry:TextLineAndDisplayObjectEntry, itemIndex:int, g:Graphics, w:int, h:int, x:Number, y:Number):void {
    draw(itemIndex, g, _lastCreatedRendererDimension, h, false, _selectionModel.isItemSelected(itemIndex));
  }

  /**
   * Мы должны быть осторожны при отрисовке и учитывать, чтобы было корректное перекрытие разделителей.
   * Поэтому всегда (за исключением последнего элемента) отрисовываем разделитель справа, а слева только если мы selected (нет разницы — highlighted или нет).
   * Так как мы добавляем элементы слева направо — самый левый имеет самый маленький индекс в display list,
   * то при отрисовке левого разделителя при selected Flash Player корректно отрисует его над старым разделителем (который отрисован предыдущим элементом).
   *
   * Но у нас есть полупрозрачные пиксели — при наложении получается плохо — поэтому background и separator по высоте меньше на 3 пикселя по высоте (снизу), мы отрисовываем их сами программно
   *
   * update: в Mac OS X Lion — сепараторы тоже имеют прозрачность, так что никакого "мы отрисовываем их сами программно" нет
   */
  private function draw(itemIndex:int, g:Graphics, w:int, h:int, selecting:Boolean, selected:Boolean):void {
    const offset:int = selecting ? (selected ? BorderStateIndex.ON_SELECTING : BorderStateIndex.OFF_SELECTING) : (selected ? BorderStateIndex.ON : BorderStateIndex.OFF);
    const computedSeparatorIndex:int = separatorIndex + (offset % 2);

    var last:Boolean = false;
    const first:Boolean = isFirst(itemIndex);
    var bitmaps:Vector.<BitmapData> = border.getBitmaps();
    var backgroundWidth:int;
    var backgroundX:int = 0;
    if (first) {
      border.bitmapIndex = firstIndex + offset;
      backgroundX = bitmaps[firstIndex + offset].width;
      border.draw(g, backgroundX, NaN);

      backgroundWidth = w - backgroundX;
    }
    else {
      if (selected) {
        border.bitmapIndex = computedSeparatorIndex;
        border.draw(g, 1, NaN, -1);
      }

      last = isLast(itemIndex);
      backgroundWidth = last ? w - bitmaps[lastIndex + offset].width : w;
    }

    border.bitmapIndex = middleIndex + offset;
    border.draw(g, backgroundWidth, NaN, backgroundX);

    if (last) {
      border.bitmapIndex = lastIndex + offset;
      border.draw(g, NaN, NaN, backgroundWidth);
    }
    else {
      border.bitmapIndex = computedSeparatorIndex;
      border.draw(g, 1, NaN, w);
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

  override public function setSelected(itemIndex:int, relatedIndex:int, value:Boolean):void {
    super.setSelected(itemIndex, relatedIndex, value);

    drawOnInteract(itemIndex, false, value);
    selectingItemIndex = -1;
  }
}
}
