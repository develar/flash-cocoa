package org.flyti.aqua
{
import cocoa.PopUpButton;

public class PopUpOpenButtonSkin extends PushButtonSkin
{
	override public function regenerateStyleCache(recursive:Boolean):void
    {
		var bezel:String = PopUpButton(parent.parent.parent).getStyle("bezel");
		border = AquaBorderFactory.getPopUpOpenButtonBorder(bezel == null ? BezelStyle.rounded : BezelStyle.valueOf(bezel));
	}

	public function get labelLeftMargin():Number
	{
		return border.textInsets.left + border.layoutInsets.left;
	}
}
}