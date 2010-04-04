package cocoa.plaf.scrollbar
{
import cocoa.LightFlexUIComponent;
import cocoa.VScrollBar;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;

import flash.display.DisplayObjectContainer;

public class VscrollBarSkin extends LightFlexUIComponent
{
	protected var track:AbstractButton;
	protected var thumb:AbstractButton;
	protected var decrementButton:AbstractButton;
	protected var incrementButton:AbstractButton;

	override protected function createChildren():void
	{
		super.createChildren();

		var laf:LookAndFeel;
		var p:DisplayObjectContainer = parent;
		while (p != null)
		{
			if (p is LookAndFeelProvider)
			{
				laf = LookAndFeelProvider(p).laf;
				break;
			}
			else
			{
				if (p is Skin && Skin(p).component is LookAndFeelProvider)
				{
					laf = LookAndFeelProvider(Skin(p).component).laf;
					break;
				}
				else
				{
					p = p.parent;
				}
			}
		}

		track = new TrackOrThumbButton();
		track.border = laf.getBorder("Scrollbar.track.v");
		addChild(track);

		decrementButton = new ArrowButton();
		decrementButton.border = laf.getBorder("Scrollbar.decrementButton.v");
		addChild(decrementButton);

		incrementButton = new ArrowButton();
		incrementButton.border = laf.getBorder("Scrollbar.incrementButton.v");
		addChild(incrementButton);

		thumb = new TrackOrThumbButton();
		thumb.border = laf.getBorder("Scrollbar.thumb.v");
		addChild(thumb);

		VScrollBar(parent).uiPartAdded("track", track);
		VScrollBar(parent).uiPartAdded("thumb", thumb);
		VScrollBar(parent).uiPartAdded("decrementButton", decrementButton);
		VScrollBar(parent).uiPartAdded("incrementButton", incrementButton);
	}

	override protected function measure():void
	{
		measuredMinWidth = measuredWidth = 15;
		measuredMinHeight = measuredHeight = thumb.getExplicitOrMeasuredHeight() + decrementButton.getExplicitOrMeasuredHeight() + incrementButton.getExplicitOrMeasuredHeight();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var incrementButtonHeight:Number = incrementButton.getPreferredBoundsHeight();
		var decrementButtonY:Number = h - decrementButton.getPreferredBoundsHeight() - incrementButtonHeight;
//		var decrementButtonY:Number = h - 17 - incrementButtonHeight;

		track.setLayoutBoundsSize(NaN, decrementButtonY);

		decrementButton.setLayoutBoundsSize(NaN, NaN);
		incrementButton.setLayoutBoundsSize(NaN, NaN);

		decrementButton.setLayoutBoundsPosition(0, decrementButtonY);
		incrementButton.setLayoutBoundsPosition(0, h - incrementButtonHeight);
	}
}
}