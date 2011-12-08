package cocoa.plaf.basic {
import cocoa.Container;
import cocoa.ContentView;
import cocoa.SkinnableView;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;

import flash.display.DisplayObjectContainer;

public class BoxSkin extends Container implements Skin {
  private var _component:SkinnableView;

  public final function get hostComponent():SkinnableView {
    return _component;
  }

  override public function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void {
    super.addToSuperview(displayObjectContainer, laf, superview);

    hostComponent.uiPartAdded("contentView", this);
  }

  public function attach(component:SkinnableView):void {
    _component = component;
  }

  public function hostComponentPropertyChanged():void {
    //invalidate(true);
  }

  public function setVisibleAndBurnInHellAdobe(value:Boolean):void {
    visible = value;
  }
}
}