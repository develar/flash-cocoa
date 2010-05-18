package cocoa.layout
{
import cocoa.CheckBox;
import cocoa.Label;
import cocoa.VSeparator;
import cocoa.plaf.Skin;

import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;

public class FormLayout extends LayoutBase
{
	private static const MAX_ROW_COUNT:int = 3;

	private var columns:Vector.<Column>;

	private var _fieldGap:Number = 3;
    public function get fieldGap():Number
    {
        return _fieldGap;
    }
    public function set fieldGap(value:Number):void
    {
        if (value != _fieldGap)
		{
            _fieldGap = value;
			invalidateTargetSizeAndDisplayList();
		}
    }

	/**
	 * Промежуток между controls в колонке
	 */
	private var _controlGap:Number = 0;
    public function set controlGap(value:Number):void
    {
        if (value != _controlGap)
		{
            _controlGap = value;
			invalidateTargetSizeAndDisplayList();
		}
    }

	private var _labelGap:Number = 6;
    public function set labelGap(value:Number):void
    {
        if (value != _labelGap)
		{
            _labelGap = value;
			invalidateTargetSizeAndDisplayList();
		}
    }

	private var _columnGap:int = 6;
	/**
	 * Промежуток между колонками, игнорируется при явно вставленном разделителе
	 */
    public function get columnGap():int
    {
        return _columnGap;
    }
    public function set columnGap(value:int):void
    {
        if (value != _columnGap)
		{
            _columnGap = value;
			invalidateTargetSizeAndDisplayList();
		}
    }

	override public function measure():void
	{
		var layoutTarget:GroupBase = target;
		if (layoutTarget == null)
		{
			return;
		}

		columns = new Vector.<Column>();

		var measuredWidth:Number = 0;
		var measuredHeight:Number = 0;

		var column:Column;
		const numElements:int = target.numElements;
		var i:int = 0;
		var oldControlGroup:Column;
		while (true)
		{
			var element:ILayoutElement = layoutTarget.getElementAt(i++);
			if (element is Skin && Skin(element).component is VSeparator)
			{
				column.separator = Skin(element);
				oldControlGroup = column;
				column = null;

				measuredWidth += element.getPreferredBoundsWidth();
			}
			else
			{
				var skipAdd:Boolean = false;
				if (isStartElement(element))
				{
					if (column == null || column.compositions.length == MAX_ROW_COUNT)
					{
						if (column != null && column.separator == null)
						{
							measuredWidth += columnGap;
						}
						oldControlGroup = column;
						column = new Column();
					}

					if (column.compositions.length > 0 && column.compositions[0].length > 1 &&
						(i == numElements || ((column.compositions.length + 1) == MAX_ROW_COUNT && isAnotherColumnElement(layoutTarget.getElementAt(i)))))
					{
						column.auxiliaryElement = element;
						skipAdd = true;
					}
					else if (element is CheckBox && (i + 1) < numElements && isAnotherColumnElement(layoutTarget.getElementAt(i)) && !isAnotherColumnElement(layoutTarget.getElementAt(i + 1)))
					{
						column.auxiliaryElement = element;
						column.isAuxiliaryElementFirst = true;
						continue;
					}
					else
					{
						column.addComposition();
					}
				}

//				if (column.auxiliaryElement == null)
				if (!skipAdd)
				{
					column.addElement(element);
				}
			}

			if (oldControlGroup != null || i == numElements)
			{
				if (oldControlGroup == null)
				{
					oldControlGroup = column;
				}

				columns.push(oldControlGroup);
				oldControlGroup.finalize();
				measuredWidth += oldControlGroup.calculateTotalWidth(_labelGap, _controlGap);

				const currentHeight:Number = oldControlGroup.calculateTotalHeight(fieldGap);
				if (currentHeight > measuredHeight)
				{
					measuredHeight = currentHeight;
				}

				if (i == numElements)
				{
					break;
				}
			}
		}

		layoutTarget.measuredWidth = measuredWidth;
		layoutTarget.measuredHeight = measuredHeight;
	}

	private function isAnotherColumnElement(element:ILayoutElement):Boolean
	{
		return element is Skin && Skin(element).component is VSeparator || isStartElement(element);
	}

	private function isStartElement(element:ILayoutElement):Boolean
	{
		return element is Label /* control не может состоять только из Label, поэтому дальше явно часть текущего control, а не новый */ ||
			   (element is CheckBox && CheckBox(element).label.length > 0);
	}

	override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		var layoutTarget:GroupBase = target;
		if (layoutTarget == null)
		{
			return;
		}

		var x:Number = 0;
		for each (var column:Column in columns)
		{
			var localY:Number = 0;
			var columnCompositionsLength:int = column.compositions.length;
			if (columnCompositionsLength == 2)
			{
				localY = 3;
			}

			if (column.isAuxiliaryElementFirst)
			{
				column.auxiliaryElement.setLayoutBoundsPosition(x, localY);
				column.auxiliaryElement.setLayoutBoundsSize(NaN, NaN);

				localY += column.auxiliaryElement.getPreferredBoundsHeight() + fieldGap;
			}

			for (var compositionIndex:int = 0; compositionIndex < columnCompositionsLength; compositionIndex++)
			{
				var localX:Number = x;
				const compositionHeight:Number = column.heights[compositionIndex];
				var composition:Vector.<ILayoutElement> = column.compositions[compositionIndex];
				for (var elementIndex:int = 0; elementIndex < composition.length; elementIndex++)
				{
					if (elementIndex == 1)
					{
						localX += _labelGap;
					}
					else if (elementIndex == 0 && compositionIndex == 0 && composition.length == 1 && columnCompositionsLength != 2)
					{
						localY += 3; // see comment BasicGroupSkin#PADDING_TOP
					}

					var element:ILayoutElement = composition[elementIndex];
					element.setLayoutBoundsPosition(localX, localY + ((compositionHeight - element.getPreferredBoundsHeight()) / 2));
					element.setLayoutBoundsSize(NaN, NaN);

					if (elementIndex == 0)
					{
						localX += column.widths[elementIndex];
					}
					else
					{
						localX += element.getPreferredBoundsWidth() + _controlGap;
					}
				}

				localY += compositionHeight + fieldGap;
			}

			if (!column.isAuxiliaryElementFirst && column.auxiliaryElement != null)
			{
				column.auxiliaryElement.setLayoutBoundsPosition(x, localY);
				column.auxiliaryElement.setLayoutBoundsSize(NaN, NaN);
			}

			x += column.totalWidth;
			var separator:Skin = column.separator;
			if (separator == null)
			{
				x += columnGap;
			}
			else
			{
				separator.setLayoutBoundsPosition(x, 0);
				separator.setLayoutBoundsSize(NaN, NaN);

				x += separator.getPreferredBoundsWidth();
			}
		}
	}

	private function invalidateTargetSizeAndDisplayList():void
    {
		var group:GroupBase = target;
		if (group != null)
		{
			group.invalidateSize();
			group.invalidateDisplayList();
		}
    }
}
}