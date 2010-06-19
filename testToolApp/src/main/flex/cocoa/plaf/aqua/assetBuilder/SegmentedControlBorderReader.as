package cocoa.plaf.aqua.assetBuilder
{
import cocoa.Border;
import cocoa.Insets;
import cocoa.border.BitmapBorderStateIndex;
import cocoa.border.Scale1BitmapBorder;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.BitmapAsset;

/**
 * Информация по этому классу также есть в SegmentItemRenderer#updateDisplayList()
 */
public class SegmentedControlBorderReader
{
	private static const sharedPoint:Point = new Point(0, 0);

	private static const leftIndex:int = 0;
	private static const middleIndex:int = leftIndex + 4;
	private static const rightIndex:int = middleIndex + 4;
	private static const separatorIndex:int = rightIndex + 4;
	private static const shadowIndex:int = separatorIndex + 2;

	private var compoundBitmapData:BitmapData;

	private var frameRectangle:Rectangle;
	private var segmentRectangle:Rectangle;
	private var sourceRectangle:Rectangle;

	private static const firstMiddleAbsoluteX:Number = 18;

	private const segmentBitmaps:Vector.<BitmapData> = new Vector.<BitmapData>(shadowIndex + 1, true);

	private const sliceCalculator:SliceCalculator = new SliceCalculator();

	/**
	 * 4 (off, on, highlight off, highlight on) left, 4 middle, 4 right and 2 separator (off == highlight off, on == highlight on)
	 * В отличие от прочих border, этот нам проще отрисовать самим по логике, — скин будет умным.
	 */
	public function read(bitmapDataClass:Class, bitmapData2Class:Class, bitmapData3Class:Class, bitmapData4Class:Class):Border
	{
		var canvasBitmapData:BitmapData = compoundBitmapData = BitmapAsset(new bitmapDataClass()).bitmapData;

		sourceRectangle = new Rectangle(0, 22, 60, 30);
		compoundBitmapData = createBitmapData(sourceRectangle);
		frameRectangle = compoundBitmapData.getColorBoundsRect(0xff000000, 0x00000000, false);

		var sliceSize:Insets = sliceCalculator.calculate(compoundBitmapData, frameRectangle, 0, false, false);

		segmentBitmaps[leftIndex + BitmapBorderStateIndex.ON] = readLeftSegment(frameRectangle, sliceSize);

		segmentRectangle = new Rectangle(firstMiddleAbsoluteX, frameRectangle.bottom - 3, 1, 3);

		segmentBitmaps[shadowIndex] = createBitmapData(segmentRectangle);

		segmentRectangle.y = frameRectangle.top;
		segmentRectangle.height = frameRectangle.height - 3;

		segmentBitmaps[middleIndex + BitmapBorderStateIndex.ON] = createBitmapData(segmentRectangle);
		segmentRectangle.x += 1;
		segmentBitmaps[separatorIndex + BitmapBorderStateIndex.ON] = createBitmapData(segmentRectangle);
		segmentRectangle.x += 1;
		segmentBitmaps[middleIndex + BitmapBorderStateIndex.OFF] = createBitmapData(segmentRectangle);
		segmentRectangle.x += 16;
		segmentBitmaps[separatorIndex + BitmapBorderStateIndex.OFF] = createBitmapData(segmentRectangle);

		segmentBitmaps[rightIndex + BitmapBorderStateIndex.OFF] = readRightSegment(frameRectangle, sliceSize);

		// next row
		compoundBitmapData = canvasBitmapData;
		sourceRectangle.y += 30;
		compoundBitmapData = createBitmapData(sourceRectangle);

		sliceSize = sliceCalculator.calculate(compoundBitmapData, frameRectangle, 0, false, false);
		segmentBitmaps[leftIndex + BitmapBorderStateIndex.OFF] = readLeftSegment(frameRectangle, sliceSize);

		// next row
		compoundBitmapData = canvasBitmapData;
		sourceRectangle.y += 30;
		compoundBitmapData = createBitmapData(sourceRectangle);

		sliceSize = sliceCalculator.calculate(compoundBitmapData, frameRectangle, 0, false, false);
		segmentBitmaps[rightIndex + BitmapBorderStateIndex.ON] = readRightSegment(frameRectangle, sliceSize);

		readHighlightedSegments(canvasBitmapData, BitmapAsset(new bitmapData2Class()).bitmapData, 3, 5, BitmapBorderStateIndex.OFF_HIGHLIGHT);
		readHighlightedSegments(BitmapAsset(new bitmapData3Class()).bitmapData, BitmapAsset(new bitmapData4Class()).bitmapData, 6, 7, BitmapBorderStateIndex.ON_HIGHLIGHT);

		return Scale1BitmapBorder.create(segmentBitmaps, new Insets(10, NaN, 10, 4));
	}

	// firstMultiplier/lastMultiplier — число controls над разбираемым
	private function readHighlightedSegments(firstCanvasBitmapData:BitmapData, lastCanvasBitmapData:BitmapData, firstMultiplier:int, lastMultiplier:int, highlightOffset:int):void
	{
		compoundBitmapData = firstCanvasBitmapData;
		sourceRectangle.y = 22 + (firstMultiplier * 30);
		compoundBitmapData = createBitmapData(sourceRectangle);

		var sliceSize:Insets = sliceCalculator.calculate(compoundBitmapData, frameRectangle, 0, false, false);
		segmentBitmaps[leftIndex + highlightOffset] = readLeftSegment(frameRectangle, sliceSize);

		segmentRectangle.x = firstMiddleAbsoluteX;
		segmentBitmaps[middleIndex + highlightOffset] = createBitmapData(segmentRectangle);

		// second with last highlighted off
		compoundBitmapData = lastCanvasBitmapData;
		sourceRectangle.y = 22 + (lastMultiplier * 30);
		compoundBitmapData = createBitmapData(sourceRectangle);

		sliceSize = sliceCalculator.calculate(compoundBitmapData, frameRectangle, 0, false, false);
		segmentBitmaps[rightIndex + highlightOffset] = readRightSegment(frameRectangle, sliceSize);
	}

	private function readLeftSegment(frameRectangle:Rectangle, sliceSize:Insets):BitmapData
	{
		var rectangle:Rectangle = new Rectangle(frameRectangle.left, frameRectangle.top, sliceSize.left, frameRectangle.height);
		return createBitmapData(rectangle);
	}

	private function readRightSegment(frameRectangle:Rectangle, sliceSize:Insets):BitmapData
	{
		var rectangle:Rectangle = new Rectangle(frameRectangle.right - sliceSize.right, frameRectangle.top, sliceSize.right, frameRectangle.height);
		return createBitmapData(rectangle);
	}

	private function createBitmapData(sourceRectangle:Rectangle):BitmapData
	{
		var bitmapData:BitmapData = new BitmapData(sourceRectangle.width, sourceRectangle.height, true, 0);
		bitmapData.copyPixels(compoundBitmapData, sourceRectangle, sharedPoint, null, null, true);
		return bitmapData;
	}
}
}