package cocoa
{
import org.flyti.view.*;

import cocoa.AbstractView;

import flash.events.Event;

import org.flyti.view;

use namespace view;

[Event(name="change", type="flash.events.Event")]
public class SliderNumericStepper extends AbstractView
{
	view var slider:HSlider;
	view var stepper:NumericStepper;

	public function SliderNumericStepper()
	{
		skinParts.slider = 0;
		skinParts.stepper = 0;
	}

	private var _stepSize:Number = 0.01;
	public function set stepSize(value:Number):void
	{
		_stepSize = value;
	}

	private var _unitLabel:String = "%";
	public function set unitLabel(value:String):void
	{
		_unitLabel = value;
	}

	private var _stepperMultiplier:Number = 100;
	public function set stepperMultiplier(value:Number):void
	{
		_stepperMultiplier = value;
	}

	private var _enabled:Boolean = true;
	public function set enabled(value:Boolean):void
	{
		_enabled = value;
		if (skin != null)
		{
			skin.enabled = _enabled;
		}
	}

	private var _minimum:Number = 0;
	public function get minimum():Number
	{
		return _minimum;
	}
	public function set minimum(value:Number):void
	{
		if (value != minimum)
		{
			_minimum = value;
			if (slider != null)
			{
				slider.minimum = minimum;
			}
			if (stepper != null)
			{
				stepper.minimum = minimum;
			}
		}
	}

	private var _maximum:Number = 1;
	public function get maximum():Number
	{
		return _maximum;
	}

	public function set maximum(value:Number):void
	{
		if (value != maximum)
		{
			_maximum = value;
			if (slider != null)
			{
				slider.maximum = maximum;
			}
			if (stepper != null)
			{
				stepper.maximum = maximum;
			}
		}
	}

	private var _value:Number = 0;
	public function get value():Number
	{
		return _value;
	}

	public function set value(value:Number):void
	{
		_value = value;

		if (stepper != null)
		{
			stepper.value = _value * _stepperMultiplier;
		}
		if (slider != null)
		{
			slider.value = _value;
		}
	}

	view function stepperAdded():void
	{
		stepper.minimum = _minimum * _stepperMultiplier;
		stepper.maximum = _maximum * _stepperMultiplier;
		stepper.stepSize = _stepSize * _stepperMultiplier;

		if (_unitLabel != null && _unitLabel != "")
		{
			stepper.valueFormatFunction = stepperFormatFunction;
			stepper.valueParseFunction = stepperParseFunction;
		}

		if (!isNaN(_value))
		{
			stepper.value = _value * _stepperMultiplier;
		}

		stepper.addEventListener(Event.CHANGE, stepperChangeHandler);
	}

	view function sliderAdded():void
	{
		slider.minimum = _minimum;
		slider.maximum = _maximum;
		slider.stepSize = _stepSize;
		slider.showDataTip = false;

		if (!isNaN(_value))
		{
			slider.value = _value;
		}

		slider.addEventListener(Event.CHANGE, sliderChangeHandler);
	}

	override protected function initializeSkin():void
	{
		if (!_enabled)
		{
			skin.enabled = false;
		}
		
		super.initializeSkin();
	}

//	override protected function partRemoved(partName:String, instance:Object):void
//	{
//		super.partRemoved(partName, instance);
//
//		if (instance == stepper)
//		{
//			stepper.valueFormatFunction = null;
//			stepper.valueParseFunction = null;
//
//			stepper.removeEventListener(Event.CHANGE, stepperChangeHandler);
//		}
//		else if (instance == slider)
//		{
//			slider.removeEventListener(Event.CHANGE, sliderChangeHandler);
//		}
//	}

	private function sliderChangeHandler(event:Event):void
	{
		// system_mouseUpHandler в TrackBase имеет ошибку — всегда возбуждает CHANGE, даже если ничего не было изменено
		if (_value == slider.value)
		{
			return;
		}

		_value = slider.value;
		stepper.value = _value * _stepperMultiplier;
		dispatchEvent(event);
	}

	private function stepperChangeHandler(event:Event):void
	{
		_value = stepper.value / _stepperMultiplier;
		slider.value = _value;
		dispatchEvent(event);
	}

	private function stepperFormatFunction(value:Number):String
	{
		return value + " " + _unitLabel;
	}

	private function stepperParseFunction(value:String):Number
	{
		const endIndex:int = value.length - _unitLabel.length;
		if (value.substring(endIndex) == _unitLabel)
		{
			return Number(value.substring(0, endIndex - 1 /* space */));
		}
		else
		{
			return Number(value);
		}
	}
}
}