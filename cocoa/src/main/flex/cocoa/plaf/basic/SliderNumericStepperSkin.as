package cocoa.plaf.basic
{
import cocoa.HSlider;
import cocoa.LabelHelper;
import cocoa.NumericStepper;
import cocoa.plaf.AbstractSkin;
import cocoa.plaf.FontID;
import cocoa.plaf.SliderNumericStepperSkin;

public class SliderNumericStepperSkin extends AbstractSkin implements cocoa.plaf.SliderNumericStepperSkin
{
	protected var slider:HSlider;
	protected var stepper:NumericStepper;

	protected static const GAP:Number = 5;

	protected var labelHelper:LabelHelper;

	public function set label(value:String):void
	{
		if (labelHelper == null)
		{
			if (value == null)
			{
				return;
			}

			labelHelper = new LabelHelper(this, laf == null ? null : getFont(FontID.SYSTEM));
		}
		else if (value == labelHelper.text)
		{
			return;
		}

		labelHelper.text = value;

		invalidateSize();
		invalidateDisplayList();
	}

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

		if (labelHelper != null)
		{
			labelHelper.font = getFont(FontID.SYSTEM);
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
			measuredHeight += Math.round(labelHelper.textAscent);
		}
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var topOffset:Number = 0;
		if (labelHelper != null)
		{
			topOffset = Math.round(labelHelper.textAscent);
			labelHelper.validate();
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