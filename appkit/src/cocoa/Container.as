package cocoa {
import cocoa.border.EmptyBorder;
import cocoa.plaf.LookAndFeel;
import cocoa.util.SharedPoint;

import flash.display.DisplayObjectContainer;

import net.miginfocom.layout.ComponentType;
import net.miginfocom.layout.ComponentWrapper;
import net.miginfocom.layout.ContainerWrapper;
import net.miginfocom.layout.ContainerWrappers;
import net.miginfocom.layout.LayoutUtil;

[DefaultProperty("subviews")]
public class Container extends SpriteBackedView implements ContentView, ContainerWrapper {
  public function Container() {
    mouseEnabled = false;
  }
  
  private var _border:Border = EmptyBorder.EMPTY;
  public function set border(value:Border):void {
    _border = value;
  }

  public function get insets():Insets {
    return _border.contentInsets;
  }

  private var _subviews:Vector.<ComponentWrapper>;
  public function set subviews(value:Vector.<ComponentWrapper>):void {
    _subviews = value;
  }

  private var _layout:MigLayout;
  public function set layout(value:MigLayout):void {
    if (_layout != value) {
      _layout = value;
      if (_layout != null) {
        _layout.container = this;
      }
    }
  }

  public function getLayout():Object {
    return _layout;
  }

  override public function validate():void {
    _layout.validate();
  }

  override public function getMinimumWidth(hHint:int = -1):int {
    return _layout.preferredLayoutWidth(LayoutUtil.MIN);
  }

  override public function getMinimumHeight(wHint:int = -1):int {
    return _layout.preferredLayoutHeight(LayoutUtil.MIN);
  }

  override public function getPreferredWidth(hHint:int = -1):int {
    return _preferredWidth == 0 ? _layout.preferredLayoutWidth(LayoutUtil.PREF) : _preferredWidth;
  }

  public function set preferredWidth(value:int):void {
    _preferredWidth = value;
    _layout.invalidateSubview(true);
  }

  override public function getPreferredHeight(wHint:int = -1):int {
    return _preferredHeight == 0 ? _layout.preferredLayoutHeight(LayoutUtil.PREF) : _preferredHeight;
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

  public function get components():Vector.<ComponentWrapper> {
    return _subviews;
  }

  public function get componentCount():int {
    return _subviews.length;
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

  public function initRoot(laf:LookAndFeel):void {
    _laf = laf;
    initSubviews();
  }

  override public function addToSuperview(superview:ContentView):void {
    super.addToSuperview(superview);

    _laf = superview.laf;
    initSubviews();
  }

  override public function removeFromSuperview(superview:ContentView):void {
    super.removeFromSuperview(superview);
  }

  private function initSubviews():void {
    for each (var view:View in components) {
      view.addToSuperview(this);
    }
  }

  public function invalidateSubview(invalidateSuperview:Boolean = true):void {
    _layout.invalidateSubview(invalidateSuperview);
  }

  public function get displayObject():DisplayObjectContainer {
    return this;
  }
}
}