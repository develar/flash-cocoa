package cocoa.plaf.basic {
import cocoa.Border;
import cocoa.Component;
import cocoa.ControlView;
import cocoa.Icon;
import cocoa.UIPartProvider;
import cocoa.plaf.Skin;

import mx.core.IFactory;

import org.flyti.plexus.Injectable;
import org.flyti.plexus.events.InjectorEvent;

/**
 * Default base skin implementation for view
 */
[Abstract]
public class AbstractSkin extends ControlView implements Skin {
  private var _component:Component;
  public final function get hostComponent():Component {
    return _component;
  }

  protected final function getObject(key:String):Object {
    return container.laf.getObject(_component.lafKey + "." + key, false);
  }

  protected final function getBorder(key:String = "b"):Border {
    return container.laf.getBorder(_component.lafKey + "." + key, false);
  }

  protected final function getNullableBorder(key:String = "b"):Border {
    return container.laf.getBorder(_component.lafKey + "." + key, true);
  }

  protected final function getIcon(key:String):Icon {
    return container.laf.getIcon(_component.lafKey + "." + key);
  }

  protected final function getFactory(key:String):IFactory {
    return container.laf.getFactory(_component.lafKey + "." + key, false);
  }

  public function attach(component:Component):void {
    _component = component;

    createChildren();
    container.addChild(this);
  }

  protected function createChildren():void {
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