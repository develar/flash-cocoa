package cocoa
{
import cocoa.plaf.FontID;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;

import flash.display.DisplayObjectContainer;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.FontLookup;
import flash.text.engine.FontPosture;
import flash.text.engine.FontWeight;

import flashx.textLayout.compose.ISWFContext;
import flashx.textLayout.formats.TextAlign;
import flashx.textLayout.formats.VerticalAlign;

import mx.core.mx_internal;

use namespace mx_internal;

public class Label extends AbstractView
{
	private var fontDescription:FontDescription;

	private var labelHelper:LabelHelper;

	private var elementFormat:ElementFormat;
	private var laf:LookAndFeel;

	public function Label()
	{
		super();

		mouseEnabled = false;
		mouseChildren = false;

		labelHelper = new LabelHelper(this);
	}
	
	private var _paddingLeft:Number = 0;
	public function set paddingLeft(value:Number):void
	{
		_paddingLeft = value;
	}
	
	private var _paddingRight:Number = 0;
	public function set paddingRight(value:Number):void
	{
		_paddingRight = value;
	}
	
	private var _paddingTop:Number = 0;
	public function set paddingTop(value:Number):void
	{
		_paddingTop = value;
	}
	
	private var _paddingBottom:Number = 0;
	public function set paddingBottom(value:Number):void
	{
		_paddingBottom = value;
	}

	public function get color():uint
	{
		return elementFormat.color;
	}
	public function set color(value:uint):void
	{
		if (elementFormat == null)
		{
			elementFormat = new ElementFormat();
		}
		else if (elementFormat.locked)
		{
			elementFormat = elementFormat.clone();
		}

		elementFormat.color = value;

		invalidateDisplayList();
	}

	public function set fontFamily(value:String):void
	{
		if (fontDescription == null)
		{
			fontDescription = new FontDescription();
		}
		else if (fontDescription.locked)
		{
			fontDescription = fontDescription.clone();
		}

		fontDescription.fontName = value;
		if (elementFormat != null && elementFormat.fontDescription != null && elementFormat.fontDescription != fontDescription)
		{
			elementFormat = elementFormat.clone();
			elementFormat.fontDescription = fontDescription;
		}

		invalidateDisplayList();
	}

	public function set fontWeight(value:String):void
	{
		if (fontDescription == null)
		{
			fontDescription = new FontDescription();
		}
		else if (fontDescription.locked)
		{
			fontDescription = fontDescription.clone();
		}

		fontDescription.fontWeight = value;

		if (elementFormat != null && elementFormat.fontDescription != null && elementFormat.fontDescription != fontDescription)
		{
			elementFormat = elementFormat.clone();
			elementFormat.fontDescription = fontDescription;
		}

		invalidateDisplayList();
	}

	public function set fontSize(value:Number):void
	{
		if (elementFormat == null)
		{
			elementFormat = new ElementFormat();
		}
		else if (elementFormat.locked)
		{
			elementFormat = elementFormat.clone();
		}

		elementFormat.fontSize = value;
		invalidateDisplayList();
	}

	private var _textAlign:String = TextAlign.START;
	public function set textAlign(value:String):void
	{
		_textAlign = value;
	}

	private var _verticalAlign:String = VerticalAlign.TOP;
	public function set verticalAlign(value:String):void
	{
		_verticalAlign = value;
	}

	public function get title():String
	{
		return labelHelper.text;
	}
	public function set title(value:String):void
	{
		if (value != labelHelper.text)
		{
			labelHelper.text = value;
			invalidateDisplayList();
		}
	}

	override protected function createChildren():void
	{
		super.createChildren();

		if (elementFormat != null && fontDescription != null)
		{
			elementFormat.fontDescription = fontDescription;
			return;
		}

		// ImageView и не скин компонента, и не item renderer, так что пока что он сам ищет для себя LaF
		var p:DisplayObjectContainer = parent;
		while (p != null)
		{
			if (p is LookAndFeelProvider)
			{
				laf = LookAndFeelProvider(p).laf;
				if (laf != null)
				{
					break;
				}
			}
			else
			{
				if (p is Skin && Skin(p).component is LookAndFeelProvider)
				{
					laf = LookAndFeelProvider(Skin(p).component).laf;
					break;
				}
			}

			p = p.parent;
		}

		if (fontDescription == null)
		{
			var lafElementFormat:ElementFormat = laf.getFont(FontID.VIEW);
			if (elementFormat == null)
			{
				elementFormat = lafElementFormat;
			}
			else
			{
				elementFormat.fontDescription = lafElementFormat.fontDescription;
			}

			fontDescription = elementFormat.fontDescription;
		}

		// на данный момент встроенные шрифты могут придти только из LaF, поэтому более нигде мы не обновляем swf context
		if (elementFormat.fontDescription.fontLookup == FontLookup.EMBEDDED_CFF)
		{
			labelHelper.swfContext = ISWFContext(getFontContext(fontDescription.fontName, fontDescription.fontWeight == FontWeight.BOLD, fontDescription.fontPosture == FontPosture.ITALIC, true));
		}
	}

	override protected function measure():void
	{
		if (labelHelper.hasText)
		{
			labelHelper.validate();
			measuredWidth = labelHelper.textWidth + _paddingLeft + _paddingRight;
			measuredHeight = labelHelper.textHeight + _paddingBottom + _paddingTop;
		}
		else
		{
			measuredWidth = 0;
			measuredHeight = 0;
		}
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		labelHelper.font = elementFormat;
		if (!labelHelper.hasText)
		{
			return;
		}

		labelHelper.validate();

		var textY:Number = h - labelHelper.textLine.descent - _paddingBottom + _paddingTop;
		
		switch (_textAlign)
		{
			case TextAlign.START:
			case TextAlign.LEFT:
			{
				labelHelper.move(_paddingLeft, textY);
			}
			break;

			case TextAlign.CENTER:
			{
				labelHelper.moveToCenter(w, textY);
			}
			break;
		}
	}
	}
}