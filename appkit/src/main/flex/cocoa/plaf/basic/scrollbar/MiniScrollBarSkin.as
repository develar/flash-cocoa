package cocoa.plaf.basic.scrollbar {
import cocoa.LightFlexUIComponent;
import cocoa.UIPartController;
import cocoa.UIPartProvider;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelUtil;

import flash.display.Graphics;

import spark.components.supportClasses.ScrollBarBase;

public class MiniScrollBarSkin extends LightFlexUIComponent implements UIPartProvider {
  private var thumb:TrackOrThumbButton;

  override protected function createChildren():void {
    var laf:LookAndFeel = LookAndFeelUtil.find(parent);

    thumb = new TrackOrThumbButton();
    thumb.border = laf.getBorder("Scrollbar.thumb");
    addChild(thumb);

    UIPartController(parent).uiPartAdded("thumb", thumb);
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    const isOff:Boolean = ScrollBarBase(parent).maximum <= ScrollBarBase(parent).minimum;

    var g:Graphics = graphics;
    g.clear();
    if (isOff == thumb.visible) {
      thumb.visible = !isOff;
    }

    g.beginFill(0, 0);
    g.drawRect(0, 0, w, h);
    g.endFill();
  }
}
}