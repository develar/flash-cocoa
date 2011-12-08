package cocoa.plaf.basic {
import cocoa.Border;
import cocoa.ContentView;
import cocoa.ControlView;
import cocoa.Icon;
import cocoa.SkinnableView;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;

import mx.core.IFactory;

import org.flyti.plexus.Injectable;
import org.flyti.plexus.events.InjectorEvent;

/**
 * Default base skin implementation for view
 */
[Abstract]
public class AbstractSkin extends ControlView implements Skin {
  private var _component:SkinnableView;
  public final function get hostComponent():SkinnableView {
    return _component;
  }

  public final function get laf():LookAndFeel {
    return superview.laf;
  }

  protected final function getObject(key:String):Object {
    return superview.laf.getObject(_component.lafKey + "." + key, false);
  }

  protected final function getBorder(key:String = "b"):Border {
    return superview.laf.getBorder(_component.lafKey + "." + key, false);
  }

  protected final function getNullableBorder(key:String = "b"):Border {
    return superview.laf.getBorder(_component.lafKey + "." + key, true);
  }

  protected final function getIcon(key:String):Icon {
    return superview.laf.getIcon(_component.lafKey + "." + key);
  }

  protected final function getFactory(key:String):IFactory {
    return superview.laf.getFactory(_component.lafKey + "." + key, false);
  }

  public function attach(component:SkinnableView):void {
    _component = component;
  }

  override public function addToSuperview(superview:ContentView):void {
    super.addToSuperview(superview);

    // Скин, в отличии от других элементов, также может содержать local event map — а контейнер с инжекторами мы находим посредством баблинга,
    // поэтому отослать InjectorEvent мы должны от самого скина и только после того, как он будет добавлен в display list.
    if (_component is Injectable) {
      dispatchEvent(new InjectorEvent(_component, _component.linkId));
    }

    doInit();
  }

  protected function doInit():void {
  }

  public function hostComponentPropertyChanged():void {
    invalidate(true);
  }

  public function setVisibleAndBurnInHellAdobe(value:Boolean):void {
    visible = value;
  }
}
}