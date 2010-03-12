package org.flyti.layout
{
import flash.display.DisplayObject;

import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;
import spark.layouts.TileOrientation;
import spark.layouts.supportClasses.LayoutBase;
import spark.layouts.supportClasses.LayoutElementHelper;

public class FlowLayout extends LayoutBase
{
	private var tileWidth:Number;
	private var tileHeight:Number;

	private var determinedContainerWidth:Number;
	private var determinedContainerHeight:Number;

	private var elementsCount:Number;

	private var rowCount:Number;
	private var columnCount:Number;

	public function FlowLayout()
	{
		super();
	}

	private var _horizontalGap:Number = 0;

	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	public function get horizontalGap():Number
	{
	  return _horizontalGap;
	}

	public function set horizontalGap(value:Number):void
	{
		if (value == _horizontalGap)
		{
			return;
		}
		_horizontalGap = value;
		invalidateTargetSizeAndDisplayList();
	}

	private var _verticalGap:Number = 0;

	[Bindable("propertyChange")]
	[Inspectable(category="General")]
	public function get verticalGap():Number
	{
	  return _verticalGap;
	}

	public function set verticalGap(value:Number):void
	{
		if (value == _verticalGap)
		{
			return;
		}
		_verticalGap = value;
		invalidateTargetSizeAndDisplayList();
	}

	private var _orientation:String = TileOrientation.ROWS;

	[Inspectable(category="General", enumeration="rows,columns", defaultValue="rows")]
	public function get orientation():String
	{
		return _orientation;
	}

	public function set orientation(value:String):void
	{
		if (_orientation == value)
			return;

		_orientation = value;
		invalidateTargetSizeAndDisplayList();
	}

	override public function measure():void
	{
		var layoutTarget:GroupBase = target;
		if (!layoutTarget)
		{
			return;
		}

		updateActualValues();

		if (columnCount == 0)
		{
			layoutTarget.measuredWidth = 0;
			layoutTarget.measuredMinWidth = 0;
		}
		else
		{
			var widthByTiles:Number = columnCount * (tileWidth + _horizontalGap) - _horizontalGap;

			if (isNaN(determinedContainerWidth) || determinedContainerWidth < widthByTiles)
			{
				layoutTarget.measuredWidth = widthByTiles;
				layoutTarget.measuredMinWidth = widthByTiles;
			}
			else
			{
				layoutTarget.measuredWidth = determinedContainerWidth;
				layoutTarget.measuredMinWidth = determinedContainerWidth;
			}
		}
		if (rowCount == 0)
		{
			layoutTarget.measuredHeight = 0;
			layoutTarget.measuredMinHeight = 0;
		}
		else
		{
			var heightByTiles:Number = rowCount * (tileHeight + _verticalGap) - _verticalGap;

			if (isNaN(determinedContainerHeight) || determinedContainerHeight < heightByTiles)
			{
				layoutTarget.measuredHeight = heightByTiles;
				layoutTarget.measuredMinHeight = heightByTiles;
			}
			else
			{
				layoutTarget.measuredHeight = determinedContainerHeight;
				layoutTarget.measuredMinHeight = determinedContainerHeight;
			}
		}
		trace("");
	}

	override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		var layoutTarget:GroupBase = target;
		if (!layoutTarget)
		{
			return;
		}

		updateActualValues();

		var xPos:Number = 0;
		var yPos:Number = 0;

		var xMajorDelta:Number;
		var yMajorDelta:Number;

		var xMinorDelta:Number;
		var yMinorDelta:Number;

		var counter:int = 0;
		var counterLimit:int;

		// Setup counterLimit and deltas based on orientation
		if (orientation == TileOrientation.ROWS)
		{
		counterLimit = columnCount;
		xMajorDelta = tileWidth + _horizontalGap;
		xMinorDelta = 0;
		yMajorDelta = 0;
		yMinorDelta = tileHeight + _verticalGap;
		}
		else
		{
		counterLimit = rowCount;
		xMajorDelta = 0;
		xMinorDelta = tileWidth + _horizontalGap;
		yMajorDelta = tileHeight + _verticalGap;
		yMinorDelta = 0;
		}

		var count:int = layoutTarget.numElements;

		for (var index:int = 0; index <= count; index++)
		{
			var element:ILayoutElement = null;
			element = layoutTarget.getElementAt(index);

			if (!element || !element.includeInLayout)
			{
				continue;
			}

			var cellX:int = Math.round(xPos);
			var cellY:int = Math.round(yPos);
			var cellWidth:int = Math.round(xPos + tileWidth) - cellX;
			var cellHeight:int = Math.round(yPos + tileHeight) - cellY;

			sizeAndPositionElement(element, cellX, cellY, cellWidth, cellHeight);

			xPos += xMajorDelta;
			yPos += yMajorDelta;

			if (++counter >= counterLimit)
			{
				counter = 0;
				if (orientation == TileOrientation.ROWS)
				{
					xPos = 0;
					yPos += yMinorDelta;
				}
				else
				{
					xPos += xMinorDelta;
					yPos = 0;
				}
			}
		}
		//layoutTarget.setLayoutBoundsSize(Math.ceil(columnCount * (tileWidth + _horizontalGap) - _horizontalGap), Math.ceil(rowCount * (tileHeight + _verticalGap) - _verticalGap), false);
		layoutTarget.setContentSize(Math.ceil(columnCount * (tileWidth + _horizontalGap) - _horizontalGap), Math.ceil(rowCount * (tileHeight + _verticalGap) - _verticalGap));

	}

	private function sizeAndPositionElement(element:ILayoutElement, cellX:int, cellY:int, cellWidth:int, cellHeight:int):void
	{
		var childWidth:Number = NaN;
		var childHeight:Number = NaN;

		childWidth = cellWidth;
		childHeight = cellHeight;

		var maxChildWidth:Number = Math.min(element.getMaxBoundsWidth(), cellWidth);
		var maxChildHeight:Number = Math.min(element.getMaxBoundsHeight(), cellHeight);
		childWidth = Math.max(element.getMinBoundsWidth(), Math.min(maxChildWidth, childWidth));
		childHeight = Math.max(element.getMinBoundsHeight(), Math.min(maxChildHeight, childHeight));

		element.setLayoutBoundsSize(childWidth, childHeight);

		var x:Number = cellX;
		var y:Number = cellY;
		element.setLayoutBoundsPosition(x, y);
	}
	private function updateActualValues():void
	{
		calculateMinTileSize();
		calculateDeterminedContainerSize();
		calculateRowAndColumnCount();
	}


	private function calculateMinTileSize():void
	{
		tileWidth = 0;
		tileHeight = 0;

		var layoutTarget:GroupBase = target;
		var count:int = layoutTarget.numElements;
		elementsCount = count;
		for (var i:int = 0; i < count; i++)
		{
			var element:ILayoutElement = layoutTarget.getElementAt(i);
			if (!element || !element.includeInLayout)
			{
				elementsCount--;
				continue;
			}
			tileWidth = Math.max(tileWidth, element.getPreferredBoundsWidth());
			tileHeight = Math.max(tileHeight, element.getPreferredBoundsHeight());
		}
	}

	private function calculateDeterminedContainerSize():void
	{

		var group:GroupBase = target;
		if (!group)
		{
			return;
		}

		var left:Number = LayoutElementHelper.parseConstraintValue(group.left);
		var right:Number = LayoutElementHelper.parseConstraintValue(group.right);
		var width:Number = group.explicitWidth;

		var top:Number = LayoutElementHelper.parseConstraintValue(group.top);
		var bottom:Number = LayoutElementHelper.parseConstraintValue(group.bottom);
		var height:Number = group.explicitHeight;

		var dO:DisplayObject = DisplayObject(group.parent);

		determinedContainerWidth = isNaN(width) ? isNaN(left) || isNaN(right) ? NaN : group.parent.width - left - right : width;
		determinedContainerHeight = isNaN(height) ? isNaN(top) || isNaN(bottom) ? NaN : group.parent.height - top - bottom : height;
	}

	private function calculateRowAndColumnCount():void
	{
		switch(_orientation)
		{
			case TileOrientation.ROWS:
			{
				if (isNaN(determinedContainerWidth) || determinedContainerWidth < tileWidth)
				{
					columnCount = 1;
					rowCount = elementsCount;
				}
				else
				{
					columnCount = Math.floor(determinedContainerWidth / (tileWidth + horizontalGap));
					rowCount = Math.ceil(elementsCount / columnCount);
				}
				break;
			}
			case TileOrientation.COLUMNS:
			{
				if (isNaN(determinedContainerHeight) || determinedContainerHeight < tileHeight)
				{
					rowCount = 1;
					columnCount = elementsCount;
				}
				else
				{
					rowCount = Math.floor(determinedContainerHeight / (tileHeight + verticalGap));
					columnCount = Math.ceil(elementsCount / rowCount);
				}
				break;
			}
		}
	}

	private function invalidateTargetSizeAndDisplayList():void
	{
		var group:GroupBase = target;
		if (!group)
		{
			return;
		}
		group.invalidateSize();
		group.invalidateDisplayList();
	}
}
}