package cocoa.plaf.scrollbar
{
import cocoa.Border;
import cocoa.LightFlexUIComponent;
import cocoa.UIPartController;
import cocoa.UIPartProvider;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;

import flash.display.DisplayObjectContainer;

internal class AbstractScrollBarSkin extends LightFlexUIComponent implements UIPartProvider
{
	protected var track:TrackOrThumbButton;
	protected var thumb:TrackOrThumbButton;
	protected var decrementButton:ArrowButton;
	protected var incrementButton:ArrowButton;

	protected var offBorder:Border;

	protected function get orientation():String
	{
		throw new Error("abstract");
	}

	override protected function createChildren():void
	{
		var laf:LookAndFeel;
		var p:DisplayObjectContainer = parent;
		while (p != null)
		{
			if (p is LookAndFeelProvider)
			{
				laf = LookAndFeelProvider(p).laf;
				if (laf != null)
				{
					break;
				}
			}
			else if (p is Skin && Skin(p).component is LookAndFeelProvider)
			{
				laf = LookAndFeelProvider(Skin(p).component).laf;
				break;
			}

			p = p.parent;
		}

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

		UIPartController(parent).uiPartAdded("track", track);
		UIPartController(parent).uiPartAdded("thumb", thumb);
		UIPartController(parent).uiPartAdded("decrementButton", decrementButton);
		UIPartController(parent).uiPartAdded("incrementButton", incrementButton);
	}
}
}