package cocoa.layout
{
public final class LayoutMetrics
{
  public static const PERCENT_WIDTH:uint = 1 << 0;
  public static const PERCENT_HEIGHT:uint = 1 << 1;

  public var flags:uint;

	public var left:Number;
	public var right:Number;

	public var horizontalCenter:Number;
	public var verticalCenter:Number;

	public var top:Number;
	public var bottom:Number;

	public var baseline:Number;

	public var width:Number;
	public var height:Number;
}
}