package cocoa.plaf
{
import cocoa.AbstractBorder;
import cocoa.View;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;

public class ImageReflectionBorder extends AbstractBorder
{
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

	private var _imageFrame:Rectangle;
	/**
	 * shareable — oneshot for draw
	 */
	public function set imageFrame(value:Rectangle):void
	{
		_imageFrame = value;
	}

	override public function draw(view:View, g:Graphics, w:Number, h:Number):void
	{
//		var m1:Matrix = new Matrix;
//		m1.scale(filledRect.width / _bitmapData.width, -filledRect.height / _bitmapData.height);
//		m1.translate(0, filledRect.height);
//		var bitmap:BitmapData = new BitmapData(imageWidth, imageHeight, true, 0);
//		var sprite:Sprite = new Sprite();
//		var alphas:Array = [.3, 0];
//		var ratios:Array = [0, 200];
//		var m2:Matrix = new Matrix();
//		m2.createGradientBox(imageWidth, imageHeight, Math.PI / 2, 0, 0);
//		sprite.graphics.beginGradientFill(GradientType.LINEAR, [0, 0], alphas, ratios, m2);
//		bitmap.draw(_bitmapData, m1, null, BlendMode.LAYER);
//		sprite.graphics.drawRect(0, 0, bitmap.width, bitmap.height);
//		bitmap.draw(sprite, null, null, BlendMode.ALPHA);
//
//		if (!isNaN(_reflectionColor))
//		{
//			var bottomLayer:BitmapData = new BitmapData(imageWidth, imageHeight, false, _reflectionColor);
//			bottomLayer.draw(bitmap);
//			bitmap = bottomLayer;
//		}
//
//		var m3:Matrix = new Matrix;
//		m3.translate(imageX, imageY + imageHeight);
//
//		g.beginBitmapFill(bitmap, m3, false);
//		g.drawRect(imageX, imageY + imageHeight, imageWidth, imageHeight);
//		g.endFill();
	}
}
}