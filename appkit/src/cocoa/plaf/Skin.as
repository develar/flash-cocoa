package cocoa.plaf {
import cocoa.Component;

public interface Skin extends SimpleSkin {
  function get hostComponent():Component;

  function attach(component:Component):void;

  function hostComponentPropertyChanged():void;
}
}