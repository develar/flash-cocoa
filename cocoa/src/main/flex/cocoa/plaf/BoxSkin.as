package cocoa.plaf
{
import cocoa.Box;
import cocoa.Container;
import cocoa.UIPartProvider;

public class BoxSkin extends AbstractSkin implements UIPartProvider
{
	public var hostComponent:Box;

	private var contentGroup:Container;

	override protected function createChildren():void
	{
		contentGroup = new Container();
		hostComponent.uiPartAdded("contentGroup", contentGroup);
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