package cocoa {
import flash.display.Sprite;

import mx.core.UIComponentGlobals;
import mx.core.mx_internal;

import net.miginfocom.layout.ComponentType;

import net.miginfocom.layout.ComponentWrapper;
import net.miginfocom.layout.LayoutUtil;
import net.miginfocom.layout.PlatformDefaults;

use namespace mx_internal;
[Abstract]
public class AbstractView extends Sprite implements View, ComponentWrapper {
  private static const INITIALIZED:uint = 1 << 0;
  private static const DISABLED:uint = 1 << 11;
  private static const EXCLUDE_FROM_LAYOUT:uint = 1 << 12;

  private static const INVALID_PROPERTIES:uint = 1 << 5;
  private static const INVALID_SIZE:uint = 1 << 6;
  private static const INVALID_DISPLAY_LIST:uint = 1 << 7;

  /**
   * if component has been reparented, we need to potentially reassign systemManager, cause we could be in a new Window.
   */
  private static const SYSTEM_MANAGER_DIRTY:uint = 1 << 14;

  private static const HAS_FOCUSABLE_CHILDREN:uint = 1 << 15;
  private static const FOCUS_ENABLED:uint = 1 << 16;
  private static const MOUSE_FOCUS_ENABLED:uint = 1 << 17;
  private static const TAB_FOCUS_ENABLED:uint = 1 << 18;

  private var flags:uint = FOCUS_ENABLED | MOUSE_FOCUS_ENABLED;

  private static const DEFAULT_MAX_WIDTH:Number = 10000;
  private static const DEFAULT_MAX_HEIGHT:Number = 10000;

  public function AbstractView() {
    super();

    focusRect = false;
  }

  private var _preferredWidth:Number;
  public function getPreferredWidth():Number {
    return _preferredWidth;
  }

  private var _preferredHeight:Number;
  public function getPreferredHeight():Number {
    return _preferredHeight;
  }


  protected function createChildren():void {
  }

  public final function invalidateProperties():void {
    if ((flags & INVALID_PROPERTIES) == 0) {
      flags |= INVALID_PROPERTIES;

      if (parent != null) {
        UIComponentGlobals.layoutManager.invalidateProperties(this);
      }
    }
  }

  public final function invalidateSize():void {
    if ((flags & INVALID_SIZE) == 0) {
      flags |= INVALID_SIZE;

      if (parent != null) {
        UIComponentGlobals.layoutManager.invalidateSize(this);
      }
    }
  }

  public function validateProperties():void {
    if (flags & INVALID_PROPERTIES) {
      commitProperties();
      flags &= ~INVALID_PROPERTIES;
    }
  }

  protected function commitProperties():void {
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
    return LayoutUtil.calculateHash(width, height, visible, linkId);
  }

  public function getComponentType(disregardScrollPane:Boolean):int {
    return ComponentType.TYPE_UNKNOWN;
  }
}
}