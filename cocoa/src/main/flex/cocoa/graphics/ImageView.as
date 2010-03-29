package cocoa.graphics
{
import cocoa.util.RatioUtil;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.GradientType;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.UIComponent;

import spark.layouts.HorizontalAlign;
import spark.layouts.VerticalAlign;

/**
 * 
 */
public class ImageView extends UIComponent
{

	private var filledRect:Rectangle;


	private var _bitmapData:BitmapData;
	public function set bitmapData(value:BitmapData):void
	{
		if (_bitmapData != value)
		{
			_bitmapData = value;
			invalidateSize();
			invalidateDisplayList();
		}
	}

	public function get bitmapData():BitmapData
	{
		return _bitmapData;
	}

	private var _fillType:String = BitmapFillType.SCALE_TO_FIT;
	[Inspectable(category="General", enumeration="scaleToFit,scaleToFill", defaultValue="scaleToFit")]
	public function set fillType(value:String):void
	{
		if (value != _fillType)
		{
			_fillType = value;
			invalidateDisplayList();
		}
	}

	public function get fillType():String
	{
		return _fillType;
	}

	/**
	 * this bounds is set to pre-calculate the size of the scaled image
	 * and get valid measuredWidth and measuredHeight before updateDisplayList called
	 */
	private var _boundsRect:Rectangle;
	public function set boundsRect(value:Rectangle):void
	{
		if (_boundsRect == value || (_boundsRect != null && value != null && _boundsRect.equals(value)))
		{
			return;
		}
		_boundsRect = value;
		filledRect = null;
		invalidateSize();
	}


	private var _verticalAlign:String = VerticalAlign.MIDDLE;
	[Inspectable(category="General", enumeration="middle,top,bottom", defaultValue="middle")]
	public function set verticalAlign(value:String):void
	{
		if (_verticalAlign != value)
		{
			_verticalAlign = value;
			invalidateDisplayList();
		}
	}

	public function get verticalAlign():String
	{
		return _verticalAlign;
	}

	private var _horizontalAlign:String = HorizontalAlign.CENTER;
	[Inspectable(category="General", enumeration="center,right,left", defaultValue="middle")]
	public function set horizontalAlign(value:String):void
	{
		if (_horizontalAlign != value)
		{
			_horizontalAlign = value;
			invalidateDisplayList();
		}
	}

	public function get horizontalAlign():String
	{
		return _horizontalAlign;
	}

	private var _showReflection:Boolean;
	public function get showReflection():Boolean
	{
		return _showReflection;
	}

	public function set showReflection(value:Boolean):void
	{
		if(_showReflection != value)
		{
			_showReflection = value;
			invalidateDisplayList();
		}
	}

	/**
	 * The fill color for the reflection bitmap,
	 * if NaN the reflection bitmap becomes transparent.
	 * This property ignored if showReflection set to false.
	 */
	private var _reflectionColor:Number = NaN;
	public function get reflectionColor():Number
	{
		return _reflectionColor;
	}

	public function set reflectionColor(value:Number):void
	{
		if(_reflectionColor != value)
		{
			_reflectionColor = value;
			if(_showReflection)
			{
				invalidateDisplayList();
			}
		}
	}


	public function getImagePositionAtBounds(bounds:Rectangle):Point
	{
		if(bounds != null && _bitmapData != null)
		{
			var measuredRect:Rectangle = createFilledRect(bounds);
			return new Point(measuredRect.x, measuredRect.y);
		}
		else
		{
			return null;
		}
	}


	override protected function measure():void
	{
		//no bitmapData size considered without predefined boundsRect
		if (_boundsRect != null && _bitmapData != null)
		{
			var measuredRect:Rectangle = createFilledRect(_boundsRect);
			measuredWidth = measuredRect.width;
			measuredMinWidth = measuredRect.width;
			measuredHeight = measuredRect.height;
			measuredMinHeight = measuredRect.height;
			return;
		}
		super.measure();
	}


	override protected function updateDisplayList(w:Number, h:Number):void
	{
		graphics.clear();

		if(w == 0 || h == 0 || _bitmapData == null)
		{
			return;
		}

		var filledRect:Rectangle = createFilledRect(new Rectangle(0,0,w,h));
		var matrix:Matrix = new Matrix();
		matrix.scale(filledRect.width / _bitmapData.width, filledRect.height / _bitmapData.height);
		matrix.translate(filledRect.x,filledRect.y);
		graphics.beginBitmapFill(_bitmapData,matrix,false);

		var imageWidth:Number;
		var imageHeight:Number;
		var imageX:Number;
		var imageY:Number;
		if(_fillType == BitmapFillType.SCALE_TO_FIT)
		{
			imageWidth = filledRect.width;
			imageHeight = filledRect.height;
			imageX = filledRect.x;
			imageY = filledRect.y;
		}
		else
		{
			imageWidth = w;
			imageHeight = h;
			imageX = 0;
			imageY = 0;
		}
		graphics.drawRect(imageX,imageY,imageWidth,imageHeight);
		graphics.endFill();

		if(_showReflection){
			var m1:Matrix = new Matrix;
			m1.scale(filledRect.width / _bitmapData.width, -filledRect.height / _bitmapData.height);
			m1.translate(0, filledRect.height);
			var bitmap:BitmapData = new BitmapData(imageWidth,imageHeight,true,0);
			var sprite:Sprite = new Sprite();
			var alphas:Array = [.3, 0];
			var ratios:Array = [0, 200];
			var m2:Matrix = new Matrix();
			m2.createGradientBox(imageWidth,imageHeight, Math.PI/2, 0, 0);
			sprite.graphics.beginGradientFill(GradientType.LINEAR, [0, 0], alphas, ratios, m2);
			bitmap.draw(_bitmapData,m1,null,BlendMode.LAYER);
			sprite.graphics.drawRect(0,0,bitmap.width,bitmap.height);
			bitmap.draw(sprite, null, null, BlendMode.ALPHA);

			if(!isNaN(_reflectionColor))
			{
				var bottomLayer:BitmapData = new BitmapData(imageWidth, imageHeight, false, _reflectionColor);
				bottomLayer.draw(bitmap);
				bitmap = bottomLayer;
			}

			var m3:Matrix = new Matrix;
			m3.translate(imageX,imageY+imageHeight);

			graphics.beginBitmapFill(bitmap,m3,false);
			graphics.drawRect(imageX,imageY+imageHeight,imageWidth,imageHeight);
			graphics.endFill();
		}
	}

	private function createFilledRect(bounds:Rectangle):Rectangle
	{
		var filledRect:Rectangle;
		if(_fillType == BitmapFillType.SCALE_TO_FIT)
		{
			filledRect = RatioUtil.scaleToFit(_bitmapData.rect,bounds);

			if (filledRect.height < bounds.height && _verticalAlign != VerticalAlign.TOP)
			{
				if(_verticalAlign == VerticalAlign.MIDDLE)
				{
					filledRect.y += (bounds.height - filledRect.height)*.5;
				}
				else
				{
					filledRect.y += (bounds.height - filledRect.height);
				}
			}
			else if(filledRect.width < bounds.width && _horizontalAlign != HorizontalAlign.LEFT)
			{
				if(_horizontalAlign == HorizontalAlign.CENTER)
				{
					filledRect.x += (bounds.width - filledRect.width) * .5;
				}
				else
				{
					filledRect.x += ( bounds.width - filledRect.width);
				}
			}

		}
		else
		{
			filledRect = RatioUtil.scaleToFill(_bitmapData.rect,bounds);

			if (filledRect.height > bounds.height && _verticalAlign != VerticalAlign.TOP)
			{
				if(_verticalAlign == VerticalAlign.MIDDLE)
				{
					filledRect.y -= (filledRect.height - bounds.height)* .5;
				}
				else
				{
					filledRect.y -= filledRect.height - bounds.height
				}
			}
			else if(filledRect.width > bounds.width && _horizontalAlign != HorizontalAlign.LEFT)
			{
				if(_horizontalAlign == HorizontalAlign.CENTER)
				{
					filledRect.x -= (filledRect.width - bounds.width) * .5;
				}
				else
				{
					filledRect.x -= filledRect.width - bounds.width;
				}
			}
		}
		return filledRect;
	}
}
}