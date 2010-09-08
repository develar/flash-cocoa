package cocoa.plaf.basic {
import cocoa.lang.Enum;

public final class BottomBarStyle extends Enum {
  public static const application:BottomBarStyle = new BottomBarStyle("application");
  public static const chooseDialog:BottomBarStyle = new BottomBarStyle("chooseDialog");

  public function BottomBarStyle(name:String, ordinal:int = -1) {
    super(name, ordinal);
  }
}
}