package cocoa.plaf.aqua
{
import cocoa.Component;
import cocoa.plaf.AbstractSkin;
import cocoa.sidebar.SourceListView;

import flash.display.DisplayObject;

import mx.core.IUIComponent;

public class AbstractResourceBrowserSkin extends AbstractSkin
{
	protected var sourceListView:SourceListView;
	protected var resourceList:Component;

	override protected function createChildren():void
	{
		super.createChildren();

		addChild(DisplayObject(sourceListView.createView(laf)));
		addChild(DisplayObject(resourceList.createView(laf)));
	}

	override protected function measure():void
	{
		var sourceListViewSkin:IUIComponent = sourceListView.skin;
		var resourceListSkin:IUIComponent = resourceList.skin;
		measuredMinWidth = Math.max(sourceListViewSkin.minWidth, resourceListSkin.minWidth);
		measuredWidth = sourceListViewSkin.getExplicitOrMeasuredWidth() + resourceListSkin.getExplicitOrMeasuredWidth();

		measuredMinHeight = Math.max(sourceListViewSkin.minHeight, resourceListSkin.minHeight);
		measuredHeight = Math.max(sourceListViewSkin.getExplicitOrMeasuredHeight(), resourceListSkin.getExplicitOrMeasuredHeight());
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var sourceListViewWidth:Number = sourceListView.skin.getExplicitOrMeasuredWidth();
		sourceListView.skin.setActualSize(sourceListViewWidth, h);

		IUIComponent(resourceList.skin).x = sourceListViewWidth;
		resourceList.skin.setActualSize(w - sourceListViewWidth, h);
	}
}
}