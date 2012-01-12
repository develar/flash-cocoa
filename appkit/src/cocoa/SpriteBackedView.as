package cocoa {
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.errors.IllegalOperationError;

import net.miginfocom.layout.CC;
import net.miginfocom.layout.ComponentType;
import net.miginfocom.layout.ConstraintParser;

/**
 * getPreferredWidth/getPreferredHeight are not declared as abstract because some user component can be intended for works with only "fill" constraints
 */

[Abstract]
public class SpriteBackedView extends Sprite implements View {
  internal static const DEFAULT_MAX_WIDTH:int = 32767;
  internal static const DEFAULT_MAX_HEIGHT:int = 32767;

  protected static const HAS_BASELINE:uint = 1 << 0;
  protected static const MIN_EQUALS_PREF:uint = 1 << 2;
  protected static const DISABLED:uint = 1 << 1;

  protected var flags:uint;

  public function SpriteBackedView() {
    super();

    focusRect = false;
  }

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

  protected var _actualWidth:int = -1;
  public function get actualWidth():int {
    return _actualWidth;
  }

  protected var _actualHeight:int = -1;
  public function get actualHeight():int {
    return _actualHeight;
  }

  public function getMinimumWidth(hHint:int = -1):int {
    return (flags & MIN_EQUALS_PREF) == 0 ? 0 : getPreferredWidth(hHint);
  }

  public function getMinimumHeight(wHint:int = -1):int {
    return (flags & MIN_EQUALS_PREF) == 0 ? 0 : getPreferredHeight(wHint);
  }

  public function getPreferredWidth(hHint:int = -1):int {
    return 0;
  }

  public function getPreferredHeight(wHint:int = -1):int {
    return 0;
  }

  public function getMaximumWidth(hHint:int = -1):int {
    return DEFAULT_MAX_WIDTH;
  }

  public function getMaximumHeight(wHint:int = -1):int {
    return DEFAULT_MAX_HEIGHT;
  }
  
  public function setBounds(x:Number, y:Number, w:int, h:int):void {
    setLocation(x, y);
    setSize(w, h);
  }

  public function setLocation(x:Number, y:Number):void {
    this.x = x;
    this.y = y;
  }

  public final function setSize(w:int, h:int):void {
    var resized:Boolean = false;
    if (w != _actualWidth) {
      _actualWidth = w;
      resized = true;
    }
    if (h != _actualHeight) {
      _actualHeight = h;
      resized = true;
    }

    if (resized) {
      // after setBounds/setLocation/setSize superview validate subview (i.e. call subview.validate) in any case — subview doesn't need to invalidate container
      flags |= LayoutState.DISPLAY_INVALID;
      sizeInvalidated();
    }
  }

  protected function sizeInvalidated():void {

  }

  public function getBaseline(w:int, h:int):int {
    return -1;
  }

  public final function get hasBaseline():Boolean {
    return (flags & HAS_BASELINE) != 0;
  }

  public function get visualPadding():Vector.<int> {
    return null;
  }

  public function paintDebugOutline():void {
  }

  public function get linkId():String {
    return null;
  }

  public function get layoutHashCode():int {
    return 0;
  }

  public function getComponentType(disregardScrollPane:Boolean):int {
    return ComponentType.TYPE_UNKNOWN;
  }

  public function validate():Boolean {
    throw new IllegalOperationError("abstract");
  }

  public function get enabled():Boolean {
    return (flags & DISABLED) == 0;
  }

  public function set enabled(value:Boolean):void {
    value ? flags &= ~DISABLED : flags |= DISABLED;
  }

  public function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void {
    displayObjectContainer.addChild(this);
  }

  public function removeFromSuperview():void {
    parent.removeChild(this);
  }
}
}