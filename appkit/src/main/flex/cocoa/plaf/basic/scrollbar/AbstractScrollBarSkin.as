package cocoa.plaf.basic.scrollbar {
import cocoa.Border;
import cocoa.LightFlexUIComponent;
import cocoa.UIPartController;
import cocoa.UIPartProvider;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelUtil;

import spark.components.supportClasses.ScrollBarBase;

[Abstract]
internal class AbstractScrollBarSkin extends LightFlexUIComponent implements UIPartProvider {
  protected var track:TrackOrThumbButton;
  protected var thumb:TrackOrThumbButton;
  protected var decrementButton:ArrowButton;
  protected var incrementButton:ArrowButton;

  protected var offBorder:Border;

  protected function get orientation():String {
    throw new Error("abstract");
  }

  override protected function createChildren():void {
    var laf:LookAndFeel = LookAndFeelUtil.find(parent);

    offBorder = laf.getBorder("Scrollbar.track." + orientation + ".off");

    track = new TrackOrThumbButton();
    track.border = laf.getBorder("Scrollbar.track." + orientation);
    addChild(track);

    decrementButton = new ArrowButton();
    decrementButton.attach(laf, "Scrollbar.decrementButton." + orientation);
    addChild(decrementButton);

    incrementButton = new ArrowButton();
    incrementButton.attach(laf, "Scrollbar.incrementButton." + orientation);
    addChild(incrementButton);

    thumb = new TrackOrThumbButton();
    thumb.border = laf.getBorder("Scrollbar.thumb." + orientation);
    addChild(thumb);

    var uiPartController:UIPartController = UIPartController(parent);
    uiPartController.uiPartAdded("track", track);
    uiPartController.uiPartAdded("thumb", thumb);
    uiPartController.uiPartAdded("decrementButton", decrementButton);
    uiPartController.uiPartAdded("incrementButton", incrementButton);
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    const isOff:Boolean = ScrollBarBase(parent).maximum <= ScrollBarBase(parent).minimum;

    if (isOff == track.visible) {
      graphics.clear();
      track.visible = !isOff;
      thumb.visible = !isOff;
      decrementButton.visible = !isOff;
      incrementButton.visible = !isOff;
    }

    if (isOff) {
      offBorder.draw(null, graphics, w, h);
    }
    else {
      decrementButton.setLayoutBoundsSize(NaN, NaN);
      incrementButton.setLayoutBoundsSize(NaN, NaN);

      layoutTrackAndButtons(w, h);
    }
  }

  [Abstract]
  protected function layoutTrackAndButtons(w:Number, h:Number):void {

  }
}
}