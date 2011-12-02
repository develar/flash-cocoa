package cocoa.plaf.basic
{
import cocoa.HSlider;
import cocoa.NumericStepper;

public class SliderNumericStepperSkin extends TitledComponentSkin
{
	protected var slider:HSlider;
	protected var stepper:NumericStepper;

	protected static const GAP:Number = 5;

	override protected function createChildren():void
	{
		super.createChildren();

		if (slider == null)
		{
			slider = new HSlider();
			slider.enabled = enabled;
			addChild(slider);
			hostComponent.uiPartAdded("slider", slider);
		}

		if (stepper == null)
		{
			stepper = new NumericStepper();
			stepper.enabled = enabled;
			addChild(stepper);
			hostComponent.uiPartAdded("stepper", stepper);
		}
	}

	override protected function measure():void
	{
		measuredMinWidth = slider.minWidth + stepper.minWidth;
		measuredMinHeight = Math.max(slider.minHeight + stepper.minHeight);

		measuredWidth = slider.getExplicitOrMeasuredWidth() + stepper.getExplicitOrMeasuredWidth() + GAP;
		measuredHeight = Math.max(slider.getExplicitOrMeasuredHeight(), stepper.getExplicitOrMeasuredHeight());

		if (labelHelper != null)
		{
			labelHelper.validate();
			measuredHeight += Math.round(labelHelper.textLine.ascent);
		}
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var topOffset:Number = 0;
		if (labelHelper != null)
		{
			labelHelper.validate();
			topOffset = Math.round(labelHelper.textLine.ascent);
			labelHelper.move(0, topOffset);
		}

		const controlH:Number = h - topOffset;

		var stepperW:Number = stepper.getExplicitOrMeasuredWidth();
		var stepperH:Number = stepper.getExplicitOrMeasuredHeight();
		var sliderH:Number = slider.getExplicitOrMeasuredHeight();

		slider.setActualSize(w - stepperW - GAP, sliderH);
		slider.y = Math.round((controlH - sliderH) / 2) + topOffset;

		stepper.setActualSize(stepperW, stepperH);
		stepper.move(w - stepperW, Math.round((controlH - stepperH) / 2) + topOffset);
	}

	override public function set enabled(value:Boolean):void
	{
		super.enabled = value;

		if (slider != null)
		{
			slider.enabled = value;
		}
		if (stepper != null)
		{
			stepper.enabled = value;
		}
	}
}
}