package org.flyti.assetBuilder;

import java.awt.*;
import java.awt.image.BufferedImage;

public class SliceCalculator
{
	/**
	 * Для большинства изображений достаточно и 1, но для изображение Fluent PopUp Button, где стрелка отступает от края на несколько px — нужно именно такое значение
	 * (иначе мы до стрелки не дойдем, посчитав и так что изображение уже не повторяется).
	 */
	private static final int DEFAULT_EQUAL_LENGTH = 4;

	private int width;
	private int height;

	private int[] pixels;

	/**
	 * Количество _непрерывных_ равных пикселей (отсчет от 0)
	 * Учитывается только для top и right
	 */
	private int equalLength = DEFAULT_EQUAL_LENGTH;

	public int calculateFromTop(BufferedImage image, Rectangle sourceRectangle)
	{
		init(image, sourceRectangle);

		int result = getUnrepeatableFromTop(true);
		if (result == sourceRectangle.height)
		{
			throw new Error("can't find");
		}
		return result;
	}

	public int calculateFromLeft(BufferedImage image, Rectangle sourceRectangle)
	{
		init(image, sourceRectangle);

		int result = getUnrepeatableFromLeft(true);
		if (result == sourceRectangle.width)
		{
			throw new Error("can't find");
		}
		return result;
	}

	private void init(BufferedImage image, Rectangle sourceRectangle)
	{
		final boolean sourceRectangleIsNull = sourceRectangle == null;

		width = sourceRectangleIsNull ? image.getWidth() : sourceRectangle.width;
		height = sourceRectangleIsNull ? image.getHeight() : sourceRectangle.height;

		pixels = image.getRGB(sourceRectangleIsNull ? 0 : sourceRectangle.x, sourceRectangleIsNull ? 0 : sourceRectangle.y, width, height, null, 0, width);
	}

	public Insets calculate(BufferedImage image, boolean strict, boolean allSide)
	{
		return calculate(image, null, 0, strict, allSide, DEFAULT_EQUAL_LENGTH);
	}

	public Insets calculate(BufferedImage image, Rectangle frameRectangle, int top, boolean strict, boolean allSide, int equalLength)
	{
		if (frameRectangle != null)
		{
			frameRectangle.y += top;
		}

		init(image, frameRectangle);
		this.equalLength = equalLength;

		Insets sliceSize = new Insets(getUnrepeatableFromLeft(strict), allSide ? getUnrepeatableFromTop(strict) : 0, getUnrepeatableFromRight(strict), allSide ? getUnrepeatableFromBottom(strict) : 0);

		if (frameRectangle != null)
		{
			frameRectangle.y -= top;
		}

		if (sliceSize.getWidth() == width || (allSide && sliceSize.getHeight() == height))
		{
			throw new Error("can't find center area");
		}

		// мы не assertSiblings, так как 1) нам лениво 2) первый идет как up state — там и так всегда максимум отступа
		return sliceSize;
	}

	private int getUnrepeatableFromLeft(boolean strict)
	{
		columnLoop : for (int column = 0, maxColumn = width - 2; column < maxColumn; column++)
		{
			for (int i = column, n = (width * height) - width + 1; i < n; i += width)
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

	private int getUnrepeatableFromRight(boolean strict)
	{
		int equalCount = 0;

		columnLoop : for (int column = width - 1; column > 1; column--)
		{
			for (int i = column, n = (width * height) - width + 1; i < n; i += width)
			{
				if (!equalColor(pixels[i], pixels[i - 1], strict))
				{
					equalCount = 0; // сбрасываем счетчик равности, так как если equalLength равен 5, это значит, что у нас должно как минимум 5 _непрерывных_ равных пикселей
					continue columnLoop;
				}
			}

			equalCount++;
			if (equalCount == equalLength)
			{
				return width - (column + 1) - (equalCount - 1);
			}
		}

		throw new Error("can't find center area");
	}

	private int getUnrepeatableFromTop(boolean strict)
	{
		int equalCount = 0;

		rowLoop : for (int row = 0, maxRow = height - 1; row < maxRow; row++)
		{
			for (int i = row * width, n = i + width; i < n; i++)
			{
				if (!equalColor(pixels[i], pixels[i + width], strict))
				{
					equalCount = 0;
					continue rowLoop;
				}
			}

			equalCount++;
			if (equalCount == equalLength)
			{
				return row - (equalCount + 1);
			}
		}

		throw new Error("can't find center area");
	}

	private int getUnrepeatableFromBottom(boolean strict)
	{
		rowLoop : for (int row = height - 1; row > 0; row--)
		{
			for (int i = row * width, n = i + width; i < n; i++)
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
	private boolean equalColor(int c1, int c2, boolean strict)
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
			int rDiff = ((c1 & 0x00ff0000) >>> 16) - ((c2 & 0x00ff0000) >>> 16);
			if (rDiff > 1 || rDiff < -1)
			{
				return false;
			}

			int gDiff = ((c1 & 0x0000FF00) >>> 8) - ((c2 & 0x0000FF00) >>> 8);
			if (gDiff > 1 || gDiff < -1)
			{
				return false;
			}
			int bDiff = (c1 & 0x000000ff) - (c2 & 0x000000ff);
			//noinspection RedundantIfStatement
			if (bDiff > 1 || bDiff < -1)
			{
				return false;
			}

			return true;
		}
	}
}
