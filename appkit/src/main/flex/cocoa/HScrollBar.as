package cocoa {
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.basic.scrollbar.TrackOrThumbButton;

import flash.events.MouseEvent;

import mx.core.InteractionMode;

import mx.core.UIComponent;
import mx.core.mx_internal;

import spark.components.HScrollBar;

use namespace mx_internal;

public class HScrollBar extends spark.components.HScrollBar implements UIPartController {
  private var skinClass:Class;

  public function uiPartAdded(id:String, instance:Object):void {
    this[id] = instance;
    partAdded(id, instance);
  }

  override public function getStyle(styleProp:String):* {
    switch (styleProp) {
      case "repeatDelay": return 500;
      case "repeatInterval": return 35;
      case "skinClass": return skinClass;
      case "liveDragging": return true;
      case "interactionMode": return InteractionMode.MOUSE;
    }

    return undefined;
  }

  override protected function pointToValue(x:Number, y:Number):Number {
    return super.pointToValue(Math.max(0, x - TrackOrThumbButton(track).border.contentInsets.left), y);
  }

  public final function _trackMouseDownHandler(event:MouseEvent):void {
    super.track_mouseDownHandler(event);
  }

  override protected function track_mouseDownHandler(event:MouseEvent):void {
    var border:Border = FlexButton(track).border;
    if (border == null || event.localX >= border.contentInsets.left) {
      super.track_mouseDownHandler(event);
    }
  }

  override protected function updateSkinDisplayList():void {
    if (track == null || thumb == null) {
      return;
    }

    var range:Number = maximum - minimum;
    if (range <= 0) {
      skin.invalidateDisplayList();
      return;
    }

    var trackSize:Number = track.getLayoutBoundsWidth();
    if (trackSize == 0) {
      return;
    }

    if (!track.visible) {
      skin.invalidateDisplayList();
    }

    var thumbleftPadding:Number = 0;
    var trackBorder:Border = FlexButton(track).border;
    if (trackBorder != null) {
      thumbleftPadding = trackBorder.contentInsets.left;
      trackSize -= thumbleftPadding;
    }

    var thumbSize:Number = Math.max(thumb.minWidth, Math.min((pageSize / (range + pageSize)) * trackSize, trackSize));
    thumb.setLayoutBoundsSize(thumbSize, NaN);
    thumb.setLayoutBoundsPosition(Math.round(((value - minimum) * ((trackSize - thumbSize) / range)) + thumbleftPadding), 0);
  }

  // disable unwanted legacy
  include "../../unwantedLegacy.as";

  private var mySkin:UIComponent;

  override public function get skin():UIComponent {
    return mySkin;
  }

  override protected function createChildren():void {
    mySkin = new skinClass;

    addingChild(mySkin);
    $addChildAt(mySkin, 0);
    childAdded(mySkin);
  }

  public function attach(laf:LookAndFeel):void {
    skinClass = laf.getClass("ScrollBar.h");
  }

  override protected function attachSkin():void {

  }

  override public function invalidateSkinState():void {
  }

  override protected function stateChanged(oldState:String, newState:String, recursive:Boolean):void {

  }
}
}