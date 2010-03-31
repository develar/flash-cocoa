package cocoa.plaf.scrollbar
{
import cocoa.LightFlexUIComponent;

import spark.components.Button;

public class VscrollBarSkin extends LightFlexUIComponent
{
	protected var track:Button;
	protected var thumb:Button;
	protected var decrementButton:Button;
	protected var incrementButton:Button;

	public function VscrollBarSkin()
	{
	}

	override protected function createChildren():void
	{
		track = new Button();
		addChild(track);

		thumb = new Button();
		addChild(thumb);

		decrementButton = new Button();
		addChild(decrementButton);

		incrementButton = new Button();
		addChild(incrementButton);
	}

	override protected function measure():void
	{
		super.measure();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{

	}
}
}