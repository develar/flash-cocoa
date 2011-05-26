package cocoa {
import cocoa.plaf.LookAndFeel;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.core.IInvalidating;
import mx.core.UIComponent;
import mx.core.mx_internal;

import spark.components.VScrollBar;
import spark.core.IViewport;
import spark.core.NavigationUnit;

use namespace mx_internal;

public class VScrollBar extends spark.components.VScrollBar implements UIPartController {
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
    }

    return undefined;
  }

  public final function _trackMouseDownHandler(event:MouseEvent):void {
    super.track_mouseDownHandler(event);
  }

  override protected function track_mouseDownHandler(event:MouseEvent):void {
    var border:Border = FlexButton(track).border;
    if (border == null || event.localY >= border.contentInsets.top) {
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

    var trackSize:Number = track.getLayoutBoundsHeight();
    if (trackSize == 0) {
      return;
    }

    if (!track.visible) {
      skin.invalidateDisplayList();
    }

    var thumbTopPadding:Number = 0;
    var trackBorder:Border = FlexButton(track).border;
    if (trackBorder != null) {
      thumbTopPadding = trackBorder.contentInsets.top;
      trackSize -= thumbTopPadding;
    }

    var thumbSize:Number = Math.max(thumb.minHeight, Math.min((pageSize / (range + pageSize)) * trackSize, trackSize));
    thumb.setLayoutBoundsSize(NaN, thumbSize);
    thumb.setLayoutBoundsPosition(0, Math.round(((value - minimum) * ((trackSize - thumbSize) / range)) + thumbTopPadding));
  }

  // disable unwanted legacy
  include "../../unwantedLegacy.as";

  private var mySkin:UIComponent;
  override public function get skin():UIComponent {
    return mySkin;
  }

  override protected function createChildren():void {
    mySkin = new skinClass();

    addingChild(mySkin);
    $addChildAt(mySkin, 0);
    childAdded(mySkin);
  }

  public function attach(laf:LookAndFeel):void {
    skinClass = laf.getClass("ScrollBar.v");
  }

  override protected function attachSkin():void {

  }

  override public function invalidateSkinState():void {
  }

  override protected function stateChanged(oldState:String, newState:String, recursive:Boolean):void {

  }

  // flex impl skip validation (as in increment button down handler), we add it
  override mx_internal function mouseWheelHandler(event:MouseEvent):void {
    const vp:IViewport = viewport;
    if (event.isDefaultPrevented() || !vp || !vp.visible || !visible) {
      return;
    }

    const delta:int = event.delta;

    var nSteps:uint = Math.abs(delta);
    var navigationUnit:uint;
    var scrollPositionChanged:Boolean;

    // Scroll delta "steps".
    navigationUnit = (delta < 0) ? NavigationUnit.DOWN : NavigationUnit.UP;
    for (var vStep:int = 0; vStep < nSteps; vStep++) {
      var vspDelta:Number = vp.getVerticalScrollPositionDelta(navigationUnit);
      if (!isNaN(vspDelta)) {
        setValue(nearestValidValue(vp.verticalScrollPosition + vspDelta, snapInterval));
        scrollPositionChanged = true;
      }
    }

    if (scrollPositionChanged && hasEventListener(Event.CHANGE)) {
      dispatchEvent(new Event(Event.CHANGE));
    }

    event.preventDefault();
  }
}
}