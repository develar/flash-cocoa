package cocoa.plaf.aqua.assetBuilder
{
import cocoa.Insets;

import flash.display.BitmapData;
import flash.geom.Rectangle;

public class SliceCalculator
{
	private var width:int;
	private var height:int;

	private var pixels:Vector.<uint>;

	public function calculate(bitmapData:BitmapData, frameRectangle:Rectangle, top:int, strict:Boolean = false, allSide:Boolean = false):Insets
	{
		frameRectangle.y += top;

		width = frameRectangle.width;
		height = frameRectangle.height;

		pixels = bitmapData.getVector(frameRectangle);
		pixels.fixed = true;

		var sliceSize:Insets = new Insets(getUnrepeatableFromLeft(strict), allSide ? getUnrepeatableFromTop(strict) : 0, getUnrepeatableFromRight(strict), allSide ? getUnrepeatableFromBottom(strict) : 0);

		frameRectangle.y -= top;

		if (sliceSize.width == frameRectangle.width || (allSide && sliceSize.height == frameRectangle.height))
		{
			throw new Error("can't find center area");
		}

		// мы не assertSiblings, так как 1) нам лениво 2) первый идет как up state — там и так всегда максимум отступа
		return sliceSize;
	}

	private function getUnrepeatableFromLeft(strict:Boolean):int
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

	private function getUnrepeatableFromRight(strict:Boolean):int
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

	private function getUnrepeatableFromTop(strict:Boolean):int
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

	private function getUnrepeatableFromBottom(strict:Boolean):int
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
}
}