package cocoa.plaf.basic
{
import cocoa.Container;
import cocoa.plaf.AbstractSkin;

public class BoxSkin extends AbstractSkin
{
	private var contentGroup:Container;

	override protected function createChildren():void
	{
		super.createChildren();
		
		contentGroup = new Container();
		component.uiPartAdded("contentGroup", contentGroup);
		addChild(contentGroup);
	}

	override protected function measure():void
	{
		measuredMinWidth = contentGroup.minHeight;
		measuredMinHeight = contentGroup.minHeight;
		measuredWidth = contentGroup.getExplicitOrMeasuredWidth();
		measuredHeight = contentGroup.getExplicitOrMeasuredHeight();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		contentGroup.setActualSize(w, h);
	}
}
}