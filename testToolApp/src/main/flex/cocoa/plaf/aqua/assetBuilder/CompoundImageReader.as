package cocoa.plaf.aqua.assetBuilder
{
import cocoa.Border;
import cocoa.Icon;
import cocoa.Insets;
import cocoa.plaf.BitmapIcon;
import cocoa.plaf.Scale1HBitmapBorder;
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

	private var position:int = 0;

	private var borders:Vector.<Border>;

	public function CompoundImageReader(borders:Vector.<Border>)
	{
		this.borders = borders;
	}

	public function read(bitmapDataClass:Class, rowsInfo:Vector.<RowInfo>):void
	{
		this.rowsInfo = rowsInfo;

		compoundBitmapData = BitmapAsset(new bitmapDataClass()).bitmapData;

		var rowCount:int = rowsInfo.length;
		for (var row:int = 0; row < rowCount; row++)
		{
			var rowInfo:RowInfo = rowsInfo[row];
			var frameRectangle:Rectangle = getSliceFrameRectangle(row, 0);
			assertSiblings(frameRectangle, row);

			var sliceSize:Insets = calculateSliceSize(frameRectangle, rowInfo.top, false, false);
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

		var sliceSize:Insets = calculateSliceSize(frameRectangle, frameRectangle.top, false, false);
		var bitmaps:Vector.<BitmapData> = slice3H(frameRectangle, sliceSize);
		border.configure(sliceSize, bitmaps);

		borders[position++] = border;
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
		borders[position + 1] = Scale1HBitmapBorder.create(itemBitmaps, itemHeight, new Insets(21, NaN, 21, 5));

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

		var sliceSize:Insets = calculateSliceSize(frameRectangle, 0, true, true);
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

		listBorder.configure(bitmaps);
		borders[position] = listBorder;

		position += 2;
	}

	private function createBitmapData(sourceRectangle:Rectangle):BitmapData
	{
		var bitmapData:BitmapData = new BitmapData(sourceRectangle.width, sourceRectangle.height, true, 0);
		bitmapData.copyPixels(compoundBitmapData, sourceRectangle, sharedPoint, null, null, true);
		return bitmapData;
	}

	private function calculateSliceSize(frameRectangle:Rectangle, top:int, strict:Boolean, allSide:Boolean):Insets
	{
		frameRectangle.y += top;

		var pixels:Vector.<uint> = compoundBitmapData.getVector(frameRectangle);
		pixels.fixed = true;
		var width:int = frameRectangle.width;
		var height:int = frameRectangle.height;

		var sliceSize:Insets = new Insets(getUnrepeatableFromLeft(pixels, width, height, strict), allSide ? getUnrepeatableFromTop(pixels, width, height, strict) : 0,
				getUnrepeatableFromRight(pixels, width, height, strict), allSide ? getUnrepeatableFromBottom(pixels, width, height, strict) : 0);

		frameRectangle.y -= top;

		if (sliceSize.width == frameRectangle.width || (allSide && sliceSize.height == frameRectangle.height))
		{
			throw new Error("can't find center area");
		}

		// мы не assertSiblings, так как 1) нам лениво 2) первый идет как up state — там и так всегда максимум отступа
		return sliceSize;
	}

	private function getUnrepeatableFromLeft(pixels:Vector.<uint>, width:int, height:int, strict:Boolean):int
	{
		columnLoop : for (var column:int = 0, maxColumn:int = width - 2; column < maxColumn; column++)
		{
			for (var i:int = column, n:int = (width * height) - width + 1; i < n; i += width)
			{
				if (!equalColor(pixels[i], pixels[i + 1], strict))
				{
					continue columnLoop;
				}
			}

			return column;
		}

		throw new Error("can't find center area");
	}

	private function getUnrepeatableFromRight(pixels:Vector.<uint>, width:int, height:int, strict:Boolean):int
	{
		columnLoop : for (var column:int = width - 1; column > 1; column--)
		{
			for (var i:int = column, n:int = (width * height) - width + 1; i < n; i += width)
			{
				if (!equalColor(pixels[i], pixels[i - 1], strict))
				{
					continue columnLoop;
				}
			}

			return width - (column + 1);
		}

		throw new Error("can't find center area");
	}

	private function getUnrepeatableFromTop(pixels:Vector.<uint>, width:int, height:int, strict:Boolean):int
	{
		rowLoop : for (var row:int = 0, maxRow:int = height - 1; row < maxRow; row++)
		{
			for (var i:int = row * width, n:int = i + width; i < n; i++)
			{
				if (!equalColor(pixels[i], pixels[i + width], strict))
				{
					continue rowLoop;
				}
			}

			return row;
		}

		throw new Error("can't find center area");
	}

	private function getUnrepeatableFromBottom(pixels:Vector.<uint>, width:int, height:int, strict:Boolean):int
	{
		rowLoop : for (var row:int = height - 1; row > 0; row--)
		{
			for (var i:int = row * width, n:int = i + width; i < n; i++)
			{
				if (!equalColor(pixels[i], pixels[i - width], strict))
				{
					continue rowLoop;
				}
			}

			return height - (row + 1);
		}

		throw new Error("can't find center area");
	}

	/**
	 * в силу непонятных причин какой-либо из компонент цвета может отличаться на единицу это другого — поэтому мы считаем отклонение на единицу компонента цвета нормальным
	 */
	private function equalColor(c1:uint, c2:uint, strict:Boolean):Boolean
	{
		if (c1 == c2)
		{
			return true;
		}
		else if (strict || (((c1 & 0xff000000) >>> 24) != ((c2 & 0xff000000) >>> 24)))
		{
			return false;
		}
		else
		{
			var rDiff:int = ((c1 & 0x00ff0000) >>> 16) - ((c2 & 0x00ff0000) >>> 16);
			if (rDiff > 1 || rDiff < -1)
			{
				return false;
			}

			var gDiff:int = ((c1 & 0x0000FF00) >>> 8) - ((c2 & 0x0000FF00) >>> 8);
			if (gDiff > 1 || gDiff < -1)
			{
				return false;
			}
			var bDiff:int = (c1 & 0x000000ff) - (c2 & 0x000000ff);
			//noinspection RedundantIfStatementJS
			if (bDiff > 1 || bDiff < -1)
			{
				return false;
			}

			return true;
		}
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