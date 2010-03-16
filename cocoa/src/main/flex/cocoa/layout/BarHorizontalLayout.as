package cocoa.layout
{
import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;

/**
 *  The BarHorizontalLayout is a layout specifically designed for the Sidebar or TabView
 *
 *  The layout lays out the children horizontally, left to right.
 *  The layout measures such that all children are sized at their preferred size.
 *
 *  All children are set to the height of the parent.
 */
public class BarHorizontalLayout extends BarLayout
{
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

		if (n > 0)
		{
			width -= gap;
		}

		layoutTarget.measuredWidth = width;
		layoutTarget.measuredHeight = n > 0 ? layoutTarget.getElementAt(0).getPreferredBoundsHeight() : 0;
	}

	override public function updateDisplayList(width:Number, height:Number):void
	{
		var layoutTarget:GroupBase = target;
		var x:Number = 0;
		for (var i:int = 0, n:int = layoutTarget.numElements; i < n; i++)
		{
			var layoutElement:ILayoutElement = layoutTarget.getElementAt(i);
			if (!layoutElement.includeInLayout)
			{
				continue;
			}

			layoutElement.setLayoutBoundsSize(NaN, height);
			layoutElement.setLayoutBoundsPosition(x, 0);

			x += layoutElement.getLayoutBoundsWidth() + gap;
		}
	}
}
}
