package cocoa.plaf.aqua.assetBuilder
{
import cocoa.Border;
import cocoa.FrameInsets;
import cocoa.Icon;
import cocoa.Insets;
import cocoa.plaf.BitmapIcon;
import cocoa.border.OneBitmapBorder;
import cocoa.border.Scale3EdgeHBitmapBorder;
import cocoa.border.Scale3HBitmapBorder;
import cocoa.border.Scale3VBitmapBorder;
import cocoa.border.Scale9BitmapBorder;

import flash.display.Bitmap;
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
			var bitmaps:Vector.<BitmapData> = slice3H(frameRectangle, sliceSize, rowInfo.top, rowInfo.width, 3 /* off, on, disabled */);

			borders[position + row] = Scale3EdgeHBitmapBorder(rowInfo.border).configure(bitmaps);
		}

		position += rowsInfo.length;
	}

	public function readButtonAdditionalBitmaps(border:Scale3EdgeHBitmapBorder, additionalBitmaps:Vector.<Class>):void
	{
		additionalBitmaps.fixed = true;
		var n:int = additionalBitmaps.length;
		var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>(n - (n / 3), true);
		for (var i:int = 0, bitmapIndex:int = 0; i < n; i += 3)
		{
			var left:BitmapData = Bitmap(new additionalBitmaps[i]).bitmapData;
			var bitmapData:BitmapData = new BitmapData(left.width + 1, left.height, true, 0);
			bitmapData.copyPixels(left, left.rect, sharedPoint, null, null, true);

			sharedPoint.x += left.width;
			var right:BitmapData = Bitmap(new additionalBitmaps[i + 1]).bitmapData;
			bitmapData.copyPixels(right, right.rect, sharedPoint, null, null, true);
			sharedPoint.x = 0;

			bitmaps[bitmapIndex++] = bitmapData;
			bitmaps[bitmapIndex++] = Bitmap(new additionalBitmaps[i + 2]).bitmapData;
		}

		borders[position++] = border.configure(bitmaps);
	}

	public function readScale3(bitmapDataClass:Class, border:Scale3EdgeHBitmapBorder):void
	{
		compoundBitmapData = BitmapAsset(new bitmapDataClass()).bitmapData;
		var frameRectangle:Rectangle = compoundBitmapData.getColorBoundsRect(0xff000000, 0x00000000, false);

		var sliceSize:Insets = sliceCalculator.calculate(compoundBitmapData, frameRectangle, frameRectangle.top, false, false);
		var bitmaps:Vector.<BitmapData> = slice3H(frameRectangle, sliceSize);
		border.configure(bitmaps);

		borders[position++] = border;
	}

	public function readTitleBarAndContent(bitmapDataClass:Class, border:Scale3EdgeHBitmapBorder):void
	{
		compoundBitmapData = BitmapAsset(new bitmapDataClass()).bitmapData;
		var frameRectangle:Rectangle = compoundBitmapData.getColorBoundsRect(0xff000000, 0x00000000, false);

		var sliceSize:Insets = sliceCalculator.calculate(compoundBitmapData, frameRectangle, frameRectangle.top, true, false);
		frameRectangle.height = sliceCalculator.calculateFromTop(compoundBitmapData, frameRectangle);

		var bitmaps:Vector.<BitmapData> = slice3H(frameRectangle, sliceSize);
		border.configure(bitmaps);

		borders[position++] = border;
	}

	/**
	 * 2 (v and h) track, 4 h/v decrement button (normal and highlighted), 4 h/v increment button (normal and highlighted),
	 * v/h thumb, v/h off track
	 */
	public function readScrollbar():void
	{
		compoundBitmapData = assetsBitmapData;

		const scrollViewWidth:Number = 120;
		const scrollViewRightPadding:Number = 10;
		const scrollViewWidthWithPaddings:Number = scrollViewWidth + scrollViewRightPadding;

		const thickness:Number = 15;

		const incrementArrowLocalPosition:Number = 89;
		const incrementHArrowWidth:Number = 16;

		const vArrowLocalPosition:Number = scrollViewWidth - thickness;

		const decrementArrowLocalPosition:Number = 61;

		const scrollViewAbsoluteY:Number = 192;

		// v track
		var itemRectangle:Rectangle = new Rectangle(vArrowLocalPosition, scrollViewAbsoluteY, thickness, 25);
		itemRectangle.height = sliceCalculator.calculateFromTop(compoundBitmapData, itemRectangle) + 1;
		borders[position++] = OneBitmapBorder.create(createBitmapData(itemRectangle), new Insets(0, 7));

		// h track
		itemRectangle.x = 0;
		itemRectangle.y += vArrowLocalPosition;
		itemRectangle.width = 25;
		itemRectangle.height = thickness;
		itemRectangle.width = sliceCalculator.calculateFromLeft(compoundBitmapData, itemRectangle) + 1;
		borders[position++] = OneBitmapBorder.create(createBitmapData(itemRectangle), new Insets(7));

		// h d button, normal
		itemRectangle.x = decrementArrowLocalPosition;
		itemRectangle.width = 28;
		borders[position++] = OneBitmapBorder.create(createBitmapData(itemRectangle));
		// h d button, highlighted
		itemRectangle.x = 321;
		borders[position++] = OneBitmapBorder.create(createBitmapData(itemRectangle));

		// h i button, normal
		itemRectangle.x = incrementArrowLocalPosition;
		itemRectangle.width = incrementHArrowWidth;
		borders[position++] = OneBitmapBorder.create(createBitmapData(itemRectangle));
		// h i button, highlighted
		itemRectangle.width += 1;
		itemRectangle.x = (scrollViewWidthWithPaddings * 3) + incrementArrowLocalPosition - 1;
		borders[position++] = OneBitmapBorder.create(createBitmapData(itemRectangle), null, new FrameInsets(-1));

		// v d button, normal
		itemRectangle.x = vArrowLocalPosition;
		itemRectangle.y = scrollViewAbsoluteY + decrementArrowLocalPosition;
		itemRectangle.width = thickness;
		itemRectangle.height = 28;
		borders[position++] = OneBitmapBorder.create(createBitmapData(itemRectangle), null, new FrameInsets(0, -11));
		// v d button, highlighted
		itemRectangle.x = (scrollViewWidthWithPaddings * 2) + vArrowLocalPosition;
		borders[position++] = OneBitmapBorder.create(createBitmapData(itemRectangle), null, new FrameInsets(0, -11)); // todo serialize frameinsets as one, not twice

		// v i button, normal
		itemRectangle.x = vArrowLocalPosition;
		itemRectangle.y = scrollViewAbsoluteY + incrementArrowLocalPosition;
		itemRectangle.width = thickness;
		itemRectangle.height = 16;
		borders[position++] = OneBitmapBorder.create(createBitmapData(itemRectangle));
		// v i button, highlighted
		itemRectangle.y -= 1;
		itemRectangle.height += 1;
		itemRectangle.x = (scrollViewWidthWithPaddings * 3) + vArrowLocalPosition;
		borders[position++] = OneBitmapBorder.create(createBitmapData(itemRectangle), null, new FrameInsets(0, -1));


		const scrollViewForThumbWidth:Number = 127;
		// v thumb
		const thumbEdgeSegmentSize:Number = 12 + 3 /* альфа */;
		const thumbMiddleSegmentSize:Number = 16;
		itemRectangle.x = (scrollViewWidthWithPaddings * 4) + scrollViewForThumbWidth - thickness;
		itemRectangle.y = 189;
		itemRectangle.width = thickness;
		itemRectangle.height = thumbEdgeSegmentSize;

		var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>(3, true);
		bitmaps[0] = createBitmapData(itemRectangle);

		itemRectangle.y += thumbEdgeSegmentSize + (thumbMiddleSegmentSize * 2);
		itemRectangle.height = thumbMiddleSegmentSize;
		bitmaps[1] = createBitmapData(itemRectangle);

		itemRectangle.y += thumbMiddleSegmentSize;
		itemRectangle.height = thumbEdgeSegmentSize;
		bitmaps[2] = createBitmapData(itemRectangle);
		borders[position++] = Scale3VBitmapBorder.create(new FrameInsets(0, -3, 0, -3)).configure(bitmaps);

		// h thumb
		itemRectangle.x = (scrollViewWidthWithPaddings * 4) + 4;
		itemRectangle.y = 297;
		itemRectangle.width = thumbEdgeSegmentSize;
		itemRectangle.height = thickness;

		bitmaps = new Vector.<BitmapData>(3, true);
		bitmaps[0] = createBitmapData(itemRectangle);

		itemRectangle.x += thumbEdgeSegmentSize + (thumbMiddleSegmentSize * 2);
		itemRectangle.width = thumbMiddleSegmentSize;
		bitmaps[1] = createBitmapData(itemRectangle);

		itemRectangle.x += thumbMiddleSegmentSize;
		itemRectangle.width = thumbEdgeSegmentSize;
		bitmaps[2] = createBitmapData(itemRectangle);
		borders[position++] = Scale3HBitmapBorder.create(new FrameInsets(-3, 0, -3, 0)).configure(bitmaps);

		// track v off
		itemRectangle.x = scrollViewWidthWithPaddings + vArrowLocalPosition;
		itemRectangle.y = scrollViewAbsoluteY;
		itemRectangle.width = thickness;
		itemRectangle.height = 1;
		borders[position++] = OneBitmapBorder.create(createBitmapData(itemRectangle));

		// track h off
		itemRectangle.x = scrollViewWidthWithPaddings;
		itemRectangle.y = scrollViewAbsoluteY + vArrowLocalPosition;
		itemRectangle.width = 1;
		itemRectangle.height = thickness;
		borders[position++] = OneBitmapBorder.create(createBitmapData(itemRectangle));
	}

	public function readMenu(icons:Vector.<Icon>, bitmapDataClass:Class, listBorder:Scale9BitmapBorder, itemHeight:Number):void
	{
		compoundBitmapData = BitmapAsset(new bitmapDataClass()).bitmapData;
		var frameRectangle:Rectangle = compoundBitmapData.getColorBoundsRect(0xff000000, 0x00000000, false);

		// item background
		const firstItemY:Number = -listBorder.frameInsets.top + listBorder.contentInsets.top + frameRectangle.top;
		const itemX:Number = -listBorder.frameInsets.left + listBorder.contentInsets.left + frameRectangle.x;
		var itemRectangle:Rectangle = new Rectangle(itemX, firstItemY, 1, itemHeight);
		borders[position + 1] = OneBitmapBorder.create(createBitmapData(itemRectangle), new Insets(21, NaN, 21, 5));

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

	public function readScale9(bitmapDataClass:Class, border:Scale9BitmapBorder, equalLength:int = -1):void
	{
		compoundBitmapData = BitmapAsset(new bitmapDataClass()).bitmapData;
		var frameRectangle:Rectangle = compoundBitmapData.getColorBoundsRect(0xff000000, 0x00000000, false);

		var bitmaps:Vector.<BitmapData> = parseScale9Grid(frameRectangle, null, equalLength);
		border.configure(bitmaps);

		borders[position++] = border;
	}

	public function parseScale9Grid(frameRectangle:Rectangle, sliceSize:Insets = null, equalLength:int = -1):Vector.<BitmapData>
	{
		if (sliceSize == null)
		{
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

	private function createBitmapData(sourceRectangle:Rectangle):BitmapData
	{
		var bitmapData:BitmapData = new BitmapData(sourceRectangle.width, sourceRectangle.height, true, 0);
		bitmapData.copyPixels(compoundBitmapData, sourceRectangle, sharedPoint, null, null, true);
		return bitmapData;
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