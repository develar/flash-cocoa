package cocoa.plaf.aqua
{
import cocoa.Component;
import cocoa.Container;
import cocoa.plaf.AbstractSkin;
import cocoa.sidebar.SourceListView;

public class AbstractResourceBrowserSkin extends AbstractSkin
{
	protected var toolbar:Container;

	protected var sourceListView:SourceListView;
	protected var resourceList:Component;

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var sourceListViewWidth:Number = sourceListView.skin.getExplicitOrMeasuredWidth();
		sourceListView.skin.setActualSize(sourceListViewWidth, h);

		resourceList.skin.move(sourceListViewWidth, 0);
		resourceList.skin.setActualSize(w - sourceListViewWidth, h);
	}
}
}