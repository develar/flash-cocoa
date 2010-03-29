package cocoa.graphics
{
import cocoa.AbstractView;
import cocoa.Border;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;
import cocoa.util.RatioUtil;

import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
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

		var filledRect:Rectangle = calculateImageFrame(sharedRectangle);
		sharedMatrix.identity();
		sharedMatrix.scale(filledRect.width / _bitmapData.width, filledRect.height / _bitmapData.height);
		sharedMatrix.translate(filledRect.x, filledRect.y);
		g.beginBitmapFill(_bitmapData, sharedMatrix, false);

		var imageWidth:Number;
		var imageHeight:Number;
		var imageX:Number;
		var imageY:Number;
		if (_fillType == BitmapFillType.SCALE_TO_FIT)
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
		g.drawRect(imageX, imageY, imageWidth, imageHeight);
		g.endFill();
	}

	public function calculateImageFrame(bounds:Rectangle):Rectangle
	{
		imageFrame = new Rectangle();
		if (_fillType == BitmapFillType.SCALE_TO_FIT)
		{
			imageFrame = RatioUtil.scaleToFit(_bitmapData.rect, bounds);

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
			else if (imageFrame.width < bounds.width && _horizontalAlign != HorizontalAlign.LEFT)
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