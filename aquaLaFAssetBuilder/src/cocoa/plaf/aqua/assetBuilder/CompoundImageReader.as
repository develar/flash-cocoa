package cocoa.plaf.aqua.assetBuilder {
import cocoa.Border;
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.border.BorderStateIndex;
import cocoa.border.OneBitmapBorder;
import cocoa.border.Scale1BitmapBorder;
import cocoa.border.Scale3EdgeHBitmapBorder;
import cocoa.border.Scale9EdgeBitmapBorder;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

import mx.core.BitmapAsset;

internal final class CompoundImageReader {
  private var rowsInfo:Vector.<RowInfo>;
  private var compoundBitmapData:BitmapData;

  private var borders:Vector.<Border>;

  private const sliceCalculator:SliceCalculator = new SliceCalculator();

  private var assetsBitmapData:BitmapData;

  public function CompoundImageReader(borders:Vector.<Border>) {
    this.borders = borders;
  }

  public function read(bitmapDataClass:Class, rowsInfo:Vector.<RowInfo>):void {
    this.rowsInfo = rowsInfo;

    assetsBitmapData = compoundBitmapData = BitmapAsset(new bitmapDataClass()).bitmapData;

    var rowCount:int = rowsInfo.length;
    for (var row:int = 0; row < rowCount; row++) {
      var rowInfo:RowInfo = rowsInfo[row];
      var frameRectangle:Rectangle = getSliceFrameRectangle(row, 0);
      assertSiblings(frameRectangle, row);

      var sliceSize:Insets = sliceCalculator.calculate(compoundBitmapData, frameRectangle, rowInfo.top, false, false);
      var bitmaps:Vector.<BitmapData> = slice3H(frameRectangle, sliceSize, rowInfo.top, rowInfo.width, 3 /* off, on, disabled */);

      borders[rowInfo.index] = Scale3EdgeHBitmapBorder(rowInfo.border).configure(bitmaps);
    }
  }

  public function readScale3(bitmapDataClass:Class, border:Scale3EdgeHBitmapBorder, borderPosition:int):void {
    compoundBitmapData = BitmapAsset(new bitmapDataClass()).bitmapData;
    var frameRectangle:Rectangle = compoundBitmapData.getColorBoundsRect(0xff000000, 0x00000000, false);

    var sliceSize:Insets = sliceCalculator.calculate(compoundBitmapData, frameRectangle, frameRectangle.top, false, false);
    var bitmaps:Vector.<BitmapData> = slice3H(frameRectangle, sliceSize);
    border.configure(bitmaps);

    borders[borderPosition] = border;
  }

  public function readTitleBarAndContent(bitmapDataClass:Class, border:Scale3EdgeHBitmapBorder, borderPosition:int):void {
    compoundBitmapData = BitmapAsset(new bitmapDataClass()).bitmapData;
    var frameRectangle:Rectangle = compoundBitmapData.getColorBoundsRect(0xff000000, 0x00000000, false);

    var sliceSize:Insets = sliceCalculator.calculate(compoundBitmapData, frameRectangle, frameRectangle.top, true, false);
    frameRectangle.height = sliceCalculator.calculateFromTop(compoundBitmapData, frameRectangle);

    var bitmaps:Vector.<BitmapData> = slice3H(frameRectangle, sliceSize);
    border.configure(bitmaps);

    borders[borderPosition] = border;
  }

  public function readMenu(icons:ByteArray, bitmapDataClass:Class, listBorder:Scale9EdgeBitmapBorder, itemHeight:Number):void {
    compoundBitmapData = BitmapAsset(new bitmapDataClass()).bitmapData;
    var frameRectangle:Rectangle = compoundBitmapData.getColorBoundsRect(0xff000000, 0x00000000, false);

    // item background
    const firstItemY:Number = -listBorder.frameInsets.top + listBorder.contentInsets.top + frameRectangle.top;
    const itemX:Number = -listBorder.frameInsets.left + listBorder.contentInsets.left + frameRectangle.x;
    var itemRectangle:Rectangle = new Rectangle(itemX, firstItemY, 1, itemHeight);
    borders[BorderPosition.menuItem] = OneBitmapBorder.create(createBitmapData(itemRectangle), new Insets(21, NaN, 21, 5));

    // checkmarks
    itemRectangle.x += 5;
    itemRectangle.y += 3;
    itemRectangle.width = 10;
    itemRectangle.height = 10;

    writeIcon(icons, "MenuItem.onStateIcon.highlighted", itemRectangle);
    itemRectangle.y += itemHeight;
    writeIcon(icons, "MenuItem.onStateIcon", itemRectangle);

    // clear item background
    itemRectangle.x = itemX;
    itemRectangle.y = firstItemY;
    itemRectangle.width = frameRectangle.right - (-listBorder.frameInsets.right + listBorder.contentInsets.right) - itemX;
    itemRectangle.height = (itemHeight * 2) + 12 /* separator item */;
    compoundBitmapData.fillRect(itemRectangle, 0);

    listBorder.configure(parseScale9Grid(frameRectangle));
    borders[BorderPosition.menu] = listBorder;
  }

  private function writeIcon(data:ByteArray, name:String, sourceRectangle:Rectangle):void {
    data.writeUTF(name);
    data.writeByte(sourceRectangle.width);
    data.writeByte(sourceRectangle.height);
    data.writeBytes(compoundBitmapData.getPixels(sourceRectangle));
  }

  public function parseScale9Grid(frameRectangle:Rectangle, sliceSize:Insets = null, equalLength:int = -1):Vector.<BitmapData> {
    if (sliceSize == null) {
      sliceSize = sliceCalculator.calculate(compoundBitmapData, frameRectangle, 0, true, true, equalLength);
    }
    var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>(4, true);

    var sliceRectangle:Rectangle = new Rectangle(frameRectangle.x, frameRectangle.y, sliceSize.left + 1, sliceSize.top + 1);
    bitmaps[0] = createBitmapData(sliceRectangle);

    const rightX:Number = frameRectangle.right - sliceSize.right;
    sliceRectangle.x = rightX;
    sliceRectangle.width = sliceSize.right;
    bitmaps[1] = createBitmapData(sliceRectangle);

    sliceRectangle.x = frameRectangle.x;
    sliceRectangle.y = frameRectangle.bottom - sliceSize.bottom;
    sliceRectangle.width = sliceSize.left + 1;
    sliceRectangle.height = sliceSize.bottom;
    bitmaps[2] = createBitmapData(sliceRectangle);

    sliceRectangle.x = rightX;
    sliceRectangle.width = sliceSize.right;
    bitmaps[3] = createBitmapData(sliceRectangle);

    return bitmaps;
  }

  private function createBitmapData(sourceRectangle:Rectangle):BitmapData {
    var bitmapData:BitmapData = new BitmapData(sourceRectangle.width, sourceRectangle.height, true, 0);
    bitmapData.copyPixels(compoundBitmapData, sourceRectangle, new Point(), null, null, true);
    return bitmapData;
  }

  private function crop(bitmapData:BitmapData):BitmapData {
    var frameRectangle:Rectangle = bitmapData.getColorBoundsRect(0xff000000, 0x00000000, false);
    if (frameRectangle.width != bitmapData.width || frameRectangle.height != bitmapData.height) {
      compoundBitmapData = bitmapData;
      bitmapData = createBitmapData(frameRectangle);
      compoundBitmapData = assetsBitmapData;
    }

    return bitmapData;
  }

  public function readTreeIcons(bitmapDataClass:Class, openFrameInsets:FrameInsets, closeFrameInsets:FrameInsets):void {
    compoundBitmapData = assetsBitmapData = BitmapAsset(new bitmapDataClass()).bitmapData;

    var sourceBitmaps:Vector.<BitmapData> = sliceH(15);
    borders[BorderPosition.treeDisclosureSideBar] = Scale1BitmapBorder.create(createTreeDisclosureIcon(sourceBitmaps, false), null, openFrameInsets);
    borders[BorderPosition.treeDisclosureSideBar + 1] = Scale1BitmapBorder.create(createTreeDisclosureIcon(sourceBitmaps, true), null, closeFrameInsets);
  }

  // off, off h, on, on h
  // skip open/close on h
  private static function createTreeDisclosureIcon(input:Vector.<BitmapData>, expanded:Boolean):Vector.<BitmapData> {
    var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>(4, true);
    var offset:int = expanded ? 6 : 0;
    bitmaps[BorderStateIndex.OFF] = input[offset];
    bitmaps[BorderStateIndex.OFF_SELECTING] = input[expanded ? 14 : 12];
    bitmaps[BorderStateIndex.ON] = input[offset + 2];
    return bitmaps;
  }

  private function sliceH(count:int):Vector.<BitmapData> {
    var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>(count, true);
    var rowWidth:Number = compoundBitmapData.width / count;
    var rectangle:Rectangle = new Rectangle(0, 0, rowWidth, compoundBitmapData.height);
    for (var i:int = 0, n:int = bitmaps.length; i < n; i++,rectangle.x += rowWidth) {
      bitmaps[i] = crop(createBitmapData(rectangle));
    }

    return bitmaps;
  }

  private function slice3H(frameRectangle:Rectangle, sliceSize:Insets, rowTop:Number = 0, rowWidth:Number = NaN, count:int = 1):Vector.<BitmapData> {
    var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>(count * 2, true);

    const relativeRightBitmapX:int = frameRectangle.width - sliceSize.right;
    const top:Number = rowTop + frameRectangle.top;
    // x как 0, актуальное значение устанавливается в цикле
    var leftWithCenterRectangle:Rectangle = new Rectangle(0, top, sliceSize.left + 1, frameRectangle.height);
    var rightRectangle:Rectangle = new Rectangle(0, top, sliceSize.right, frameRectangle.height);

    var x:Number = frameRectangle.left;
    for (var i:int = 0, n:int = bitmaps.length; i < n; x += rowWidth) {
      leftWithCenterRectangle.x = x;
      bitmaps[i++] = createBitmapData(leftWithCenterRectangle);
      rightRectangle.x = x + relativeRightBitmapX;
      bitmaps[i++] = createBitmapData(rightRectangle);
    }

    return bitmaps;
  }

  private function getSliceBitmapData(row:int, column:int):BitmapData {
    var rowInfo:RowInfo = rowsInfo[row];
    var sliceBitmapData:BitmapData = new BitmapData(rowInfo.width, rowInfo.height, true, 0);
    sliceBitmapData.copyPixels(compoundBitmapData, new Rectangle(column * rowInfo.width, rowInfo.top, rowInfo.width, rowInfo.height), new Point(), null, null, true);
    return sliceBitmapData;
  }

  private function getSliceFrameRectangle(row:int, column:int):Rectangle {
    return getSliceBitmapData(row, column).getColorBoundsRect(0xff000000, 0x00000000, false);
  }

  private function assertSiblings(frameRectangle:Rectangle, row:int):void {
    var count:int = 3;
    for (var column:int = 1; column < count; column++) {
      var sliceContentInsets:Rectangle = getSliceFrameRectangle(row, column);

      var xDiff:int = sliceContentInsets.x - frameRectangle.x;
      if (xDiff > 0) {
        sliceContentInsets.width += xDiff;
        sliceContentInsets.x -= xDiff; // в данном случае просто мы возьмем чуть больше чем надо — это нормально (для rounded disabled state так)
        if (sliceContentInsets.width < frameRectangle.width) {
          sliceContentInsets.width = frameRectangle.width;
        }
      }

      if (sliceContentInsets.width != 0 /* для некоторых state может быть пропущен */ && !frameRectangle.equals(sliceContentInsets)) {
        throw new Error("why? " + frameRectangle + " vs " + sliceContentInsets);
      }
    }
  }
}
}