package org.flyti.aqua
{
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.BitmapAsset;

import cocoa.Insets;

public class SlicedImage
{
	private static const sharedMatrix:Matrix = new Matrix();

	protected var bitmaps:Vector.<BitmapData>;
	protected var sliceHeight:Number;
	protected var sliceInsets:Insets;

	private var firstSliceEmpty:Boolean;

	private static const EMPTY_CONTENT_INSETS:Insets = new Insets();

	public function slice2(bitmapClass:Class, contentInsets:Insets, contentGap:Number, sliceInsets:Insets, sliceWidth:Number = NaN):SlicedImage
	{
		slice(BitmapAsset(new bitmapClass()).bitmapData, contentInsets, sliceInsets, sliceWidth, -1, contentGap);
		return this;
	}

	/**
	 * contentInsets — в PNG собственно ассет расположен с неким отступом от края.
	 * contentGap — в PNG может быть несколько независимых композитных кусочков — gap между ними
	 * sliceInsets — указание размера кусочка (center cчитается автоматически на основе sliceWidth).
	 * Поддерживается только horizontal orientation, и только горизонтальное масштабирование.
	 */
	public function slice(compoundBitmapData:BitmapData, contentInsets:Insets, sliceInsets:Insets, sliceWidth:Number = NaN, sliceCount:int = -1, contentGap:Number = 0):Vector.<BitmapData>
	{
		if (contentInsets == null)
		{
			contentInsets = EMPTY_CONTENT_INSETS;
		}

		this.sliceInsets = sliceInsets;

		if (sliceCount == -1)
		{
			if (isNaN(sliceWidth))
			{
				sliceCount = 1;
				sliceWidth = compoundBitmapData.width;
			}
			else
			{
				sliceCount = compoundBitmapData.width / (contentInsets.width + sliceWidth);
			}
		}
		firstSliceEmpty = sliceInsets.left == 0;
		bitmaps = new Vector.<BitmapData>(sliceCount * (firstSliceEmpty ? 2 : 3), true);

		sliceHeight = compoundBitmapData.height - contentInsets.height;

		var leftSideRectangle:Rectangle = firstSliceEmpty ? null : new Rectangle(0, contentInsets.top, sliceInsets.left, sliceHeight);
		var rightSideRectangle:Rectangle = new Rectangle(0, contentInsets.top, sliceInsets.right, sliceHeight);
		var centerRectangle:Rectangle = new Rectangle(0, contentInsets.top, sliceWidth - sliceInsets.width, sliceHeight);

		var destinationPoint:Point = new Point();
		var bitmapData:BitmapData;

		var x:Number = contentInsets.left;
		for (var i:int = 0, n:int = bitmaps.length; i < n;)
		{
			if (!firstSliceEmpty)
			{
				leftSideRectangle.x = x;
				x += leftSideRectangle.width;

				bitmapData = new BitmapData(leftSideRectangle.width, leftSideRectangle.height, true, 0);
				bitmapData.copyPixels(compoundBitmapData, leftSideRectangle, destinationPoint, null, null, true);
				bitmaps[i++] = bitmapData;
			}

			centerRectangle.x = x;
			x += centerRectangle.width;

			bitmapData = new BitmapData(centerRectangle.width, centerRectangle.height, true, 0);
			bitmapData.copyPixels(compoundBitmapData, centerRectangle, destinationPoint, null, null, true);
			bitmaps[i++] = bitmapData;

			rightSideRectangle.x = x;
			x += rightSideRectangle.width;

			bitmapData = new BitmapData(rightSideRectangle.width, rightSideRectangle.height, true, 0);
			bitmapData.copyPixels(compoundBitmapData, rightSideRectangle, destinationPoint, null, null, true);
			bitmaps[i++] = bitmapData;

			x += contentGap;
		}

		return bitmaps;
	}

	public function draw(g:Graphics, w:Number, firstSubSliceIndex:int = 0, left:Number = 0, right:Number = 0, top:Number = 0, h:Number = NaN):void
	{
		var sliceIndex:int = firstSubSliceIndex;
		sharedMatrix.tx = left;
		sharedMatrix.ty = top;

		if (isNaN(h))
		{
			h = sliceHeight;
		}

		if (!firstSliceEmpty)
		{
			g.beginBitmapFill(bitmaps[sliceIndex++], sharedMatrix);
			g.drawRect(sharedMatrix.tx, top, sliceInsets.left, h);
			g.endFill();

			sharedMatrix.tx += sliceInsets.left;
		}

		var middleSliceWidth:Number = w - sharedMatrix.tx - sliceInsets.right - right;
		g.beginBitmapFill(bitmaps[sliceIndex++], sharedMatrix);
		g.drawRect(sharedMatrix.tx, top, middleSliceWidth, h);
		g.endFill();

		sharedMatrix.tx += middleSliceWidth;
		g.beginBitmapFill(bitmaps[sliceIndex++], sharedMatrix);
		g.drawRect(sharedMatrix.tx, top, sliceInsets.right, h);
		g.endFill();
	}
}
}