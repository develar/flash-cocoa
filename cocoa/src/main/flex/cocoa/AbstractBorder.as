package cocoa
{
public class AbstractBorder
{
	private static const EMPTY_INSETS:Insets = new Insets();

	protected var _frameInsets:Insets = EMPTY_INSETS;
	public function get frameInsets():Insets
	{
		return _frameInsets;
	}

	protected var _contentInsets:Insets = EMPTY_INSETS;
	public function get contentInsets():Insets
	{
		return _contentInsets;
	}
}
}