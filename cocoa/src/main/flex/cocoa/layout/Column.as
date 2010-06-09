package cocoa.layout
{
import cocoa.plaf.Skin;

import mx.core.ILayoutElement;

/**
 * Composition — композиция элементов, состоит из label + ui control. А может также состоять и из label + ui control + ui control,
 * к примеру, Top [CheckBox] [NumericStepper], где CheckBox enable/disable NumericStepper
 */
internal final class Column
{
	private var currentRowWidth:Number = 0;

	private var _maxControlLengthInComposition:int = 0;
	public function get maxControlLengthInComposition():int
	{
		return _maxControlLengthInComposition;
	}

	private var currentComposition:Vector.<ILayoutElement>;
	public const compositions:Vector.<Vector.<ILayoutElement>> = new Vector.<Vector.<ILayoutElement>>();

	private var rowMaxWidth:Number = 0;

	public const heights:Vector.<Number> = new Vector.<Number>();

	public var separator:Skin;

	/**
	 * Типа checkbox "constrainProportionsCheckBox" который в этой же колонке, но общий для всей composition
	 */
	public var auxiliaryElement:ILayoutElement;

	public var isAuxiliaryElementFirst:Boolean;

	private var _labelMaxWidth:Number = 0;
	public function get labelMaxWidth():Number
	{
		return _labelMaxWidth;
	}

	public function get finalized():Boolean
	{
		return compositions.fixed;
	}

	private var _totalWidth:Number;
	public function get totalWidth():Number
	{
		return _totalWidth;
	}

	public function calculateTotalWidth(labelGap:Number, controlGap:Number):Number
	{
		_totalWidth = _labelMaxWidth + rowMaxWidth;
		if (_maxControlLengthInComposition > 1)
		{
			_totalWidth += labelGap + ((_maxControlLengthInComposition - 2) * controlGap);
		}

		if (auxiliaryElement != null)
		{
			const auxiliaryElementWidth:Number = auxiliaryElement.getPreferredBoundsWidth();
			if (auxiliaryElementWidth > _totalWidth)
			{
				_totalWidth = auxiliaryElementWidth;
			}
		}

		return _totalWidth;
	}

	public function calculateTotalHeight(gap:Number):Number
	{
		var result:Number = 0;
		for each (var number:Number in heights)
		{
			result += number;
		}

		result += gap * (heights.length - 1);

		if (auxiliaryElement != null)
		{
			result += gap + auxiliaryElement.getPreferredBoundsHeight();
		}

		return result;
	}

	public function addComposition():void
	{
		if (currentComposition != null)
		{
			finalizeCurrentComposition();
		}

		currentComposition = new Vector.<ILayoutElement>();
		compositions.push(currentComposition);
	}

	public function addElement(element:ILayoutElement):void
	{
		const rowIndex:int = compositions.length - 1;
		const columnIndex:int = currentComposition.push(element) - 1;

		const width:Number = element.getPreferredBoundsWidth();
		if (columnIndex == 0)
		{
			if (width > _labelMaxWidth)
			{
				_labelMaxWidth = width;
			}
		}
		else
		{
			currentRowWidth += width;
		}

		const height:Number = element.getPreferredBoundsHeight();
		if (heights.length == rowIndex)
		{
			heights.push(height);
		}
		else if (height > heights[rowIndex])
		{
			heights[rowIndex] = height;
		}
	}

	public function finalize():void
	{
		finalizeCurrentComposition();
		currentComposition = null;

		compositions.fixed = true;
		heights.fixed = true;
	}

	private function finalizeCurrentComposition():void
	{
		currentComposition.fixed = true;
		if (currentComposition.length > _maxControlLengthInComposition)
		{
			_maxControlLengthInComposition = currentComposition.length;
		}

		if (currentRowWidth > rowMaxWidth)
		{
			rowMaxWidth = currentRowWidth;
		}
		currentRowWidth = 0;
	}
}
}