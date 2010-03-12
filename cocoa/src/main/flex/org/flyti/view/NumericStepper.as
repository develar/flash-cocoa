package org.flyti.view
{
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.FontLookup;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;

import mx.core.IUIComponent;
import mx.core.mx_internal;

import org.flyti.util.StringUtil;

import spark.components.NumericStepper;

use namespace mx_internal;

[Style(name="focusVisible", format="Boolean")]

[SkinState("over")]
public class NumericStepper extends spark.components.NumericStepper
{
	private var focusVisible:Boolean = true;
	private var focusVisibleChanged:Boolean;

	public function $getCurrentSkinState():String
    {
		return super.getCurrentSkinState();
	}

	/**
	 * WA. По логике, сам NumericStepper при изменении enabled должен менять состояние своих skinParts, как VideoPlayer, но этого пока что нет, так что мы сами
	 */
	override public function set enabled(value:Boolean):void
    {
        super.enabled = value;

		if (skinParts != null)
		{
			for (var skinPartId:String in skinParts)
			{
				var skinPart:IUIComponent = this[skinPartId];
				if (skinPart != null)
				{
					skinPart.enabled = value;
				}
			}
		}
    }

	public override function drawFocus(isFocused:Boolean):void
	{
		if (focusVisible)
		{
			super.drawFocus(isFocused);
		}
	}

	public override function styleChanged(styleProp:String):void
	{
		super.styleChanged(styleProp);

		if (styleProp == null || styleProp == "focusVisible")
		{
			focusVisibleChanged = true;
		}
	}

	override protected function partAdded(partName:String, instance:Object):void
	{
		super.partAdded(partName, instance);

		if (instance == textDisplay)
		{
			textDisplay.width = calculateTextWidth();
		}
	}

	protected override function commitProperties():void
	{
		super.commitProperties();

		if (maxChanged || stepSizeChanged || valueFormatFunctionChanged)
		{
			textDisplay.width = calculateTextWidth();
			maxChanged = false;
			stepSizeChanged = false;
			valueFormatFunctionChanged = false;
		}

		if (focusVisibleChanged)
		{
			focusVisibleChanged = false;
			focusVisible = getStyle("focusVisible");
		}
	}

	private function calculateWidestText():String
    {
        var widestNumber:Number = minimum.toString().length > maximum.toString().length ? minimum : maximum;
		var widestText:String;
		if (widestNumber < 0)
		{
			widestText = "-" + (StringUtil.repeat("9", widestNumber.toString().length - 1));
		}
		else
		{
			widestText = StringUtil.repeat("9", widestNumber.toString().length);
		}

        if (valueFormatFunction != null)
		{
            return valueFormatFunction(Number(widestText));
		}
        else
		{
			return widestText;
		}
    }

	private function calculateTextWidth():Number
    {
        var fontDescription:FontDescription = new FontDescription();

        var s:String;

        s = getStyle("cffHinting");
        if (s != null)
            fontDescription.cffHinting = s;

        s = getStyle("fontFamily");
        if (s != null)
            fontDescription.fontName = s;

        s = getStyle("fontLookup");
        if (s != null)
        {
            // FTE understands only "device" and "embeddedCFF"
            // for fontLookup. But Flex allows this style to be
            // set to "auto", in which case we automatically
            // determine it based on whether the CSS styles
            // specify an embedded font.
            if (s == "auto")
            {
                s = textDisplay.textDisplay.textContainerManager.swfContext ?
                    FontLookup.EMBEDDED_CFF :
                    FontLookup.DEVICE;
            }
        }

        s = getStyle("fontStyle");
        if (s != null)
            fontDescription.fontPosture = s;

        s = getStyle("fontWeight");
        if (s != null)
            fontDescription.fontWeight = s;

        var elementFormat:ElementFormat = new ElementFormat();
        elementFormat.fontDescription = fontDescription;
        elementFormat.fontSize = getStyle("fontSize");

        var textElement:TextElement = new TextElement();
        textElement.elementFormat = elementFormat;
        textElement.text = calculateWidestText();

        var textBlock:TextBlock = new TextBlock();
        textBlock.content = textElement;

        var textLine:TextLine = textBlock.createTextLine();
		return textLine.width;
    }

	// override
	private var valueFormatFunctionChanged:Boolean;

	override public function set valueFormatFunction(value:Function):void
    {
        valueFormatFunctionChanged = true;
        super.valueFormatFunction = value;
    }

	private var stepSizeChanged:Boolean = false;

	override public function set stepSize(value:Number):void
	{
		stepSizeChanged = true;
		super.stepSize = value;
	}

	private var maxChanged:Boolean = false;

    override public function set maximum(value:Number):void
    {
        maxChanged = true;
        super.maximum = value;
    }

	override protected function nearestValidValue(value:Number, interval:Number):Number
	{
		if (interval == 0)
		{
			return Math.max(minimum, Math.min(maximum, value));
		}

		var minValue:Number = minimum;
		var maxValue:Number = maximum;
		var scale:Number = 1;

		// If interval isn't an integer, there's a possibility that the floating point
		// approximation of value or value/interval will be slightly larger or smaller
		// than the real value.  This can lead to errors in calculations like
		// floor(value/interval)*interval, which one might expect to just equal value,
		// when value is an exact multiple of interval.  Not so if value=0.58 and
		// interval=0.01, in that case the calculation yields 0.57!  To avoid problems,
		// we scale by the implicit precision of the interval and then round.  For
		// example if interval=0.01, then we scale by 100.

		if (interval != int(interval))
		{
			const s:String = String(1 + interval);
			scale = Math.pow(10, s.length - s.indexOf(".") - 1);
			minValue *= scale;
			maxValue *= scale;
			value = Math.round(value * scale);
			interval = Math.round(interval * scale);
		}

		var lower:Number = Math.max(minValue, Math.floor(value / interval) * interval);
		var upper:Number = Math.min(maxValue, Math.floor((value + interval) / interval) * interval);
		return (((value - lower) >= ((upper - lower) / 2)) ? upper : lower) / scale;
	}
}
}