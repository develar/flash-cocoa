package cocoa {
import cocoa.border.Scale1BitmapBorder;

import flash.display.Graphics;

import mx.core.UIComponent;
import mx.core.mx_internal;

import spark.components.Button;

use namespace mx_internal;

public class FlexButton extends Button {
  protected var _border:Border;
  public function get border():Border {
    return _border;
  }

  public function set border(value:Border):void {
    _border = value;
  }

  override public function getStyle(styleProp:String):* {
    switch (styleProp) {
      case "repeatDelay": return 500;
      case "repeatInterval": return 35;
    }

    return undefined;
  }

  override protected function measure():void {
    if (!isNaN(_border.layoutWidth)) {
      measuredMinWidth = measuredWidth = _border.layoutWidth;
    }
    measuredMinHeight = measuredHeight = _border.layoutHeight;
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    var g:Graphics = graphics;
    g.clear();
    _border.draw(g, w, h);
  }

  override protected function attachSkin():void {

  }

  override protected function detachSkin():void {

  }

  override public function setConstraintValue(constraintName:String, value:*):void {
  }

  override public function get skin():UIComponent {
    return this;
  }

  private var _hoverable:Boolean;
  public function set hoverable(value:Boolean):void {
    _hoverable = value;
  }

  override public function invalidateSkinState():void {
    if (_border is Scale1BitmapBorder) {
      Scale1BitmapBorder(_border).stateIndex = ((mouseCaptured && (hovered || stickyHighlighting))) ? 1 : (_hoverable && hovered ? 2 : 0);
      invalidateDisplayList();
    }
  }

  // disable unwanted legacy
  include "../../unwantedLegacy.as";

  override public function setCurrentState(stateName:String, playTransition:Boolean = true):void {
  }

  override protected function stateChanged(oldState:String, newState:String, recursive:Boolean):void {

  }
}
}