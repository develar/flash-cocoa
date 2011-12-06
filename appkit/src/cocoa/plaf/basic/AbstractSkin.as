package cocoa.plaf.basic {
import cocoa.Border;
import cocoa.Container;
import cocoa.ContentView;
import cocoa.ControlView;
import cocoa.Icon;
import cocoa.SkinnableView;
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
    doInit();
  }

  protected function doInit():void {
    // Скин, в отличии от других элементов, также может содержать local event map — а контейнер с инжекторами мы находим посредством баблинга,
    // поэтому отослать InjectorEvent мы должны от самого скина и только после того, как он будет добавлен в display list.
    if (_component is Injectable) {
      dispatchEvent(new InjectorEvent(_component, _component.linkId));
    }
  }

  override public function setBounds(x:Number, y:Number, width:int, height:int):void {
    this.x = x;
    this.y = y;

    var resized:Boolean = false;
    if (width != _actualWidth) {
      _actualWidth = width;
      resized = true;
    }
    if (height != _actualHeight) {
      _actualHeight = height;
      resized = true;
    }

    if (resized) {

    }
  }

  public function hostComponentPropertyChanged():void {
    invalidate(true);
  }
}
}