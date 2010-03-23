package cocoa.plaf
{
import cocoa.Border;
import cocoa.Insets;
import cocoa.Menu;
import cocoa.SingleSelectionDataGroup;

import flash.display.Graphics;

import flash.geom.Point;

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
	private static var sharedPoint:Point;

	private var itemGroup:SingleSelectionDataGroup;

	private var _border:Border;
	public function get border():Border
	{
		return _border;
	}

	override protected function createChildren():void
	{
		super.createChildren();

		_border = getBorder("border");

		itemGroup = new SingleSelectionDataGroup();
		itemGroup.itemRenderer = getFactory("itemFactory");
		itemGroup.rendererUpdateDelegate = this;
		var itemGroupLayout:VerticalLayout = new VerticalLayout();
		itemGroupLayout.gap = 0;
		itemGroupLayout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
		itemGroup.layout = itemGroupLayout;
		itemGroup.x = _border.contentInsets.left;
		itemGroup.y = _border.contentInsets.top;
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

	override protected function measure():void
	{
		var contentInsets:Insets = _border.contentInsets;
		measuredMinWidth = measuredWidth = contentInsets.width + itemGroup.getExplicitOrMeasuredWidth();
		measuredMinHeight = measuredHeight = contentInsets.height + itemGroup.getExplicitOrMeasuredHeight();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		itemGroup.setActualSize(w - _border.contentInsets.width, h - _border.contentInsets.height);
		
		var g:Graphics = graphics;
		g.clear();
		_border.draw(this, g, w, h);
	}

	override public function hitTestPoint(x:Number, y:Number, shapeFlag:Boolean = false):Boolean
	{
		if (shapeFlag)
		{
			return super.hitTestPoint(x, y, shapeFlag);
		}
		else
		{
			if (sharedPoint == null)
			{
				sharedPoint = new Point(x, y);
			}
			else
			{
				sharedPoint.x = x;
				sharedPoint.y = y;
			}

			var local:Point = globalToLocal(sharedPoint);
			return local.x >= 0 && local.x <= width && local.y >= 0 && local.y <= height;
		}
	}
}
}