package cocoa.plaf
{
import cocoa.Border;
import cocoa.Insets;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.utils.ByteArray;

import mx.core.UIComponent;

public final class Scale1HBitmapBorder extends AbstractControlBitmapBorder implements Border
{
	public static function create(bitmaps:Vector.<BitmapData>, layoutHeight:Number, contentInsets:Insets):Scale1HBitmapBorder
	{
		var border:Scale1HBitmapBorder = new Scale1HBitmapBorder();
		border.bitmaps = bitmaps;
		border._layoutHeight = layoutHeight;
		border._contentInsets = contentInsets;
		return border;
	}

	override public function draw(object:UIComponent, g:Graphics, w:Number, h:Number):void
	{
		sharedMatrix.tx = 0;
		sharedMatrix.ty = 0;

		g.beginBitmapFill(bitmaps[0], sharedMatrix, true);
		g.drawRect(0, 0, w, _layoutHeight);
		g.endFill();
	}

	override public function writeExternal(output:ByteArray):void
	{
		output.writeByte(1);

		super.writeExternal(output);
	}
}
}