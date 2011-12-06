package cocoa.plaf.aqua
{
import cocoa.FlexButton;
import cocoa.LightFlexUIComponent;
import cocoa.UIPartController;
import cocoa.UIPartProvider;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;

public class HSliderSkin extends LightFlexUIComponent
{
	protected var thumb:FlexButton;
	protected var track:FlexButton;

	public function HSliderSkin()
	{
		super();

		height = 12;
	}

	override public function set enabled(value:Boolean):void
	{
		if (enabled != value)
		{
			super.enabled = value;
			alpha = enabled ? 1 : 0.5;
		}
	}

	override protected function createChildren():void
	{
		var laf:LookAndFeel = LookAndFeelProvider(parent.parent).laf;

		track = new FlexButton();
		track.border = laf.getBorder("Slider.track.h", false);
		track.y = 5;
		track.width = 100;
		addChild(track);
		UIPartController(parent).uiPartAdded("track", track);

		thumb = new FlexButton();
		thumb.stickyHighlighting = true;
		thumb.border = laf.getBorder("Slider.thumb", false);
		thumb.y = 1;

		addChild(thumb);
		UIPartController(parent).uiPartAdded("thumb", thumb);
	}

	override protected function measure():void
	{
		measuredWidth = track.getExplicitOrMeasuredWidth();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		thumb.setLayoutBoundsSize(NaN, NaN);
		track.setLayoutBoundsSize(w, NaN);
	}
}
}