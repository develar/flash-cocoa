package cocoa.graphics
{
import cocoa.util.RatioUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.events.EventDispatcher;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.events.PropertyChangeEvent;
import mx.graphics.IFill;

public class BitmapFill extends EventDispatcher implements IFill
{
	/**
	 * main bitmapData source
	 */
	private var bitmapData:BitmapData;

	/**
	 * if we create bitmapData internaly we need to dispose it when no longer need it
	 */
	private var bitmapDataCreated:Boolean;

	/**
	 * clone of main bitmapData used for apply alpha if it is not 1
	 */
	private var alphaSource:BitmapData;

	/**
	 * clone of main bitmapData used for apply some fill modes
	 * when the size of bitmapData source smaller than filled rectangle
	 */
	private var clippedSource:BitmapData;

	private static const transformMatrix:Matrix = new Matrix();

	private var _source:Object;
	public function get source():Object
	{
		return _source;
	}

	/**
	 * came from SDK source but slightly modifyed
	 * now the supported types are Class, DisplayObject, Bitmap, BitmapData
	 * but String is not supported as we don't load external resources by this class
	 */
	public function set source(value:Object):void
	{
		if (value == source)
		{
			return;
		}

		var bitmapDataTemp:BitmapData;
		var internalyCreated:Boolean = false;

		var tmpSprite:DisplayObject;
		var oldValue:Object = _source;
		_source = value;

		if (value != null)
		{
			if (value is BitmapData)
			{
				bitmapDataTemp = BitmapData(value);
			}
			else if (value is Bitmap)
			{
				bitmapDataTemp = Bitmap(value).bitmapData;
			}
			else if (value is Class)
			{
				var clazz:Class = Class(value);
				value = new clazz();
			}
			else if (value is DisplayObject)
			{
				tmpSprite = DisplayObject(value);
			}
			else
			{
				throw new ArgumentError("unknow source type");
			}

			if (bitmapDataTemp == null && tmpSprite != null)
			{
				bitmapDataTemp = new BitmapData(tmpSprite.width, tmpSprite.height, true, 0);
				bitmapDataTemp.draw(tmpSprite, new Matrix());
				internalyCreated = true;
			}

			// If the bitmapData isn't transparent (ex. JPEG), then copy it into a transparent bitmapData
			if (alpha != 1 && !bitmapDataTemp.transparent)
			{
				bitmapDataTemp = switchBitmapTransparent(bitmapDataTemp);
				internalyCreated = true;
			}
		}
		_source = value;
		setBitmapData(bitmapDataTemp, internalyCreated);
		dispatchFillChangedEvent("source", oldValue, value);
	}


	private function switchBitmapTransparent(sourceBitmap:BitmapData):BitmapData
	{
		var transparentBitmap:BitmapData = new BitmapData(sourceBitmap.width, sourceBitmap.height, !sourceBitmap.transparent);
		transparentBitmap.draw(sourceBitmap);
		return transparentBitmap;
	}

	private function setBitmapData(bitmapDataTemp:BitmapData, internallyCreated:Boolean = false):void
	{
		// Clear previous bitmapData
		if (bitmapData != null)
		{
			// Dispose the bitmap if we created it
			if (bitmapDataCreated)
			{
				bitmapData.dispose();
			}
			bitmapData = null;
		}

		bitmapDataCreated = internallyCreated;
		bitmapData = bitmapDataTemp;
	}

	private var _alpha:Number = 1;
	public function get alpha():Number
	{
		return _alpha;
	}

	public function set alpha(value:Number):void
	{
		if (_alpha == value)
		{
			return;
		}

		var oldValue:Number = _alpha;
		if (value != 1 && bitmapData != null && !bitmapData.transparent)
		{
			setBitmapData(switchBitmapTransparent(bitmapData), true);
		}

		_alpha = value;
		dispatchFillChangedEvent("alpha", oldValue, value);
	}

	private var _rotation:Number = 1;
	public function get rotation():Number
	{
		return _rotation;
	}

	public function set rotation(value:Number):void
	{
		if (value == rotation)
		{
			return;
		}

		var oldValue:Number = _rotation;
		_rotation = value;
		dispatchFillChangedEvent("rotation", oldValue, value);
	}

	private var _fillType:String = BitmapFillType.SCALE_TO_FIT;
	public function get fillType():String
	{
		return _fillType;
	}

	[Inspectable(category="General", enumeration="scaleToFit,scaleToFill,stretch,originalSize,tile,imagePreview", defaultValue="scaleToFit")]
	public function set fillType(value:String):void
	{
		if (value == fillType)
		{
			return;
		}

		var oldValue:String = _fillType;
		_fillType = value;
		dispatchFillChangedEvent("fillType", oldValue, value);
	}

	public function begin(target:Graphics, targetBounds:Rectangle, targetOrigin:Point):void
	{
		if (bitmapData == null || targetBounds.height < 1 || targetBounds.width < 1)
		{
			return;
		}

		var sourceAsBitmapData:BitmapData = bitmapData;
		transformMatrix.identity();
		transformMatrix.translate(targetBounds.x, targetBounds.y);

		// If we need to apply the alpha, we need to make another clone. So dispose of the old one.
		if (alphaSource)
		{
			alphaSource.dispose();
			alphaSource = null;
		}

		// dispose of the old clippedSource.
		if (clippedSource)
		{
			clippedSource.dispose();
			clippedSource = null;
		}

		if (fillType == BitmapFillType.SCALE_TO_FIT || (fillType == BitmapFillType.IMAGE_PREVIEW && (sourceAsBitmapData.width > targetBounds.width || sourceAsBitmapData.height > targetBounds.height)))
		{
			clippedSource = new BitmapData(targetBounds.width, targetBounds.height, true, 0);
			var scaledToFit:Rectangle = RatioUtil.scaleToFit(sourceAsBitmapData.rect, targetBounds);

			var scaleMatrix:Matrix = new Matrix;
			scaleMatrix.scale(scaledToFit.width / sourceAsBitmapData.width, scaledToFit.height / sourceAsBitmapData.height);
			scaleMatrix.translate((targetBounds.width - scaledToFit.width) / 2, (targetBounds.height - scaledToFit.height) / 2);
			clippedSource.draw(sourceAsBitmapData, scaleMatrix);
			sourceAsBitmapData = clippedSource;
		}
		else if (fillType == BitmapFillType.SCALE_TO_FILL)
		{
			var scaledToFill:Rectangle = RatioUtil.scaleToFill(sourceAsBitmapData.rect, targetBounds);
			transformMatrix.scale(scaledToFill.width / sourceAsBitmapData.width, scaledToFill.height / sourceAsBitmapData.height);
			transformMatrix.translate((targetBounds.width - scaledToFill.width) / 2, (targetBounds.height - scaledToFill.height) / 2);

		}
		else if (fillType == BitmapFillType.STRETCH)
		{
			transformMatrix.scale(targetBounds.width / sourceAsBitmapData.width, targetBounds.height / sourceAsBitmapData.height);
		}
		else if (fillType == BitmapFillType.CENTER ||
				 (fillType == BitmapFillType.IMAGE_PREVIEW &&
				  sourceAsBitmapData.width <= targetBounds.width && sourceAsBitmapData.height <= targetBounds.height))
		{
			var x:Number = (targetBounds.width - sourceAsBitmapData.width) / 2;
			var y:Number = (targetBounds.height - sourceAsBitmapData.height) / 2;
			if (x > 0 || y > 0)
			{
				clippedSource = new BitmapData(targetBounds.width, targetBounds.height, true, 0);
				var originalMatrix:Matrix = new Matrix;
				originalMatrix.translate(x, y);
				clippedSource.draw(sourceAsBitmapData, originalMatrix);
				sourceAsBitmapData = clippedSource;
			}
			else
			{
				transformMatrix.translate(x, y);
			}
		}

		// Reapply the alpha if alpha is not 1.
		var applyAlphaMultiplier:Boolean = alpha != 1;

		// Apply the alpha to a clone of the source. We don't want to modify the actual source because applying the alpha
		// will modify the source and we have no way to restore the source back its original alpha value.
		if (applyAlphaMultiplier)
		{
			alphaSource = sourceAsBitmapData.clone();
			var ct:ColorTransform = new ColorTransform();
			ct.alphaMultiplier = alpha;
			alphaSource.colorTransform(new Rectangle(0, 0, sourceAsBitmapData.width, sourceAsBitmapData.height), ct);
		}

		// If we have a alphaSource, then use it. Otherwise, we just use the source.
		if (alphaSource)
		{
			sourceAsBitmapData = alphaSource;
		}

		target.beginBitmapFill(sourceAsBitmapData, transformMatrix);
	}

	public function end(target:Graphics):void
	{
		target.endFill();
	}

	private function dispatchFillChangedEvent(prop:String, oldValue:Object, value:Object):void
	{
		dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, prop, oldValue, value));
	}
}
}