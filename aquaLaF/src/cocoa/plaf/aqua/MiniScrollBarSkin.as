package cocoa.plaf.aqua {
import cocoa.HScrollBar;
import cocoa.LightFlexUIComponent;
import cocoa.UIPartController;
import cocoa.UIPartProvider;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelUtil;
import cocoa.plaf.basic.scrollbar.TrackOrThumbButton;

import flash.display.Graphics;

import spark.components.supportClasses.ScrollBarBase;

[BorderRequirement("ScrollBar.thumb")]
public class MiniScrollBarSkin extends LightFlexUIComponent {
  private var thumb:TrackOrThumbButton;
  protected var track:TrackButton;

  override protected function measure():void {
    if (parent is HScrollBar) {
      measuredHeight = thumb.getExplicitOrMeasuredHeight();
    }
    else {
      measuredWidth = thumb.getExplicitOrMeasuredWidth();
    }
  }

  override protected function createChildren():void {
    var laf:LookAndFeel = LookAndFeelUtil.find(parent);

    track = new TrackButton();
    addChild(track);

    thumb = new TrackOrThumbButton();
    thumb.border = laf.getBorder("ScrollBar.thumb", false);
//    thumb.minHeight = 28;
    addChild(thumb);

    var uiPartController:UIPartController = UIPartController(parent);
    uiPartController.uiPartAdded("track", track);
    uiPartController.uiPartAdded("thumb", thumb);
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    if (w == 0) {
      return;
    }

    const isOff:Boolean = ScrollBarBase(parent).maximum <= ScrollBarBase(parent).minimum;

    var g:Graphics = graphics;
    g.clear();
    if (isOff == thumb.visible) {
      thumb.visible = !isOff;
    }

    track.setActualSize(w, h);
  }
}
}

import cocoa.FlexButton;

import flash.display.Graphics;

final class TrackButton extends FlexButton {
  override protected function measure():void {

  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    var g:Graphics = graphics;
    g.clear();
    g.beginFill(0, 0);
    g.drawRect(0, 0, w, h);
    g.endFill();
  }

  override public function invalidateSkinState():void {

  }
}