package cocoa.plaf {
import cocoa.SkinnableView;

public interface Skin extends SimpleSkin {
  function get hostComponent():SkinnableView;

  function attach(component:SkinnableView):void;

  function hostComponentPropertyChanged():void;
}
}