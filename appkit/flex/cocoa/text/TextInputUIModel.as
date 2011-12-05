package cocoa.text {
/**
 * @todo handle displayAsPassword
 */
public class TextInputUIModel extends TextUIModel {
  private static const DISPLAY_AS_PASSWORD:uint = 1 << 0;

  public function get displayAsPassword():Boolean {
    return (flags & DISPLAY_AS_PASSWORD) != 0;
  }

  public function set displayAsPassword(value:Boolean):void {
    if (value == ((flags & DISPLAY_AS_PASSWORD) == 0)) {
      return;
    }

    value ? flags &= ~DISPLAY_AS_PASSWORD : flags |= DISPLAY_AS_PASSWORD;
  }

  private static var defaultModel:TextInputUIModel;
  public static function getDefault():TextInputUIModel {
    if (defaultModel == null) {
      defaultModel = new TextInputUIModel();
    }
    return defaultModel;
  }
}
}