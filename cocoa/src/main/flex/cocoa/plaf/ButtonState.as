package cocoa.plaf
{
import org.flyti.lang.Enum;

public final class ButtonState extends Enum
{
	public static const up:ButtonState = new ButtonState("up", 0);
	public static const down:ButtonState = new ButtonState("down", 1);
	public static const disabled:ButtonState = new ButtonState("disabled", 2);

	// Aqua over не поддерживает, но для совместимости, да и мало ли кому нужен будет скин с over state
	public static const over:ButtonState = new ButtonState("over", 3);

	public function ButtonState(name:String, ordinal:int)
	{	
		super(name, ordinal);
	}

	public static function valueOf(name:String):ButtonState
	{
		return ButtonState[name];
	}
}
}