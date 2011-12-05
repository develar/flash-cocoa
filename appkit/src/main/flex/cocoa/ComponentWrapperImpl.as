package cocoa {
import flash.errors.IllegalOperationError;

import net.miginfocom.layout.CC;
import net.miginfocom.layout.ComponentType;
import net.miginfocom.layout.LayoutUtil;
import net.miginfocom.layout.PlatformDefaults;

[Abstract]
internal class ComponentWrapperImpl implements View {
  private var _constraints:CC;
  public function get constraints():CC {
    return _constraints;
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
    return AbstractView.DEFAULT_MAX_WIDTH;
  }

  public function getMaximumHeight(wHint:int = -1):int {
    return AbstractView.DEFAULT_MAX_HEIGHT;
  }

  public function setBounds(x:Number, y:Number, width:int, height:int):void {
    throw new IllegalOperationError("Abstract");
  }

  public function getBaseline(width:int, height:int):int {
    return -1;
  }

  public function get hasBaseline():Boolean {
    return false;
  }

  public function getPixelUnitFactor(isHor:Boolean):Number {
    return 1;
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
    return LayoutUtil.calculateHash(this);
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
    return true;
  }

  public function init(container:Container):void {
    throw new IllegalOperationError("Abstract");
  }

  public function validate():void {
  }

  public function get enabled():Boolean {
    return true;
  }
}
}
