package cocoa
{
public final class FrameInsets
{
	public var left:Number;
	public var top:Number;
	public var right:Number;

	public var bottom:Number;

	public function FrameInsets(left:Number = 0, top:Number = 0, right:Number = 0, bottom:Number = 0)
	{
		this.left = left;
		this.top = top;
		this.right = right;

		this.bottom = bottom;
	}
}
}