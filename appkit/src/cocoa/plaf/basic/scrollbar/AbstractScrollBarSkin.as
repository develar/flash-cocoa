package cocoa.plaf.basic.scrollbar {
import cocoa.Border;
import cocoa.LightFlexUIComponent;
import cocoa.UIPartController;
import cocoa.UIPartProvider;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelUtil;

import spark.components.supportClasses.ScrollBarBase;

[Abstract]
internal class AbstractScrollBarSkin extends LightFlexUIComponent {
  protected var track:TrackOrThumbButton;
  protected var thumb:TrackOrThumbButton;
  protected var decrementButton:ArrowButton;
  protected var incrementButton:ArrowButton;

  protected var offBorder:Border;

  protected var minFullSize:Number;

  protected function get isVertical():Boolean {
    throw new Error("abstract");
  }

  override protected function canSkipMeasurement():Boolean {
    return !isNaN(minFullSize);
  }

  override protected function measure():void {
    minFullSize = thumb.getExplicitOrMeasuredWidth() + decrementButton.getExplicitOrMeasuredWidth() + incrementButton.getExplicitOrMeasuredWidth();
    if (isVertical) {
      measuredWidth = track.getExplicitOrMeasuredWidth();
      minFullSize += track.border.contentInsets.height;
    }
    else {
      measuredHeight = track.getExplicitOrMeasuredHeight();
      minFullSize += track.border.contentInsets.width;
    }
  }

  override protected function createChildren():void {
    var laf:LookAndFeel = LookAndFeelUtil.find(parent);

    const orientation:String = isVertical ? "v" : "h";
    offBorder = laf.getBorder("ScrollBar.track." + orientation + ".off", false);

    track = new TrackOrThumbButton();
    track.border = laf.getBorder("ScrollBar.track." + orientation, false);
    addChild(track);

    decrementButton = new ArrowButton();
    decrementButton.attach(laf, "ScrollBar.decrementButton." + orientation);
    addChild(decrementButton);

    incrementButton = new ArrowButton();
    incrementButton.attach(laf, "ScrollBar.incrementButton." + orientation);
    addChild(incrementButton);

    thumb = new TrackOrThumbButton();
    thumb.border = laf.getBorder("ScrollBar.thumb." + orientation, false);
    addChild(thumb);

    var uiPartController:UIPartController = UIPartController(parent);
    uiPartController.uiPartAdded("track", track);
    uiPartController.uiPartAdded("thumb", thumb);
    uiPartController.uiPartAdded("decrementButton", decrementButton);
    uiPartController.uiPartAdded("incrementButton", incrementButton);
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    const isOff:Boolean = ScrollBarBase(parent).maximum <= ScrollBarBase(parent).minimum || (isVertical ? h : w) < minFullSize;
    graphics.clear();
    if (isOff == track.visible) {
      track.visible = !isOff;
      thumb.visible = !isOff;
      decrementButton.visible = !isOff;
      incrementButton.visible = !isOff;
    }

    if (isOff) {
      offBorder.draw(graphics, w, h);
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