package cocoa {
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.errors.IllegalOperationError;

import net.miginfocom.layout.CC;
import net.miginfocom.layout.ComponentType;
import net.miginfocom.layout.LayoutUtil;
import net.miginfocom.layout.PlatformDefaults;

[Abstract]
public class AbstractView extends Sprite implements View {
  internal static const DEFAULT_MAX_WIDTH:int = 32767;
  internal static const DEFAULT_MAX_HEIGHT:int = 32767;

  public function AbstractView() {
    super();

    focusRect = false;
  }

  private var _constraints:CC;
  public function get constraints():CC {
    return _constraints;
  }

  public function get component():Object {
    return this;
  }

  private var _actualWidth:int;
  public function get actualWidth():int {
    return _actualWidth;
  }

  private var _actualHeight:int;
  public function get actualHeight():int {
    return _actualHeight;
  }

  private var minWidth:int;
  private var minHeight:int;
  public function getMinimumWidth(hHint:int = -1):int {
    return minWidth;
  }

  public function getMinimumHeight(wHint:int = -1):int {
    return minHeight;
  }

  protected var _preferredWidth:int;
  public function getPreferredWidth(hHint:int = -1):int {
    return _preferredWidth;
  }

  protected var _preferredHeight:int;
  public function getPreferredHeight(wHint:int = -1):int {
    return _preferredHeight;
  }

  public function getMaximumWidth(hHint:int = -1):int {
    return DEFAULT_MAX_WIDTH;
  }

  public function getMaximumHeight(wHint:int = -1):int {
    return DEFAULT_MAX_HEIGHT;
  }
  
  public function setBounds(x:Number, y:Number, width:int, height:int):void {
    this.x = x;
    this.y = y;

    _actualWidth = width;
    _actualHeight = height;
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
    return name;
  }

  public function get layoutHashCode():int {
    return LayoutUtil.calculateHash(this);
  }

  public function getComponentType(disregardScrollPane:Boolean):int {
    return ComponentType.TYPE_UNKNOWN;
  }

  public function init(laf:LookAndFeel, container:DisplayObjectContainer):void {
    throw new IllegalOperationError("Abstract");
  }
}
}