package cocoa
{
public final class TextInsets
{
	public var left:Number;
	public var right:Number;
	public var bottom:Number;

	public function TextInsets(left:Number = 0, right:Number = 0, bottom:Number = 0)
	{
		this.left = left;
		this.right = right;
		this.bottom = bottom;

		_width = left + right;
	}

	private var _width:Number;
	public function get width():Number
	{
		return _width;
	}
}
}