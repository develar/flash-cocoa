package org.flyti.aqua
{
import cocoa.Insets;

import mx.core.ClassFactory;
import mx.core.ILayoutElement;
import mx.core.SpriteAsset;
import mx.core.mx_internal;

import org.flyti.layout.AdvancedLayout;
import org.flyti.layout.BarHorizontalLayout;
import cocoa.AbstractSkin;
import cocoa.SingleSelectionDataGroup;
import cocoa.UIPartProvider;
import cocoa.ViewStack;
import cocoa.tabView.TabView;

use namespace mx_internal;

public class TabSkin extends AbstractSkin implements AdvancedLayout, UIPartProvider
{
	[Embed(source="/GroupBox.png", scaleGridTop="7", scaleGridBottom="11", scaleGridLeft="7", scaleGridRight="13")]
	private static const contentBorderClass:Class;

	private static const CONTENT_INSETS:Insets = new Insets(16, 16 + 10, 16, 16);
	
	public var hostComponent:TabView;

	private var itemGroup:SingleSelectionDataGroup;
	private var paneGroup:ViewStack;

	private var contentBorder:SpriteAsset;

	override protected function createChildren():void
	{
		if (contentBorder == null)
		{
			contentBorder = new contentBorderClass();
			contentBorder.y = 10;
			contentBorder.mouseEnabled = false;
			$addChild(contentBorder);
		}

		if (paneGroup == null)
		{
			paneGroup = new ViewStack();
			paneGroup.move(CONTENT_INSETS.left, CONTENT_INSETS.top);
			addChild(paneGroup);
			hostComponent.uiPartAdded("paneGroup", paneGroup);
		}

		if (itemGroup == null)
		{
			itemGroup = new SingleSelectionDataGroup();
			itemGroup.layout = new BarHorizontalLayout();
			itemGroup.itemRenderer = new ClassFactory(AquaBarButton);

			addChild(itemGroup);
			hostComponent.uiPartAdded("itemGroup", itemGroup);
		}
	}

	public function childCanSkipMeasurement(element:ILayoutElement):Boolean
	{
		// если у окна установлена фиксированный размер, то content pane устанавливается в размер невзирая на его preferred
		return canSkipMeasurement();
	}

	override protected function measure():void
	{
		measuredMinWidth = paneGroup.minWidth + CONTENT_INSETS.width;
		measuredMinHeight = paneGroup.minHeight + CONTENT_INSETS.height;

		measuredWidth = paneGroup.getExplicitOrMeasuredWidth() + CONTENT_INSETS.width;
		measuredHeight = paneGroup.getExplicitOrMeasuredHeight() + CONTENT_INSETS.height;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		contentBorder.width = w;
		contentBorder.height = h - contentBorder.y;

		itemGroup.setLayoutBoundsSize(NaN, NaN);
		itemGroup.x = Math.round((w - itemGroup.getExplicitOrMeasuredWidth()) / 2);

		paneGroup.setActualSize(w - CONTENT_INSETS.width, h - CONTENT_INSETS.height);
	}
}
}