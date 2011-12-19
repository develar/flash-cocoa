package cocoa.plaf {
import cocoa.SkinnableView;
import cocoa.View;

  public interface Skin extends View {
  function get component():SkinnableView;

  function attach(component:SkinnableView):void;

  function hostComponentPropertyChanged():void;

  function setVisibleAndBurnInHellAdobe(value:Boolean):void;
}
}