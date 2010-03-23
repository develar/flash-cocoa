package cocoa
{
public class TextInsets extends Insets
{
	public var truncatedTailMargin:Number;

	/**
	 * pop up button title обрезается с конца, при этом отступ от края области со стрелками не 9 как для необрезанного, а чуть-меньше — около 4
	 */
	public function TextInsets(left:Number = 0, top:Number = 0, right:Number = 0, bottom:Number = 0, truncatedTailMargin:Number = NaN)
	{
		super(left, top, right, bottom);

		this.truncatedTailMargin = isNaN(truncatedTailMargin) ? right : truncatedTailMargin;
	}
}
}