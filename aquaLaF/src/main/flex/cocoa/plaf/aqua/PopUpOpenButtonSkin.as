package cocoa.plaf.aqua
{
import cocoa.PopUpButton;
import cocoa.UIManager;

public class PopUpOpenButtonSkin extends PushButtonSkin
{
	override public function regenerateStyleCache(recursive:Boolean):void
    {
		var bezel:String = PopUpButton(parent.parent.parent).getStyle("bezel");
		border = UIManager.getBorder("PopUpButton.border." + (bezel == null ? BezelStyle.rounded.name : bezel));
	}

	public function get labelLeftMargin():Number
	{
		return border.contentInsets.left + border.frameInsets.left;
	}
}
}