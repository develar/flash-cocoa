package cocoa.plaf.aqua
{
import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;

/**
 * воспринимает left, right и horizontal center как указание центровки – то есть кнопка с left=0 (значение не имеет смысла) будет у левого края (но не будет наезжать на другие кнопки у этого края)
 */
public class BottomBarLayout extends LayoutBase
{
	private var _gap:Number;
	public function set gap(value:Number):void
	{
		_gap = value;
	}

	private var _padding:Number;
	public function set padding(value:Number):void
	{
		_padding = value;
	}

	override public function updateDisplayList(w:Number, h:Number):void
	{
		var layoutTarget:GroupBase = target;

		var left:Number = _padding;
		var right:Number = w - _padding;
		var x:Number;

		for (var i:int = layoutTarget.numElements - 1; i >= 0; i--)
		{
			var layoutElement:ILayoutElement = layoutTarget.getElementAt(i);
			layoutElement.setLayoutBoundsSize(NaN, NaN);

			if (isNaN(Number(layoutElement.left)))
			{
				x = right - layoutElement.getPreferredBoundsWidth();
				right = x - _gap;
			}
			else
			{
				x = left;
				left += layoutElement.getPreferredBoundsWidth() + _gap;
			}
			
			layoutElement.setLayoutBoundsPosition(x, Math.round((h - layoutElement.getPreferredBoundsHeight()) / 2));
		}
	}
}
}