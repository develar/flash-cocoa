package cocoa.graphics
{
import cocoa.AbstractView;
import cocoa.Border;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;
import cocoa.util.RatioUtil;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObjectContainer;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import spark.layouts.HorizontalAlign;
import spark.layouts.VerticalAlign;

public class ImageView extends AbstractView
{
	private static const sharedRectangle:Rectangle = new Rectangle();
	private static const sharedMatrix:Matrix = new Matrix();

	private var imageFrame:Rectangle;

	private var _border:Border;
	public function get border():Border
	{
		return _border;
	}

	public function set border(value:Border):void
	{
		_border = value;
	}

	private var _bitmapData:BitmapData;
	public function get bitmapData():BitmapData
	{
		return _bitmapData;
	}

	public function set bitmapData(value:BitmapData):void
	{
		if (_bitmapData != value)
		{
			_bitmapData = value;
			invalidateSize();
			invalidateDisplayList();
		}
	}

	private var _fillType:String = BitmapFillType.SCALE_TO_FIT;
	[Inspectable(category="General", enumeration="scaleToFit,scaleToFill,imagePreview", defaultValue="scaleToFit")]
	public function get fillType():String
	{
		return _fillType;
	}

	public function set fillType(value:String):void
	{
		if (value != _fillType)
		{
			_fillType = value;
			invalidateDisplayList();
		}
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
		if (_showReflection != value)
		{
			_showReflection = value;
		}
	}

	/**
	 * The fill color for the reflection bitmap,
	 * if NaN the reflection bitmap becomes transparent.
	 * This property ignored if showReflection set to false.
	 */
	private var _reflectionColor:Number = NaN;
	public function set reflectionColor(value:Number):void
	{
		if (_reflectionColor != value)
		{
			_reflectionColor = value;
		}
	}

	override protected function createChildren():void
	{
		super.createChildren();

		if (_border != null)
		{
			return;
		}

		// ImageView и не скин компонента, и не item renderer, так что пока что он сам ищет для себя LaF.
		var laf:LookAndFeel;
		var p:DisplayObjectContainer = parent;
		while (p != null)
		{
			if (p is LookAndFeelProvider)
			{
				laf = LookAndFeelProvider(p).laf;
				break;
			}
			else
			{
				if (p is Skin && Skin(p).component is LookAndFeelProvider)
				{
					laf = LookAndFeelProvider(Skin(p).component).laf;
					break;
				}
				else
				{
					p = p.parent;
				}
			}
		}

		_border = laf.getBorder("ImageView.border");
	}

	override protected function measure():void
	{
		// no bitmapData size considered without predefined boundsRect
		if (imageFrame != null && _bitmapData != null)
		{
			measuredMinWidth = measuredWidth = imageFrame.width;
			measuredMinHeight = measuredHeight = imageFrame.height;
		}
		else
		{
			super.measure();
		}
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var g:Graphics = graphics;
		g.clear();

		if (w == 0 || h == 0 || _bitmapData == null)
		{
			return;
		}

		sharedRectangle.width = w;
		sharedRectangle.height = h;

		var scaledImageRect:Rectangle = calculateImageFrame(sharedRectangle);
		var imageScaleX:Number = scaledImageRect.width / _bitmapData.width;
		var imageScaleY:Number = scaledImageRect.height / _bitmapData.height;
		var imageWidth:Number;
		var imageHeight:Number;
		var imageX:Number;
		var imageY:Number;
		if (_fillType == BitmapFillType.SCALE_TO_FIT || _fillType == BitmapFillType.IMAGE_PREVIEW)
		{
			imageWidth = scaledImageRect.width;
			imageHeight = scaledImageRect.height;
			imageX = scaledImageRect.x;
			imageY = scaledImageRect.y;
		}
		else
		{
			imageWidth = w;
			imageHeight = h;
			imageX = 0;
			imageY = 0;
		}

		sharedMatrix.identity();
		sharedMatrix.scale(imageScaleX, imageScaleY);
		sharedMatrix.translate(scaledImageRect.x, scaledImageRect.y);
		g.beginBitmapFill(_bitmapData, sharedMatrix, false);
		g.drawRect(imageX, imageY, imageWidth, imageHeight);
		g.endFill();

		if (_showReflection)
		{
			//draw reflection
			var m1:Matrix = new Matrix;
			m1.scale(imageScaleX, -imageScaleY);
			m1.translate(0, scaledImageRect.height);
			var bitmap:BitmapData = new BitmapData(imageWidth, imageHeight, true, 0);
			bitmap.draw(_bitmapData, m1, null, BlendMode.LAYER);

			//apply fade-out gradient
			var sprite:Sprite = new Sprite();
			var m2:Matrix = new Matrix();
			m2.createGradientBox(imageWidth, imageHeight, Math.PI / 2, 0, 0);
			sprite.graphics.beginGradientFill(GradientType.LINEAR, [0, 0], [.3, 0], [0, 200], m2);
			sprite.graphics.drawRect(0, 0, bitmap.width, bitmap.height);
			bitmap.draw(sprite, null, null, BlendMode.ALPHA);

			if (!isNaN(_reflectionColor))
			{
				var bottomLayer:BitmapData = new BitmapData(imageWidth, imageHeight, false, _reflectionColor);
				bottomLayer.draw(bitmap);
				bitmap = bottomLayer;
			}

			var m3:Matrix = new Matrix;
			m3.translate(imageX, imageY + imageHeight);

			g.beginBitmapFill(bitmap, m3, false);
			g.drawRect(imageX, imageY + imageHeight, imageWidth, imageHeight);
			g.endFill();
		}
	}

	public function calculateImageFrame(bounds:Rectangle):Rectangle
	{
		if (_bitmapData == null)
		{
			return null;
		}

		if (_fillType == BitmapFillType.SCALE_TO_FIT || _fillType == BitmapFillType.IMAGE_PREVIEW )
		{
			if(_fillType == BitmapFillType.IMAGE_PREVIEW &&
					_bitmapData.rect.width <= bounds.width && _bitmapData.rect.height <= bounds.height)
			{
				imageFrame = _bitmapData.rect.clone();
			}
			else
			{
				imageFrame = RatioUtil.scaleToFit(_bitmapData.rect, bounds);
			}

			if (imageFrame.height < bounds.height && _verticalAlign != VerticalAlign.TOP)
			{
				if (_verticalAlign == VerticalAlign.MIDDLE)
				{
					imageFrame.y += (bounds.height - imageFrame.height) * 0.5;
				}
				else
				{
					imageFrame.y += (bounds.height - imageFrame.height);
				}
			}

			if (imageFrame.width < bounds.width && _horizontalAlign != HorizontalAlign.LEFT)
			{
				if (_horizontalAlign == HorizontalAlign.CENTER)
				{
					imageFrame.x += (bounds.width - imageFrame.width) * 0.5;
				}
				else
				{
					imageFrame.x += ( bounds.width - imageFrame.width);
				}
			}

		}
		else
		{
			imageFrame = RatioUtil.scaleToFill(_bitmapData.rect, bounds);

			if (imageFrame.height > bounds.height && _verticalAlign != VerticalAlign.TOP)
			{
				if (_verticalAlign == VerticalAlign.MIDDLE)
				{
					imageFrame.y -= (imageFrame.height - bounds.height) * .5;
				}
				else
				{
					imageFrame.y -= imageFrame.height - bounds.height
				}
			}
			else if (imageFrame.width > bounds.width && _horizontalAlign != HorizontalAlign.LEFT)
			{
				if (_horizontalAlign == HorizontalAlign.CENTER)
				{
					imageFrame.x -= (imageFrame.width - bounds.width) * .5;
				}
				else
				{
					imageFrame.x -= imageFrame.width - bounds.width;
				}
			}
		}

		return imageFrame;
	}
}
}