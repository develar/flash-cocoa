package cocoa.layout
{
import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;

/**
 *  The SegmentedControlHorizontalLayout is a layout specifically designed for the Sidebar or TabView
 *
 *  The layout lays out the children horizontally, left to right.
 *  The layout measures such that all children are sized at their preferred size.
 *
 *  All children are set to the height of the parent.
 */
public class SegmentedControlHorizontalLayout extends SegmentedControlLayout
{
	private var _itemWidth:Number;
	public function set itemWidth(value:Number):void
	{
		_itemWidth = value;
	}

	private var _useGapForEdge:Boolean;
	public function set useGapForEdge(value:Boolean):void
	{
		_useGapForEdge = value;
	}

	override public function measure():void
	{
		var layoutTarget:GroupBase = target;
		var n:int = layoutTarget.numElements;

		var width:Number = 0;
		for (var i:int = 0; i < n; i++)
		{
			var layoutElement:ILayoutElement = layoutTarget.getElementAt(i);
			if (!layoutElement.includeInLayout)
			{
				continue;
			}

			width += layoutElement.getPreferredBoundsWidth() + gap;
		}

		width -= gap;
		if (_useGapForEdge)
		{
			width += gap * 2;
		}

		layoutTarget.measuredWidth = width;
		layoutTarget.measuredHeight = n > 0 ? layoutTarget.getElementAt(0).getPreferredBoundsHeight() : 0;
	}

	override public function updateDisplayList(w:Number, h:Number):void
	{
		var layoutTarget:GroupBase = target;
		var x:Number = _useGapForEdge ? gap : 0;
		for (var i:int = 0, n:int = layoutTarget.numElements; i < n; i++)
		{
			var layoutElement:ILayoutElement = layoutTarget.getElementAt(i);
			if (!layoutElement.includeInLayout)
			{
				continue;
			}

			if (i == 0 && !isNaN(_itemWidth))
			{
				layoutElement.setLayoutBoundsSize(_itemWidth + (w - (_itemWidth * n) - (gap * (n + 1))), h);
			}
			else
			{
				layoutElement.setLayoutBoundsSize(_itemWidth, h);
			}

			layoutElement.setLayoutBoundsPosition(x, 0);

			x += layoutElement.getLayoutBoundsWidth() + gap;
		}
	}
}
}
