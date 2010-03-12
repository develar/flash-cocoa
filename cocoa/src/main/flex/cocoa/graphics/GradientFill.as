package cocoa.graphics
{
import flash.display.Graphics;
import flash.display.GraphicsGradientFill;
import flash.display.IGraphicsData;
import flash.events.EventDispatcher;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;
import mx.graphics.IFill;

import org.flyti.util.List;

public class GradientFill extends EventDispatcher implements IFill
{
	private static const sharedMatrix:Matrix = new Matrix();

	private const graphicsGradientFill:GraphicsGradientFill = new GraphicsGradientFill();
	private const graphicsData:Vector.<IGraphicsData> = new Vector.<IGraphicsData>(1, true);

	public function GradientFill()
	{
		graphicsGradientFill.matrix = sharedMatrix;
		graphicsData[0] = graphicsGradientFill;
	}

	[Inspectable(category="General", enumeration="linear,radial", defaultValue="linear")]
	public function set type(value:String):void
	{
		if (value == graphicsGradientFill.type)
		{
			return;
		}

		graphicsGradientFill.type = value;
		dispatchFillChangedEvent("type");
	}

	private var _angle:Number = 270;
	public function set angle(value:Number):void
	{
		if (value == _angle)
		{
			return;
		}

		_angle = value;
		dispatchFillChangedEvent("angle");
	}

	private var _colors:List;
	public function get colors():List
	{
		return _colors;
	}
	public function set colors(value:List):void
	{
		if (value == _colors)
		{
			return;
		}
		if (_colors != null)
		{
			_colors.removeEventListener(CollectionEvent.COLLECTION_CHANGE, listChangeHandler);
		}

		_colors = value;
		if (_colors != null)
		{
			_colors.addEventListener(CollectionEvent.COLLECTION_CHANGE, listChangeHandler);
			processColors(value);
			dispatchFillChangedEvent("colors");
		}
	}

	private function listChangeHandler(event:CollectionEvent):void
	{
		switch (event.kind)
		{
			case CollectionEventKind.REPLACE:
			{
				var updateInfo:PropertyChangeEvent = event.items[0];
				updateColor(event.location, uint(updateInfo.newValue));
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE));
			}
			break;
		}
	}

	/**
	 * process ARGB colors for extract alphas and convert colors to RGB
	 * @param colors ARGB colors
	 */
	private function processColors(colors:List):void
	{
		graphicsGradientFill.alphas = new Array(colors.size);
		graphicsGradientFill.colors = new Array(colors.size);
		for (var i:int, n:int = colors.size; i < n; i++)
		{
			updateColor(i, uint(colors.getItemAt(i)));
		}
	}

	private function updateColor(i:int, argb:uint):void
	{
		graphicsGradientFill.alphas[i] = ((argb >>> 24) & 0xff) / 255;
		graphicsGradientFill.colors[i] = argb & 0x00ffffff;
	}

	public function set ratios(value:Array):void
	{
		graphicsGradientFill.ratios = value;
		dispatchFillChangedEvent("ratios");
	}

	public function begin(target:Graphics, targetBounds:Rectangle, targetOrigin:Point):void
	{
		if (graphicsGradientFill.ratios == null)
		{
			// simple gradient fill with two colors
			graphicsGradientFill.ratios = [0x0, 0xff];
		}

		sharedMatrix.createGradientBox(targetBounds.width, targetBounds.height, _angle * Math.PI / -180, targetBounds.x, targetBounds.y);
		target.drawGraphicsData(graphicsData);
	}

	public function end(target:Graphics):void
	{
		target.endFill();
	}

	private function dispatchFillChangedEvent(propertyName:String):void
	{
		dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangeEventKind.UPDATE, propertyName));
	}
}
}