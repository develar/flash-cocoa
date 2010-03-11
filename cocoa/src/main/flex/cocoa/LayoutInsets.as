package cocoa
{
/**
 * bottom не нужен, так как мы рисуем сверху вниз — как получилось, так и получилось.
 * Но таки иногда он нужен для определенных расчетов — Scale9BitmapBorder. 
 */
public final class LayoutInsets
{
	public var left:Number;
	public var top:Number;
	public var right:Number;

	public var bottom:Number;

	public function LayoutInsets(left:Number = 0, top:Number = 0, right:Number = 0, bottom:Number = 0)
	{
		this.left = left;
		this.top = top;
		this.right = right;

		this.bottom = bottom;
	}
}
}