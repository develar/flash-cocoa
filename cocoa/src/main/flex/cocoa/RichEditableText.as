package cocoa
{
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;

import flashx.textLayout.formats.BlockProgression;

import mx.core.mx_internal;

import spark.components.RichEditableText;

use namespace mx_internal;

public class RichEditableText extends spark.components.RichEditableText
{
	public override function drawFocus(isFocused:Boolean):void
	{
		// skip
	}

	private var _font:ElementFormat;
	public function get font():ElementFormat
	{
		return _font;
	}
	public function set font(value:ElementFormat):void
	{
		_font = value;
		var fontDescription:FontDescription = _font.fontDescription;
		nonInheritingStyles = {color: _font.color,
			fontFamily: fontDescription.fontName, fontSize: _font.fontSize, fontLookup: fontDescription.fontLookup,
			blockProgression: BlockProgression.TB, focusedTextSelectionColor: 0xa8c6ee, fontWeight: fontDescription.fontWeight, fontStyle: fontDescription.fontPosture,
			cffHinting: _font.fontDescription.cffHinting};

		textContainerManager.hostFormat = new TextLayoutFormat(this, _font);
	}

	override public function regenerateStyleCache(recursive:Boolean):void
	{

	}

	override public function getStyle(styleProp:String):*
	{
//		if (!(styleProp in nonInheritingStyles))
//		{
//			trace('unknown ' + styleProp);
//		}
		return nonInheritingStyles[styleProp];
	}

	override public function styleChanged(styleProp:String):void
	{

	}

	override protected function resourcesChanged():void
	{

	}

	override public function setStyle(styleProp:String, newValue:*):void
	{
		nonInheritingStyles[styleProp] = newValue;
	}

	override public function get layoutDirection():String
	{
		return AbstractView.LAYOUT_DIRECTION_LTR;
	}

	override public function registerEffects(effects:Array /* of String */):void
	{

	}

	override public function notifyStyleChangeInChildren(styleProp:String, recursive:Boolean):void
	{

	}

	override public function stylesInitialized():void
	{

	}

	override mx_internal function initThemeColor():Boolean
	{
		return true;
	}

	include "../../legacyConstraints.as";
}
}