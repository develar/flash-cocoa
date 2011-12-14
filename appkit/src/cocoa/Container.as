package cocoa {
import cocoa.plaf.LookAndFeel;
import cocoa.util.SharedPoint;

import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.errors.IllegalOperationError;

import net.miginfocom.layout.ComponentType;
import net.miginfocom.layout.ComponentWrapper;
import net.miginfocom.layout.ContainerWrappers;
import net.miginfocom.layout.LayoutUtil;

[DefaultProperty("subviews")]
public class Container extends SpriteBackedView implements RootContentView {
  public function Container() {
    mouseEnabled = false;
  }

  public function getPixelUnitFactor(isHor:Boolean):Number {
    return 1;
  }
  
  private var _border:Border;
  public function set border(value:Border):void {
    _border = value;
  }

  public function get insets():Insets {
    return _border == null ? Insets.EMPTY : _border.contentInsets;
  }

  private var _subviews:Vector.<ComponentWrapper>;
  public function set subviews(value:Vector.<ComponentWrapper>):void {
    _subviews = value;
    if (parent != null) {
      addSubviews();
    }
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

    if ((flags & LayoutState.DISPLAY_INVALID) != 0) {
      flags &= ~LayoutState.DISPLAY_INVALID;

      if (_border == null) {
        return;
      }
      
      var g:Graphics = graphics;
      g.clear();
      _border.draw(g, actualWidth, actualHeight);
    }
  }

  override public function getMinimumWidth(hHint:int = -1):int {
    return _layout.preferredLayoutWidth(LayoutUtil.MIN);
  }

  override public function getMinimumHeight(wHint:int = -1):int {
    return _layout.preferredLayoutHeight(LayoutUtil.MIN);
  }

  override public function getPreferredWidth(hHint:int = -1):int {
    return _layout.preferredLayoutWidth(LayoutUtil.PREF);
  }

  override public function getPreferredHeight(wHint:int = -1):int {
    return _layout.preferredLayoutHeight(LayoutUtil.PREF);
  }

  override public function setSize(w:int, h:int):void {
    var resized:Boolean = false;
    if (w != _actualWidth) {
      _actualWidth = w;
      resized = true;
    }
    if (h != _actualHeight) {
      _actualHeight = h;
      resized = true;
    }

    super.setSize(w, h);

    if (resized) {
      flags |= LayoutState.DISPLAY_INVALID;
      _layout.invalidateContainerSize();
    }
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

  protected function initRoot(laf:LookAndFeel):void {
    _laf = laf;
    addSubviews();
  }

  override public function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void {
    super.addToSuperview(displayObjectContainer, laf, superview);

    if (laf != null) {
      _laf = laf;
    }
    addSubviews();
  }

  private function addSubviews():void {
    for each (var view:View in components) {
      view.addToSuperview(this, laf, this);
    }
  }

  public function invalidateSubview(invalidateSuperview:Boolean = true):void {
    _layout.invalidateSubview(invalidateSuperview);
  }

  public function get displayObject():DisplayObjectContainer {
    return this;
  }

  public function addSubview(view:View):void {
    if (_subviews.indexOf(view) != -1) {
      throw new IllegalOperationError("already added");
    }

    _subviews[_subviews.length] = view;
    view.addToSuperview(this, laf, this);
    _layout.invalidateSubview(true);
  }
}
}