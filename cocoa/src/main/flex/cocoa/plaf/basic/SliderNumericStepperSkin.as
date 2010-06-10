package cocoa.plaf.basic
{
import cocoa.HSlider;
import cocoa.NumericStepper;
import cocoa.plaf.AbstractSkin;

public class SliderNumericStepperSkin extends AbstractSkin
{
	private var slider:HSlider;
	private var stepper:NumericStepper;

	private static const GAP:Number = 5;

	override protected function createChildren():void
	{
		if (slider == null)
		{
			slider = new HSlider();
			slider.enabled = enabled;
			addChild(slider);
			component.uiPartAdded("slider", slider);
		}

		if (stepper == null)
		{
			stepper = new NumericStepper();
			stepper.enabled = enabled;
			addChild(stepper);
			component.uiPartAdded("stepper", stepper);
		}
	}

	override protected function measure():void
	{
		measuredMinWidth = slider.minWidth + stepper.minWidth;
		measuredMinHeight = Math.max(slider.minHeight + stepper.minHeight);

		measuredWidth = slider.getExplicitOrMeasuredWidth() + stepper.getExplicitOrMeasuredWidth() + GAP;
		measuredHeight = Math.max(slider.getExplicitOrMeasuredHeight(), stepper.getExplicitOrMeasuredHeight());
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var stepperW:Number = stepper.getExplicitOrMeasuredWidth();
		var stepperH:Number = stepper.getExplicitOrMeasuredHeight();
		var sliderH:Number = slider.getExplicitOrMeasuredHeight();

		slider.setActualSize(w - stepperW - GAP, sliderH);
		slider.y = (h - sliderH) / 2;

		stepper.setActualSize(stepperW, stepperH);
		stepper.move(w - stepperW, (h - stepperH) / 2);
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