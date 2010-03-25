package cocoa.plaf.aqua
{
import cocoa.Insets;
import cocoa.SingleSelectionDataGroup;
import cocoa.ViewStack;
import cocoa.layout.AdvancedLayout;
import cocoa.layout.BarHorizontalLayout;
import cocoa.plaf.AbstractSkin;

import mx.core.ClassFactory;
import mx.core.ILayoutElement;
import mx.core.SpriteAsset;
import mx.core.mx_internal;

use namespace mx_internal;

public class TabSkin extends AbstractSkin implements AdvancedLayout
{
	[Embed(source="/GroupBox.png", scaleGridTop="7", scaleGridBottom="11", scaleGridLeft="7", scaleGridRight="13")]
	private static const contentBorderClass:Class;

	private static const CONTENT_INSETS:Insets = new Insets(16, 16 + 10, 16, 16);

	private var itemGroup:SingleSelectionDataGroup;
	private var viewStack:ViewStack;

	private var contentBorder:SpriteAsset;

	override protected function createChildren():void
	{
		if (contentBorder == null)
		{
			contentBorder = new contentBorderClass();
			contentBorder.y = 10;
			contentBorder.mouseEnabled = false;
//			$addChild(contentBorder);
		}

		if (viewStack == null)
		{
			viewStack = new ViewStack();
			viewStack.move(CONTENT_INSETS.left, CONTENT_INSETS.top);
			addChild(viewStack);
			component.uiPartAdded("viewStack", viewStack);
		}

		if (itemGroup == null)
		{
			itemGroup = new SingleSelectionDataGroup();
			itemGroup.layout = new BarHorizontalLayout();
			var factory:ClassFactory = new ClassFactory(TabLabelSkin);
//			factory.properties = {"laf": laf};
			itemGroup.itemRenderer = factory;

			addChild(itemGroup);
			component.uiPartAdded("itemGroup", itemGroup);
		}
	}

	public function childCanSkipMeasurement(element:ILayoutElement):Boolean
	{
		// если у окна установлена фиксированный размер, то content pane устанавливается в размер невзирая на его preferred
		return canSkipMeasurement();
	}

	override protected function measure():void
	{
		measuredMinWidth = viewStack.minWidth + CONTENT_INSETS.width;
		measuredMinHeight = viewStack.minHeight + CONTENT_INSETS.height;

		measuredWidth = viewStack.getExplicitOrMeasuredWidth() + CONTENT_INSETS.width;
		measuredHeight = viewStack.getExplicitOrMeasuredHeight() + CONTENT_INSETS.height;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		contentBorder.width = w;
		contentBorder.height = h - contentBorder.y;

		itemGroup.setLayoutBoundsSize(NaN, NaN);
		itemGroup.x = Math.round((w - itemGroup.getExplicitOrMeasuredWidth()) / 2);

		viewStack.setActualSize(w - CONTENT_INSETS.width, h - CONTENT_INSETS.height);
	}
}
}