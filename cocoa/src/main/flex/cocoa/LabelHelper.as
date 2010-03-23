package cocoa
{
import flash.text.engine.ElementFormat;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import flash.text.engine.TextLineCreationResult;
import flash.utils.Dictionary;

import mx.core.mx_internal;

use namespace mx_internal;

/**
 * http://developer.apple.com/mac/library/DOCUMENTATION/UserExperience/Conceptual/AppleHIGuidelines/XHIGText/XHIGText.html#//apple_ref/doc/uid/TP30000365-TPXREF113
 */
public class LabelHelper
{
	private static const TRUNCATION_INDICATOR:String = "…";

	private static var truncationIndicatorMap:Dictionary;

	private static const textElement:TextElement = new TextElement();
	private static const textBlock:TextBlock = new TextBlock(textElement);

	private var availableWidth:Number = 1000000;

	private var invalid:Boolean;
	private var truncated:Boolean;

	private var textLine:TextLine;
	private var container:View;

	public function LabelHelper(container:View, font:ElementFormat = null)
	{
		this.container = container;
		_font = font;
	}

	public function get hasText():Boolean
	{
		return _text != null;
	}

	public function get textWidth():Number
	{
		return textLine.textWidth;
	}

	private var _font:ElementFormat;
	public function set font(value:ElementFormat):void
	{
		if (value != _font)
		{
			_font = value;
			invalid = true;
		}
	}

	private var _text:String;
	public function get text():String
	{
		return _text
	}
	public function set text(value:String):void
	{
		if (value != _text)
		{
			invalid = true;
			_text = value;
		}
	}

	public function set x(value:Number):void
	{
		textLine.x = value;
	}

	public function set y(value:Number):void
	{
		textLine.y = value;
	}

	public function move(x:Number, y:Number):void
	{
		textLine.x = x;
		textLine.y = y;
	}

	public function moveToCenter(w:Number, y:Number):void
	{
		if (textLine == null)
		{
			return;
		}

		textLine.x = (w - textLine.textWidth) * 0.5;
		textLine.y = y;
	}

	public function moveByInset(h:Number, contentInsets:Insets):void
	{
		if (textLine == null)
		{
			return;
		}

		textLine.x = contentInsets.left;
		textLine.y = h - contentInsets.bottom;
	}
	
	public function moveByInsets(h:Number, contentInsets:Insets, frameInsets:FrameInsets):void
	{
		if (textLine == null)
		{
			return;
		}

		// прибавление frameInsets.top нужно, так как если real bounds y полученный в результате отрисовки не будет 0, но и текст будет отпозиционирован согласно такому parent y
		textLine.x = contentInsets.left + frameInsets.left;
		textLine.y = h - contentInsets.bottom + frameInsets.top;
	}

	public function adjustWidth(newWidth:Number):void
	{
		if (newWidth < availableWidth || (newWidth > availableWidth && truncated))
		{
			invalid = true;
		}

		availableWidth = newWidth;
	}

	public function validate():void
	{
		if (!invalid)
		{
			return;
		}

		invalid = false;

		if (textLine != null)
		{
			container.removeDisplayObject(textLine);
		}

		if (_text != null)
		{
			textElement.elementFormat = _font;
			textElement.text = _text;
			textLine = textBlock.createTextLine(null, availableWidth);
			if (textLine == null)
			{
				trace(container + " " + this + " " + textBlock.textLineCreationResult);
			}
			else
			{
				truncated = textBlock.textLineCreationResult == TextLineCreationResult.EMERGENCY;
				if (truncated)
				{
					textElement.text = _text.slice(0, getTruncationPosition(textLine, availableWidth - getTruncationIndicatorWidth(textElement.elementFormat))) + TRUNCATION_INDICATOR;
					textLine = textBlock.createTextLine();
				}

				textBlock.releaseLines(textLine, textLine);
				textLine.mouseEnabled = false;
				textLine.mouseChildren = false;
				container.addDisplayObject(textLine);
			}
		}
		else
		{
			textLine = null;
		}
	}

	private function getTruncationIndicatorWidth(format:ElementFormat):Number
	{
		if (truncationIndicatorMap == null)
		{
			truncationIndicatorMap = new Dictionary();
		}

		var width:Number = truncationIndicatorMap[format];
		if (isNaN(width))
		{
			textElement.text = TRUNCATION_INDICATOR;
			var textLine:TextLine = textBlock.createTextLine();
			textBlock.releaseLines(textLine, textLine);

			width = textLine.textWidth;
			truncationIndicatorMap[format] = width;
			return width;
		}
		else
		{
			return truncationIndicatorMap[format];
		}
	}

	private function getTruncationPosition(line:TextLine, allowedWidth:Number):int
    {
        var consumedWidth:Number = 0;
        var charPosition:int = line.textBlockBeginIndex;

		var n:Number = line.textBlockBeginIndex + line.rawTextLength;
        while (charPosition < n)
        {
            var atomIndex:int = line.getAtomIndexAtCharIndex(charPosition);
            consumedWidth += line.getAtomBounds(atomIndex).width;
            if (consumedWidth > allowedWidth)
			{
                break;
			}

            charPosition = line.getAtomTextBlockEndIndex(atomIndex);
        }

        line.flushAtomData();

        return charPosition;
    }
}
}