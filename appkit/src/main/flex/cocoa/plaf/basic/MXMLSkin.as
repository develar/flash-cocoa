package cocoa.plaf.basic {
import cocoa.Component;
import cocoa.MXMLContainer;
import cocoa.layout.LayoutMetrics;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;

import mx.core.IStateClient;
import mx.core.mx_internal;

import org.flyti.plexus.Injectable;
import org.flyti.plexus.events.InjectorEvent;

use namespace mx_internal;

public class MXMLSkin extends MXMLContainer implements Skin, IStateClient {
  private static const EMPTY_LAYOUT_METRICS:LayoutMetrics = new LayoutMetrics();

  private var _component:Component;
  public function get component():Component {
    return _component;
  }

  protected var _resourceBundle:String;
  public function get resourceBundle():String {
    return _resourceBundle;
  }

  public function set resourceBundle(value:String):void {
    _resourceBundle = value;
  }

  protected function l(key:String):String {
    return resourceManager.getString(_resourceBundle, key);
  }

  public function set layoutMetrics(value:LayoutMetrics):void {
    _layoutMetrics = value;
    // currently we use only fixed, not percent
    if (!isNaN(_layoutMetrics.width)) {
      explicitWidth = _layoutMetrics.width;
      _width = _layoutMetrics.width;
    }
    if (!isNaN(_layoutMetrics.height)) {
      explicitHeight = _layoutMetrics.height;
      _height = _layoutMetrics.height;
    }
  }

  override public function get left():Object {
    return _layoutMetrics.left;
  }

  override public function set left(value:Object):void {
    throw new Error("unsupported");
  }

  override public function get right():Object {
    return _layoutMetrics.right;
  }

  override public function set right(value:Object):void {
    throw new Error("unsupported");
  }

  override public function get top():Object {
    return _layoutMetrics.top;
  }

  override public function set top(value:Object):void {
    throw new Error("unsupported");
  }

  override public function get bottom():Object {
    return _layoutMetrics.bottom;
  }

  override public function set bottom(value:Object):void {
    throw new Error("unsupported");
  }

  override public function get horizontalCenter():Object {
    return _layoutMetrics.horizontalCenter;
  }

  override public function set horizontalCenter(value:Object):void {
    throw new Error("unsupported");
  }

  override public function get verticalCenter():Object {
    return _layoutMetrics.verticalCenter;
  }

  override public function set verticalCenter(value:Object):void {
    throw new Error("unsupported");
  }

  override public function get baseline():Object {
    return _layoutMetrics.baseline;
  }

  override public function set baseline(value:Object):void {
    throw new Error("unsupported");
  }

  override public function get percentWidth():Number {
    return _layoutMetrics.widthIsPercent ? _layoutMetrics.width : NaN;
  }

  override public function set percentWidth(value:Number):void {
    throw new Error("unsupported");
  }

  override public function get percentHeight():Number {
    return _layoutMetrics.heightIsPercent ? _layoutMetrics.height : NaN;
  }

  override public function set percentHeight(value:Number):void {
    throw new Error("unsupported");
  }

  override protected function commitProperties():void {
    if (component != null) // будет если используется как mxml скин для flex-based компонента
    {
      component.commitProperties();
    }
    super.commitProperties();
  }

  override protected function createChildren():void {
    // Скин, в отличии от других элементов, также может содержать local event map — а контейнер с инжекторами мы находим посредством баблинга,
    // поэтому отослать InjectorEvent мы должны от самого скина и только после того, как он будет добавлен в display list.
    if (_component is Injectable) {
      dispatchEvent(new InjectorEvent(_component));
    }

    super.createChildren();
  }

  public function attach(component:Component, laf:LookAndFeel):void {
    _component = component;
    _laf = laf;

    this["hostComponent"] = component;
  }

  public function MXMLSkin() {
    super();

    _layoutMetrics = EMPTY_LAYOUT_METRICS;
  }
}
}