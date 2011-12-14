package cocoa {
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObjectContainer;
import flash.errors.IllegalOperationError;

import net.miginfocom.layout.CC;
import net.miginfocom.layout.ComponentType;
import net.miginfocom.layout.ConstraintParser;
import net.miginfocom.layout.PlatformDefaults;

[Abstract]
internal class ObjectBackedView implements View {
  protected static const INVISIBLE:uint = 1 << 0;
  protected static const DISABLED:uint = 1 << 1;

  protected var flags:uint;

  private var _constraints:CC;
  public function get constraints():CC {
    return _constraints;
  }

  public function set constraints(value:CC):void {
    _constraints = value;
  }

  public function set c(value:String):void {
    _constraints = ConstraintParser.parseComponentConstraint(value);
  }

  public function get component():Object {
    throw new IllegalOperationError("Abstract");
  }

  public function get actualWidth():int {
    throw new IllegalOperationError("Abstract");
  }

  public function get actualHeight():int {
    throw new IllegalOperationError("Abstract");
  }

  public function getMinimumWidth(hHint:int = -1):int {
    throw new IllegalOperationError("Abstract");
  }

  public function getMinimumHeight(wHint:int = -1):int {
    throw new IllegalOperationError("Abstract");
  }

  public function getPreferredWidth(hHint:int = -1):int {
    throw new IllegalOperationError("Abstract");
  }

  public function getPreferredHeight(wHint:int = -1):int {
    throw new IllegalOperationError("Abstract");
  }

  public function getMaximumWidth(hHint:int = -1):int {
    return SpriteBackedView.DEFAULT_MAX_WIDTH;
  }

  public function getMaximumHeight(wHint:int = -1):int {
    return SpriteBackedView.DEFAULT_MAX_HEIGHT;
  }

  public function setBounds(x:Number, y:Number, w:int, h:int):void {
    setLocation(x, y);
    setSize(w, h);
  }

  public function setSize(w:int, h:int):void {
    throw new IllegalOperationError("Abstract");
  }

  public function setLocation(x:Number, y:Number):void {
    throw new IllegalOperationError("Abstract");
  }

  public function getBaseline(width:int, height:int):int {
    return -1;
  }

  public function get hasBaseline():Boolean {
    return false;
  }

  public function get horizontalScreenDPI():Number {
    return PlatformDefaults.defaultDPI;
  }

  public function get verticalScreenDPI():Number {
    return PlatformDefaults.defaultDPI;
  }

  public function get visualPadding():Vector.<Number> {
    return null;
  }

  public function paintDebugOutline():void {
  }

  public function get linkId():String {
    return null;
  }

  public function get layoutHashCode():int {
    throw new IllegalOperationError("Abstract");
  }

  public function getComponentType(disregardScrollPane:Boolean):int {
    return ComponentType.TYPE_UNKNOWN;
  }

  public function get x():Number {
    throw new IllegalOperationError("Abstract");
  }

  public function get y():Number {
    throw new IllegalOperationError("Abstract");
  }

  public function get visible():Boolean {
    return (flags & INVISIBLE) == 0;
  }

  public function set visible(value:Boolean):void {
    value ? flags &= ~INVISIBLE : flags |= INVISIBLE;
  }

  public function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void {
    throw new IllegalOperationError("Abstract");
  }

  public function validate():void {
    throw new IllegalOperationError("Abstract");
  }

  public function get enabled():Boolean {
    return (flags & DISABLED) == 0;
  }

  public function set enabled(value:Boolean):void {
    value ? flags &= ~DISABLED : flags |= DISABLED;
  }

  public function removeFromSuperview():void {
    throw new IllegalOperationError("Abstract");
  }
}
}
