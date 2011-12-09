package cocoa.plaf.basic {
import cocoa.Container;
import cocoa.SkinnableView;
import cocoa.plaf.Skin;

public class BoxSkin extends Container implements Skin {
  private var _component:SkinnableView;

  public final function get hostComponent():SkinnableView {
    return _component;
  }

  public function attach(component:SkinnableView):void {
    _component = component;
    component.uiPartAdded("contentView", this);
  }

  public function hostComponentPropertyChanged():void {
    //invalidate(true);
  }

  public function setVisibleAndBurnInHellAdobe(value:Boolean):void {
    visible = value;
  }
}
}