package org.flyti.view.sidebar
{
import org.flyti.layout.AdvancedLayout;

import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;

/**
 * SidebarLayout don't measure — sidebar size explicitly determined by skin
 */
public class SidebarLayout extends LayoutBase implements AdvancedLayout
{
	override public function updateDisplayList(width:Number, height:Number):void
	{
		var layoutTarget:GroupBase = target;
		var numElements:int = layoutTarget.numElements;
		if (numElements == 0)
		{
			return;
		}

		var i:int;
		var numActiveElements:int = numElements;
		for (i = 0; i < numElements; i++)
		{
			if (!layoutTarget.getElementAt(i).includeInLayout)
			{
				numActiveElements--;
			}
		}

		var elementHeight:Number = height / numActiveElements;
		var y:Number = 0;
		for (i = 0; i < numElements; i++)
		{
			var layoutElement:ILayoutElement = layoutTarget.getElementAt(i);
			if (!layoutElement.includeInLayout)
			{
				continue;
			}

			layoutElement.setLayoutBoundsPosition(0, y);
			layoutElement.setLayoutBoundsSize(width, elementHeight);

			y += elementHeight;
		}
	}

	public function childCanSkipMeasurement(element:ILayoutElement):Boolean
	{
		return true;
	}
}
}