package cocoa.plaf
{
import cocoa.Border;
import cocoa.Insets;
import cocoa.LayoutInsets;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.utils.ByteArray;

import mx.core.UIComponent;

import org.flyti.view.ButtonState;

/**
 * Фиксированная высота, произвольная ширина — масштабируется только по горизонтали.
 * Состоит из left, center и right кусочков bitmap — left и right как есть, а повторяется только center.
 * Реализовано как две bitmap, где 1 это склееный left и center — ширина center равна 1px — мы используем "the bitmap image does not repeat, and the edges of the bitmap are used for any fill area that extends beyond the bitmap"
 * (это позволяет нам сократить количество bitmapData, количество вызовов на отрисовку и в целом немного упростить код (в частности, для тех случаев, когда left width == 0)).
 */
public final class Scale3HBitmapBorder extends AbstractControlBitmapBorder implements Border
{
	private var sliceHeight:Number;
	private var sliceSizes:Insets;

	public static function create(layoutHeight:Number, layoutInsets:LayoutInsets, contentInsets:Insets):Scale3HBitmapBorder
	{
		var border:Scale3HBitmapBorder = new Scale3HBitmapBorder();
		border._layoutHeight = layoutHeight;
		border._layoutInsets = layoutInsets;
		border._contentInsets = contentInsets;
		return border;
	}

	private var _layoutInsets:LayoutInsets;
	public function get layoutInsets():LayoutInsets
	{
		return _layoutInsets;
	}

	public function configure(sliceSizes:Insets, sliceHeight:Number, bitmaps:Vector.<BitmapData>):void
	{
		this.sliceSizes = sliceSizes;
		this.sliceHeight = sliceHeight;
		this.bitmaps = bitmaps;

		sliceHeight = bitmaps[0].height;
	}

	public function draw(object:UIComponent, g:Graphics, w:Number, h:Number, state:ButtonState):void
	{
		sharedMatrix.tx = _layoutInsets.left;
		sharedMatrix.ty = _layoutInsets.top;

		var rightSliceX:Number = w - sliceSizes.right - _layoutInsets.right;
		g.beginBitmapFill(bitmaps[state.ordinal << 1], sharedMatrix, false);
		g.drawRect(sharedMatrix.tx, sharedMatrix.ty, rightSliceX - _layoutInsets.left, sliceHeight);
		g.endFill();

		sharedMatrix.tx = rightSliceX;
		g.beginBitmapFill(bitmaps[(state.ordinal << 1) + 1], sharedMatrix, false);
		g.drawRect(rightSliceX, sharedMatrix.ty, sliceSizes.right, sliceHeight);
		g.endFill();
	}

	override public function readExternal(input:ByteArray):void
	{
		super.readExternal(input);
		
		sliceSizes = readInsets(input);
		_layoutInsets = new LayoutInsets(input.readByte(), input.readByte(), input.readByte());

		sliceHeight = bitmaps[0].height;
	}

	override public function writeExternal(output:ByteArray):void
	{
		output.writeByte(0);
		super.writeExternal(output);
		writeInsets(output, sliceSizes);

		output.writeByte(_layoutInsets.left);
		output.writeByte(_layoutInsets.top);
		output.writeByte(_layoutInsets.right);
	}
}
}