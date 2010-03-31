package cocoa.plaf.aqua.assetBuilder
{
import cocoa.Border;
import cocoa.Icon;
import cocoa.Insets;
import cocoa.plaf.BitmapIcon;
import cocoa.plaf.Scale1BitmapBorder;
import cocoa.plaf.Scale3HBitmapBorder;
import cocoa.plaf.Scale9BitmapBorder;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.BitmapAsset;

internal final class CompoundImageReader
{
	private static const sharedPoint:Point = new Point(0, 0);

	private var rowsInfo:Vector.<RowInfo>;
	private var compoundBitmapData:BitmapData;

	public var position:int = 0;

	private var borders:Vector.<Border>;

	private const sliceCalculator:SliceCalculator = new SliceCalculator();

	private var assetsBitmapData:BitmapData;

	public function CompoundImageReader(borders:Vector.<Border>)
	{
		this.borders = borders;
	}

	public function read(bitmapDataClass:Class, rowsInfo:Vector.<RowInfo>):void
	{
		this.rowsInfo = rowsInfo;

		assetsBitmapData = compoundBitmapData = BitmapAsset(new bitmapDataClass()).bitmapData;

		var rowCount:int = rowsInfo.length;
		for (var row:int = 0; row < rowCount; row++)
		{
			var rowInfo:RowInfo = rowsInfo[row];
			var frameRectangle:Rectangle = getSliceFrameRectangle(row, 0);
			assertSiblings(frameRectangle, row);

			var sliceSize:Insets = sliceCalculator.calculate(compoundBitmapData, frameRectangle, rowInfo.top, false, false);
			var bitmaps:Vector.<BitmapData> = slice3HGrid(frameRectangle, sliceSize, rowInfo);
			Scale3HBitmapBorder(rowInfo.border).configure(sliceSize, bitmaps);

			borders[position + row] = rowInfo.border;
		}

		position += rowsInfo.length;
	}

	public function readScale3(bitmapDataClass:Class, border:Scale3HBitmapBorder):void
	{
		compoundBitmapData = BitmapAsset(new bitmapDataClass()).bitmapData;
		var frameRectangle:Rectangle = compoundBitmapData.getColorBoundsRect(0xff000000, 0x00000000, false);

		var sliceSize:Insets = sliceCalculator.calculate(compoundBitmapData, frameRectangle, frameRectangle.top, false, false);
		var bitmaps:Vector.<BitmapData> = slice3H(frameRectangle, sliceSize);
		border.configure(sliceSize, bitmaps);

		borders[position++] = border;
	}

	public function readScrollbar():void
	{
		compoundBitmapData = assetsBitmapData;


	}

	public function readMenu(icons:Vector.<Icon>, bitmapDataClass:Class, listBorder:Scale9BitmapBorder, itemHeight:Number):void
	{
		compoundBitmapData = BitmapAsset(new bitmapDataClass()).bitmapData;
		var frameRectangle:Rectangle = compoundBitmapData.getColorBoundsRect(0xff000000, 0x00000000, false);

		const firstItemY:Number = -listBorder.frameInsets.top + listBorder.contentInsets.top + frameRectangle.top;
		const itemX:Number = -listBorder.frameInsets.left + listBorder.contentInsets.left + frameRectangle.x;
		var itemRectangle:Rectangle = new Rectangle(itemX, firstItemY, 1, itemHeight);
		var itemBitmaps:Vector.<BitmapData> = new Vector.<BitmapData>(1, true);
		itemBitmaps[0] = createBitmapData(itemRectangle);
		borders[position + 1] = Scale1BitmapBorder.create(itemBitmaps, itemHeight, new Insets(21, NaN, 21, 5));

		// checkmarks
		itemRectangle.x += 5;
		itemRectangle.y += 3;
		itemRectangle.width = 10;
		itemRectangle.height = 10;
		icons[1] = BitmapIcon.create(createBitmapData(itemRectangle));
		itemRectangle.y += itemHeight;
		icons[0] = BitmapIcon.create(createBitmapData(itemRectangle));

		// clear item background
		itemRectangle.x = itemX;
		itemRectangle.y = firstItemY;
		itemRectangle.width = frameRectangle.right - (-listBorder.frameInsets.right + listBorder.contentInsets.right) - itemX;
		itemRectangle.height = (itemHeight * 2) + 12 /* separator item */;
		compoundBitmapData.fillRect(itemRectangle, 0);

		listBorder.configure(parseScale9Grid(frameRectangle));
		borders[position] = listBorder;

		position += 2;
	}

	public function parseScale9Grid(frameRectangle:Rectangle, sliceSize:Insets = null):Vector.<BitmapData>
	{
		if (sliceSize == null)
		{
			sliceSize = sliceCalculator.calculate(compoundBitmapData, frameRectangle, 0, true, true);
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

	private function createBitmapData(sourceRectangle:Rectangle):BitmapData
	{
		var bitmapData:BitmapData = new BitmapData(sourceRectangle.width, sourceRectangle.height, true, 0);
		bitmapData.copyPixels(compoundBitmapData, sourceRectangle, sharedPoint, null, null, true);
		return bitmapData;
	}

	private function slice3HGrid(frameRectangle:Rectangle, sliceSize:Insets, rowInfo:RowInfo):Vector.<BitmapData>
	{
		return slice3H(frameRectangle, sliceSize, rowInfo.top, rowInfo.width, 3);
	}

	private function slice3H(frameRectangle:Rectangle, sliceSize:Insets, rowTop:Number = 0, rowWidth:Number = NaN, count:int = 1):Vector.<BitmapData>
	{
		var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>(count * 2, true);

		const relativeRightBitmapX:int = frameRectangle.width - sliceSize.right;
		const top:Number = rowTop + frameRectangle.top;
		// x как 0, актуальное значение устанавливается в цикле
		var leftWithCenterRectangle:Rectangle = new Rectangle(0, top, sliceSize.left + 1, frameRectangle.height);
		var rightRectangle:Rectangle = new Rectangle(0, top, sliceSize.right, frameRectangle.height);

		var bitmapData:BitmapData;

		var x:Number = frameRectangle.left;
		for (var i:int = 0, n:int = bitmaps.length; i < n; x += rowWidth)
		{
			leftWithCenterRectangle.x = x;

			bitmapData = new BitmapData(leftWithCenterRectangle.width, leftWithCenterRectangle.height, true, 0);
			bitmapData.copyPixels(compoundBitmapData, leftWithCenterRectangle, sharedPoint, null, null, true);
			bitmaps[i++] = bitmapData;

			rightRectangle.x = x + relativeRightBitmapX;

			bitmapData = new BitmapData(rightRectangle.width, rightRectangle.height, true, 0);
			bitmapData.copyPixels(compoundBitmapData, rightRectangle, sharedPoint, null, null, true);
			bitmaps[i++] = bitmapData;
		}

		return bitmaps;
	}

	private function getSliceBitmapData(row:int, column:int):BitmapData
	{
		var rowInfo:RowInfo = rowsInfo[row];
		var sliceBitmapData:BitmapData = new BitmapData(rowInfo.width, rowInfo.height, true, 0);
		sliceBitmapData.copyPixels(compoundBitmapData, new Rectangle(column * rowInfo.width, rowInfo.top, rowInfo.width, rowInfo.height), sharedPoint, null, null, true);
		return sliceBitmapData;
	}

	private function getSliceFrameRectangle(row:int, column:int):Rectangle
	{
		return getSliceBitmapData(row, column).getColorBoundsRect(0xff000000, 0x00000000, false);
	}

	private function assertSiblings(frameRectangle:Rectangle, row:int):void
	{
		var count:int = 3;
		for (var column:int = 1; column < count; column++)
		{
			var sliceContentInsets:Rectangle = getSliceFrameRectangle(row, column);

			var xDiff:int = sliceContentInsets.x - frameRectangle.x;
			if (xDiff > 0)
			{
				sliceContentInsets.width += xDiff;
				sliceContentInsets.x -= xDiff; // в данном случае просто мы возьмем чуть больше чем надо — это нормально (для rounded disabled state так)
				if (sliceContentInsets.width < frameRectangle.width)
				{
					sliceContentInsets.width = frameRectangle.width;
				}
			}

			if (sliceContentInsets.width != 0 /* для некоторых state может быть пропущен */ && !frameRectangle.equals(sliceContentInsets))
			{
				throw new Error("why? " + frameRectangle + " vs " + sliceContentInsets);
			}
		}
	}
}
}