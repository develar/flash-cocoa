package cocoa.border
{
internal class AbstractControlBitmapBorder extends AbstractMultipleBitmapBorder
{
	protected var _layoutHeight:Number;
	override public function get layoutHeight():Number
	{
		return _layoutHeight;
	}
}
}