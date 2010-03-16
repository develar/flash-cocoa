package cocoa.layout
{
import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;

/**
 *  The BarVerticalLayout is a layout specifically designed for the Sidebar or TabView
 *
 *  The layout lays out the children vertically, top to bottom.
 *  The layout measures such that all children are sized at their preferred size.
 *
 *  All children are set to the width of the parent.
 */
public class BarVerticalLayout extends BarLayout
{
	override public function updateDisplayList(width:Number, height:Number):void
	{
		var layoutTarget:GroupBase = target;
		var y:Number = 0;
		for (var i:int = 0, n:int = layoutTarget.numElements; i < n; i++)
		{
			var layoutElement:ILayoutElement = layoutTarget.getElementAt(i);
			if (!layoutElement.includeInLayout)
			{
				continue;
			}

			layoutElement.setLayoutBoundsPosition(0, y);
			layoutElement.setLayoutBoundsSize(width, NaN);

			y += layoutElement.getLayoutBoundsHeight() + gap;
		}
	}
}
}
