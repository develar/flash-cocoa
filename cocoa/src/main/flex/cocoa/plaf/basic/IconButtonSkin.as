package cocoa.plaf.basic
{
import cocoa.Icon;
import cocoa.plaf.IconButtonSkin;

public class IconButtonSkin extends PushButtonSkin implements cocoa.plaf.IconButtonSkin
{
	private var _icon:Icon;
	public function set icon(value:Icon):void
	{
		_icon = value;
	}

	override protected function get bordered():Boolean
	{
		return false;
	}

	override protected function measure():void
	{
		measuredMinWidth = measuredWidth = 16 + 2 + 2;
		measuredMinHeight = measuredHeight = 16 + 3 + 3;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		// согласно Apple HIG — "Typically, the outer dimensions of an icon button include a margin of about 10 pixels all the way around the icon and label.", но пока что мы зашиваем значения Fluent UI
		_icon.draw(this, graphics, 2, 3);
	}
}
}