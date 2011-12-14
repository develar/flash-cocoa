package cocoa.plaf.basic {
import cocoa.Border;
import cocoa.ContentView;
import cocoa.ControlView;
import cocoa.Icon;
import cocoa.SkinnableView;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;

import flash.display.DisplayObjectContainer;

import mx.core.IFactory;

import org.flyti.plexus.Injectable;
import org.flyti.plexus.events.InjectorEvent;

/**
 * Default base skin implementation for view
 */
[Abstract]
public class AbstractSkin extends ControlView implements Skin {
  protected var _laf:LookAndFeel;

  private var _hostComponent:SkinnableView;
  public final function get hostComponent():SkinnableView {
    return _hostComponent;
  }

  public final function get laf():LookAndFeel {
    return _laf;
  }

  protected final function getObject(key:String):Object {
    return _laf.getObject(_hostComponent.lafKey + "." + key, false);
  }

  protected final function getBorder(key:String = "b"):Border {
    return _laf.getBorder(_hostComponent.lafKey + "." + key, false);
  }

  protected final function getNullableBorder(key:String = "b"):Border {
    return _laf.getBorder(_hostComponent.lafKey + "." + key, true);
  }

  protected final function getIcon(key:String):Icon {
    return _laf.getIcon(_hostComponent.lafKey + "." + key);
  }

  protected final function getFactory(key:String, nullable:Boolean = false):IFactory {
    return _laf.getFactory(_hostComponent.lafKey + "." + key, nullable);
  }

  override public function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void {
    super.addToSuperview(displayObjectContainer, laf, superview);
    _laf = laf;
  }

  public function attach(component:SkinnableView):void {
    _hostComponent = component;

    // Скин, в отличии от других элементов, также может содержать local event map — а контейнер с инжекторами мы находим посредством баблинга,
    // поэтому отослать InjectorEvent мы должны от самого скина и только после того, как он будет добавлен в display list.
    if (_hostComponent is Injectable) {
      dispatchEvent(new InjectorEvent(_hostComponent, _hostComponent.linkId));
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

  override public function set visible(value:Boolean):void {
    if (visible != value) {
      super.visible = value;
      if (superview != null) {
        superview.invalidateSubview(true);
      }
    }
  }
}
}