package cocoa.plaf.aqua
{
import cocoa.FrameInsets;
import cocoa.plaf.LabeledItemRenderer;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Scale1BitmapBorder;

import flash.display.BitmapData;
import flash.display.Graphics;

import spark.components.DataGroup;

public class SegmentItemRenderer extends LabeledItemRenderer
{
	private static const leftIndex:int = 0;
	private static const middleIndex:int = leftIndex + 4;
	private static const rightIndex:int = middleIndex + 4;
	private static const separatorIndex:int = rightIndex + 4;
	private static const shadowIndex:int = separatorIndex + 2;

	private static const offOffset:int = 0;
	private static const onOffset:int = 1;
	private static const highlightOffOffset:int = 2;
	private static const highlightOnOffset:int = 3;

	public function SegmentItemRenderer()
	{
		// TabView скин в Aqua при нажатии на невыделенную кнопку (то есть down state) отображает более серую кнопку — как только мышь up или roll out, оно возвращается в up state
//		addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
//		addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
//		addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
	}

	override public function get lafPrefix():String
	{
		return "SegmentItem";
	}

	override public function set laf(value:LookAndFeel):void
	{
		super.laf = value;

		border = getBorder("border");
	}

	override protected function measure():void
	{
		super.measure();

		// первый и последний сегмент имеет ширину большую на 1px чем остальные
		var numberOfItems:int = DataGroup(parent).dataProvider.length;
		if (itemIndex == 0 || itemIndex == (numberOfItems - 1))
		{
			measuredMinWidth += 1;
			measuredWidth += 1;
		}
	}

	/**
	 * Мы должны быть осторожны при отрисовке и учитывать, чтобы было корректное перекрытие разделителей.
	 * Поэтому: всегда (за исключением последнего элемента) отрисовываем разделитель справа, а слева только если мы selected (нет разницы — highlighted или нет).
	 * Так как мы добавляем элементы слева направо — самый левый имеет самый маленький индекс в display list,
	 * то при отрисовке левого разделителя при selected Flash Player корректно отрисует его над старым разделителем (который отрисован предыдущим элементом).
	 *
	 * Но у нас есть полупрозрачные пиксели — при наложении получается плохо — поэтому background и separator по высоте меньше на 3 пикселя по высоте (снизу), мы отрисовываем их сами программно
	 */
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var frameInsets:FrameInsets = border.frameInsets;
		var border:Scale1BitmapBorder = Scale1BitmapBorder(this.border);

		var isLast:Boolean = false;
		const isFirst:Boolean = itemIndex == 0;
		if (isFirst)
		{
			frameInsets.left = -1;
			frameInsets.right = 0;
		}
		else
		{
			frameInsets.left = 0;
			isLast = itemIndex == (DataGroup(parent).dataProvider.length - 1);
			frameInsets.right = isLast ? -1 : 0;
		}

		labelHelper.validate();
		labelHelper.moveByInsets(h, border.contentInsets, frameInsets);

		var g:Graphics = graphics;
		g.clear();

		const offset:int = ((state & HIGHLIGHTED) != 0) ? (selected ? highlightOnOffset : highlightOffOffset) : (selected ? onOffset : offOffset);
		const computedSepatatorIndex:int = separatorIndex + (offset % 2);

		var bitmaps:Vector.<BitmapData> = border.getBitmaps();
		var backgroundWidth:Number;
		var rightWidth:Number;
		if (isFirst)
		{
			border.bitmapIndex = leftIndex + offset;
			var leftWidth:Number = bitmaps[leftIndex + offset].width;
			border.draw(null, g, leftWidth, h);

			backgroundWidth = w - leftWidth - frameInsets.left;
			frameInsets.left += leftWidth;
		}
		else
		{
			if (selected)
			{
				frameInsets.left = -1;
				border.bitmapIndex = computedSepatatorIndex;
				border.draw(null, g, 1, h - 3);
				frameInsets.left = 0;
			}

			if (isLast)
			{
				rightWidth = bitmaps[rightIndex + offset].width;
				backgroundWidth = w - rightWidth - frameInsets.right;
			}
			else
			{
				backgroundWidth = w;
			}
		}

		frameInsets.top = h;
		border.bitmapIndex = shadowIndex;
		border.draw(null, g, isLast ? backgroundWidth : (backgroundWidth + 1), 0);
		frameInsets.top = 0;

		border.bitmapIndex = middleIndex + offset;
		border.draw(null, g, backgroundWidth, h - 3);

		if (isLast)
		{
			frameInsets.left = backgroundWidth;
			border.bitmapIndex = rightIndex + offset;
			border.draw(null, g, rightWidth, h);
		}
		else
		{
			frameInsets.left = w;
			border.bitmapIndex = computedSepatatorIndex;
			border.draw(null, g, 1, h - 3);
		}
	}
}
}