package cocoa
{
import org.flyti.lang.Enum;

public final class ToggleButtonState extends Enum
{
	public static const up:ToggleButtonState = new ToggleButtonState("up", 0);
	public static const down:ToggleButtonState = new ToggleButtonState("down", 1);
	public static const disabled:ToggleButtonState = new ToggleButtonState("disabled", 2);

	public static const upAndSelected:ToggleButtonState = new ToggleButtonState("upAndSelected", 3);
	public static const disabledAndSelected:ToggleButtonState = new ToggleButtonState("disabledAndSelected", 4);

	// Aqua over и downAndSelected не поддерживает, но для совместимости, да и мало ли кому нужен будет скин с over/downAndSelected state
	public static const over:ToggleButtonState = new ToggleButtonState("over", 5);
	public static const downAndSelected:ToggleButtonState = new ToggleButtonState("downAndSelected", 6);

	public function ToggleButtonState(name:String, ordinal:int)
	{
		super(name, ordinal);
	}

	public static function valueOf(name:String):ToggleButtonState
	{
		return ToggleButtonState[name];
	}
}
}