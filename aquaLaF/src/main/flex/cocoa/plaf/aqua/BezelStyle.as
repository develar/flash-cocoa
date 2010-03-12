package cocoa.plaf.aqua
{
import org.flyti.lang.Enum;

public final class BezelStyle extends Enum
{
	public static const rounded:BezelStyle = new BezelStyle("rounded", 0);
	public static const texturedRounded:BezelStyle = new BezelStyle("texturedRounded", 1);

	public function BezelStyle(name:String, ordinal:int)
	{
		super(name, ordinal);
	}

	public static function valueOf(name:String):BezelStyle
	{
		return BezelStyle[name];
	}
}
}