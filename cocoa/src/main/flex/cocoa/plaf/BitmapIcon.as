package cocoa.plaf
{
import cocoa.Icon;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Matrix;
import flash.utils.ByteArray;

import mx.core.UIComponent;

public class BitmapIcon implements Icon, ExternalizableResource
{
	private static const sharedMatrix:Matrix = new Matrix();

	private var bitmapData:BitmapData;

	public static function create(bitmapData:BitmapData):BitmapIcon
	{
		var bitmapIcon:BitmapIcon = new BitmapIcon();
		bitmapIcon.bitmapData = bitmapData;
		return bitmapIcon;
	}

	public function get iconWidth():Number
	{
		return bitmapData.width;
	}

	public function get iconHeight():Number
	{
		return bitmapData.height;
	}

	public function draw(object:UIComponent, g:Graphics, x:Number, y:Number):void
	{
		sharedMatrix.tx = x;
		sharedMatrix.ty = y;
		g.beginBitmapFill(bitmapData, sharedMatrix, false);
		g.drawRect(x, y, iconWidth, iconHeight);
		g.endFill();
	}

	public function writeExternal(output:ByteArray):void
	{
		output.writeByte(bitmapData.width);
		output.writeByte(bitmapData.height);
		output.writeBytes(bitmapData.getPixels(bitmapData.rect));
	}

	public function readExternal(input:ByteArray):void
	{
		bitmapData = new BitmapData(input.readUnsignedByte(), input.readUnsignedByte(), true, 0);
		bitmapData.setPixels(bitmapData.rect, input);
	}
}
}