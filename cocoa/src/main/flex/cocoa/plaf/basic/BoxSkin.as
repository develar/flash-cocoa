package cocoa.plaf.basic
{
import cocoa.Group;

public class BoxSkin extends AbstractSkin
{
	protected var contentGroup:Group;

	override protected function createChildren():void
	{
		super.createChildren();

		if (contentGroup == null)
		{
			contentGroup = new Group();
			component.uiPartAdded("contentGroup", contentGroup);
			addChild(contentGroup);
		}
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