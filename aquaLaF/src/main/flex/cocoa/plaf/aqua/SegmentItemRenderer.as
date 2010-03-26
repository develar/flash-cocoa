package cocoa.plaf.aqua
{
import cocoa.Insets;
import cocoa.plaf.LabeledItemRenderer;
import cocoa.plaf.LookAndFeel;

import spark.components.DataGroup;

public class SegmentItemRenderer extends LabeledItemRenderer
{
	protected static const REGULAR_HEIGHT:Number = 20;
	protected static const REGULAR_LABEL_INSETS:Insets = new Insets(10, NaN, 10,  6);

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

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		labelHelper.validate();
		labelHelper.moveByInset(h, border.contentInsets);

//		var stateIndex:int = StateSubSliceIndexMap[currentState];
//
//		var tabIndex:int = AquaBarButton(parent).itemIndex;
//		var isLastTab:Boolean = tabIndex == (AquaBarButton(parent).parent.numChildren - 1);
//
//		labelHelper.font = stateIndex == StateSubSliceIndexMap.disabled ? AquaFonts.SYSTEM_FONT_DISABLED : AquaFonts.SYSTEM_FONT;
//		labelHelper.validate();
//		labelHelper.moveToCenter(isLastTab ? w : w - 1, h - REGULAR_LABEL_INSETS.bottom);
//
//		var g:Graphics = graphics;
//		g.clear();
//
//		var slicedImage:SlicedImage;
//		var left:Number = 0;
//		var right:Number = 0;
//		var indexAdjustment:int = 2;
//		if (tabIndex == 0)
//		{
//			slicedImage = firstBorderSlicedImage;
//			left = -1;
//			indexAdjustment = 3;
//		}
//		else if (isLastTab)
//		{
//			slicedImage = lastBorderSlicedImage;
//			right = -1;
//		}
//		else
//		{
//			slicedImage = middleBorderSlicedImage;
//		}
//
//		slicedImage.draw(g, w, stateIndex * indexAdjustment, left, right);
	}
}
}