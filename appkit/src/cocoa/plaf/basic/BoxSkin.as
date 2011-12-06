package cocoa.plaf.basic {
import cocoa.Container;
import cocoa.ContentView;
import cocoa.SkinnableView;
import cocoa.plaf.Skin;

public class BoxSkin extends Container implements Skin {
  private var _component:SkinnableView;

  public final function get hostComponent():SkinnableView {
    return _component;
  }

  override public function addToSuperview(superview:ContentView):void {
    super.addToSuperview(superview);

    hostComponent.uiPartAdded("contentView", this);
  }

  override public function validate():void {
    super.validate();
  }

  public function attach(component:SkinnableView):void {
    _component = component;
  }

  public function hostComponentPropertyChanged():void {
    //invalidate(true);
  }
}
}