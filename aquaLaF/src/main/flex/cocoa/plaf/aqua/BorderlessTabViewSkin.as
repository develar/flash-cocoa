package cocoa.plaf.aqua
{
import cocoa.Insets;

public class BorderlessTabViewSkin extends AbstractTabViewSkin
{
	private static const CONTENT_INSETS:Insets = new Insets(0, 29, 0, 0);

	override protected function get contentInsets():Insets
	{
		return CONTENT_INSETS;
	}
}
}