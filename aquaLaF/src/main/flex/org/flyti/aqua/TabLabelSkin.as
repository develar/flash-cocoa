package org.flyti.aqua
{
import cocoa.Insets;
import cocoa.plaf.AbstractPushButtonSkin;
import cocoa.plaf.aqua.SlicedImage;

import flash.events.MouseEvent;

import cocoa.ToggleButtonState;

/**
 * artwork для down state нету, мы используем похожий.
 */
public class TabLabelSkin extends AbstractPushButtonSkin
{
	protected static const REGULAR_HEIGHT:Number = 20;
	protected static const REGULAR_LABEL_INSETS:Insets = new Insets(10, NaN, 10,  6);

	[Embed(source="/Toggle.west.borders.png")]
	private static var firstBorderClass:Class;
	private static const firstBorderSlicedImage:SlicedImage = new SlicedImage().slice2(firstBorderClass, new Insets(1, 2, 0, 1), 1, new Insets(20, 0, 1, 0), 22);
	firstBorderClass = null;
	
	[Embed(source="/Toggle.center.borders.png")]
	private static var middleBorderClass:Class;
	private static const middleBorderSlicedImage:SlicedImage = new SlicedImage().slice2(middleBorderClass, new Insets(0, 2, 0, 1), 0, new Insets(0, 0, 1, 0), 2);
	middleBorderClass = null;

	[Embed(source="/Toggle.east.borders.png")]
	private static var lastBorderClass:Class;
	private static const lastBorderSlicedImage:SlicedImage = new SlicedImage().slice2(lastBorderClass, new Insets(0, 2, 1, 1), 1, new Insets(0, 0, 20, 0), 21);
	lastBorderClass = null;

	public function TabLabelSkin()
	{
		// TabView скин в Aqua при нажатии на невыделенную кнопку (то есть down state) отображает более серую кнопку — как только мышь up или roll out, оно возвращается в up state
		addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);

		_currentState = ToggleButtonState.up;
	}

	private function mouseDownHandler(event:MouseEvent):void
	{
		if (_currentState == ToggleButtonState.up)
		{
			currentState = ToggleButtonState.down.name;
			event.updateAfterEvent();
		}
	}

	private function rollOverHandler(event:MouseEvent):void
	{
		if (_currentState == ToggleButtonState.up && event.buttonDown)
		{
			currentState = ToggleButtonState.down.name;
			event.updateAfterEvent();
		}
	}

	private function rollOutHandler(event:MouseEvent):void
	{
		if (_currentState == ToggleButtonState.down)
		{
			currentState = ToggleButtonState.up.name;
			event.updateAfterEvent();
		}
	}

	private var _currentState:ToggleButtonState;
	override public function get currentState():String
	{
		return _currentState.name;
	}
	override public function set currentState(value:String):void
	{
		if (value != _currentState.name && !(value == ToggleButtonState.downAndSelected.name && _currentState == ToggleButtonState.upAndSelected))
		{
			_currentState = ToggleButtonState.valueOf(value);
			invalidateDisplayList();
		}
    }

	override protected function measure():void
	{
		if (!labelHelper.hasText)
		{
			return;
		}

		labelHelper.validate();
		measuredMinWidth = REGULAR_HEIGHT * 2;
		measuredMinHeight = REGULAR_HEIGHT;

		measuredWidth = Math.ceil(labelHelper.textWidth) + REGULAR_LABEL_INSETS.width;
		measuredHeight = REGULAR_HEIGHT;

		// все табы кроме последнего имеют разделяющую линию в конце — ее ширина 1px и мы должны увеличить ширину соответственно
		if (AquaBarButton(parent).itemIndex != (AquaBarButton(parent).parent.numChildren - 1))
		{
			measuredWidth += 1;
		}
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{		
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