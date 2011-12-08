package cocoa {
import net.miginfocom.layout.ContainerWrapper;

public interface RootContentView extends ContentView, ContainerWrapper {
  function addSubview(view:View):void;

  function set preferredWidth(value:int):void;

  function set preferredHeight(value:int):void;
}
}
