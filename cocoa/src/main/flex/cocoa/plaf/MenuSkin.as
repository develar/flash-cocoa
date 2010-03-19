package cocoa.plaf
{
import cocoa.Border;
import cocoa.Menu;
import cocoa.SingleSelectionDataGroup;

import mx.core.IDataRenderer;
import mx.core.IVisualElement;

import mx.core.mx_internal;

import spark.components.IItemRenderer;
import spark.components.IItemRendererOwner;
import spark.layouts.HorizontalAlign;
import spark.layouts.VerticalLayout;

use namespace mx_internal;

public class MenuSkin extends AbstractSkin implements IItemRendererOwner
{
	private var itemGroup:SingleSelectionDataGroup;

	private var border:Border;

	public function MenuSkin()
	{
	}

	override protected function createChildren():void
	{
		super.createChildren();

		border = getBorder("border");

		itemGroup = new SingleSelectionDataGroup();
		itemGroup.itemRenderer = getFactory("itemFactory");
		itemGroup.rendererUpdateDelegate = this;
		var itemGroupLayout:VerticalLayout = new VerticalLayout();
		itemGroupLayout.gap = 0;
		itemGroupLayout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
		itemGroup.layout = itemGroupLayout;
		addChild(itemGroup);

		component.uiPartAdded("itemGroup", itemGroup);
	}

	public function itemToLabel(item:Object):String
	{
		return Menu(component).labelFunction == null ? String(item) : Menu(component).labelFunction(item);
	}

	public function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void
	{
		AbstractItemRenderer(renderer).laf = laf;

		if (renderer is IItemRenderer)
		{
			IItemRenderer(renderer).itemIndex = itemIndex;
			IItemRenderer(renderer).label = itemToLabel(data);
		}

		// always set the data last
		if ((renderer is IDataRenderer) && (renderer !== data))
		{
			IDataRenderer(renderer).data = data;
		}
	}
}
}