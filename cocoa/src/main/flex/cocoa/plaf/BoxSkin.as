package cocoa.plaf
{
import cocoa.Container;

public class BoxSkin extends AbstractSkin
{
	private var contentGroup:Container;

	override protected function createChildren():void
	{
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
		contentGroup.setActualSize(contentGroup.getExplicitOrMeasuredWidth(), contentGroup.getExplicitOrMeasuredHeight());
	}
}
}