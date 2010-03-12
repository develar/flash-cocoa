package cocoa.bar
{
import mx.core.IFlexDisplayObject;

import org.flyti.view.IconedItemRenderer;

import spark.primitives.BitmapImage;

public class IconBarButton extends BarButton implements IconedItemRenderer
{
	[SkinPart(required="true")]
	public var iconDisplay:BitmapImage;

	private var _icon:IFlexDisplayObject;
	public function set icon(value:IFlexDisplayObject):void
	{
		if (value != _icon)
		{
			_icon = value;
			iconDisplay.source = _icon;
		}
	}

	override public function set label(value:String):void
    {
        if (value != label)
        {
			super.label = value;

			//toolTip = value;
		}
	}
}
}