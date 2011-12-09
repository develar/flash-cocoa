package cocoa {
import cocoa.plaf.LookAndFeelProvider;

public interface ContentView extends View, LookAndFeelProvider {
  function invalidateSubview(invalidateSuperview:Boolean = true):void;
}
}