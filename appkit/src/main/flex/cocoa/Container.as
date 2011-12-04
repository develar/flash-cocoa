package cocoa {
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.util.SharedPoint;

import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.IEventDispatcher;

import net.miginfocom.layout.ComponentType;
import net.miginfocom.layout.ContainerWrapper;
import net.miginfocom.layout.ContainerWrappers;
import net.miginfocom.layout.LayoutUtil;

public class Container extends AbstractView implements ViewContainer, LookAndFeelProvider, ContainerWrapper {
  private static const VALIDATE_LISTENERS_ATTACHED:uint = 1 << 0;
  private static const CHECK_CACHE_SCHEDULED:uint = 1 << 1;
  private static const SOME_SUBVIEW_SIZE_INVALID:uint = 1 << 2;

  private var flags:uint;
  
  public function Container(components:Vector.<View>, layout:MigLayout) {
    _components = components;
    _layout = layout;
  }

  private var _layout:MigLayout;
  public function get layout():Object {
    return _layout;
  }

  public function validate():void {
    if ((flags & CHECK_CACHE_SCHEDULED) == 0) {
          checkCache();
        }

    _layout.layoutContainer(this);
  }

  override public function getMinimumWidth(hHint:int = -1):int {
    return _layout.preferredLayoutWidth(this, LayoutUtil.MIN);
  }

  override public function getMinimumHeight(wHint:int = -1):int {
    return _layout.preferredLayoutHeight(this, LayoutUtil.MIN);
  }

  override public function getPreferredWidth(hHint:int = -1):int {
    return _preferredWidth == 0 ? _layout.preferredLayoutWidth(this, LayoutUtil.PREF) : _preferredWidth;
  }

  public function set preferredWidth(value:int):void {
    _preferredWidth = value;
  }

  override public function getPreferredHeight(wHint:int = -1):int {
    return _preferredHeight == 0 ? _layout.preferredLayoutHeight(this, LayoutUtil.PREF) : _preferredHeight;
  }

  public function set preferredHeight(value:int):void {
    _preferredHeight = value;
  }

  public function paintDebugCell(x:Number, y:Number, width:Number, height:Number, first:Boolean):void {
    ContainerWrappers.paintDebugCell(this, x,  y,  width, height, first);
  }

  override public function getComponentType(disregardScrollPane:Boolean):int {
    return ComponentType.TYPE_CONTAINER;
  }

  protected var _components:Vector.<View>;
  public function get components():Vector.<View> {
    return _components;
  }

  public function get componentCount():int {
    return _components.length;
  }

  public function get leftToRight():Boolean {
    return true;
  }

  override public function get layoutHashCode():int {
    return 0;
  }

  public function get screenLocationX():Number {
    return localToGlobal(SharedPoint.createPoint(this)).x;
  }

  public function get screenLocationY():Number {
    return localToGlobal(SharedPoint.createPoint(this)).y;
  }

  public function get screenWidth():Number {
    return stage.stageWidth;
  }

  public function get screenHeight():Number {
    return stage.stageHeight;
  }

  public function get hasParent():Boolean {
    return parent != null;
  }

  protected var _laf:LookAndFeel;
  public function get laf():LookAndFeel {
    return _laf;
  }

  public function set laf(value:LookAndFeel):void {
    _laf = value;
  }

  override public function init(laf:LookAndFeel, container:DisplayObjectContainer):void {
    _laf = laf;

    for each (var view:View in components) {
      view.init(_laf, this);
    }
  }

  public function invalidateSubview(invalidateContainer:Boolean):void {
    if (invalidateContainer) {
      flags |= SOME_SUBVIEW_SIZE_INVALID;
    }

    if ((flags & VALIDATE_LISTENERS_ATTACHED) == 0) {
      flags |= VALIDATE_LISTENERS_ATTACHED;
      addEventListener(Event.ENTER_FRAME, enterFrameHandler);
    }
  }

  private function enterFrameHandler(event:Event):void {
    IEventDispatcher(event.currentTarget).removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
    if ((flags & CHECK_CACHE_SCHEDULED) == 0) {
      checkCache();
    }

    if (controls.length > 0) {
      var oldControls:Vector.<View> = controls;
      controls = new Vector.<View>();
      for each (var control:View in oldControls) {
        control.validate();
      }
    }
  }
}
}