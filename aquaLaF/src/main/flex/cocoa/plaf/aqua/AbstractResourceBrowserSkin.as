package cocoa.plaf.aqua
{
import cocoa.Component;
import cocoa.Container;
import cocoa.plaf.AbstractSkin;
import cocoa.sidebar.SourceListView;

import flash.display.DisplayObject;

import mx.core.IUIComponent;

public class AbstractResourceBrowserSkin extends AbstractSkin
{
	protected var toolbar:Container;

	protected var sourceListView:SourceListView;
	protected var resourceList:Component;

	override protected function createChildren():void
	{
		super.createChildren();

		addChild(toolbar);
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
		measuredHeight = Math.max(sourceListViewSkin.getExplicitOrMeasuredHeight(), resourceListSkin.getExplicitOrMeasuredHeight()) + toolbar.getExplicitOrMeasuredHeight();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var sourceListViewSkin:IUIComponent = sourceListView.skin;

		var toolbarHeight:Number = toolbar.getExplicitOrMeasuredHeight();
		var sourceListViewWidth:Number = sourceListViewSkin.getExplicitOrMeasuredWidth();
		const contentHeight:Number = h - toolbarHeight;
		sourceListViewSkin.setActualSize(sourceListViewWidth, contentHeight);
		sourceListViewSkin.y = toolbarHeight;

		toolbar.setActualSize(w - sourceListViewWidth, toolbarHeight);
		toolbar.x = sourceListViewWidth;

		resourceList.skin.move(sourceListViewWidth, toolbarHeight);
		resourceList.skin.setActualSize(w - sourceListViewWidth, contentHeight);
	}
}
}