package org.flyti.aqua
{
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.utils.ByteArray;
import flash.utils.IDataOutput;

import mx.core.UIComponent;

import org.flyti.view.GroupBorder;
import org.flyti.view.Insets;
import org.flyti.view.LayoutInsets;

/**
 * Тот же трюк, что и в Scale3HBitmapBorder — отрисовка scale9Grid требует всего 4, а не 9 кусочков
 */
public final class Scale9BitmapBorder extends AbstractBorder implements GroupBorder
{
	private var rightSliceInnerWidth:int;
	private var bottomSliceInnerHeight:int;

	internal static function create(layoutInsets:LayoutInsets, contentInsets:Insets):Scale9BitmapBorder
	{
		var border:Scale9BitmapBorder = new Scale9BitmapBorder();
		border._layoutInsets = layoutInsets;
		border._contentInsets = contentInsets;
		return border;
	}

	private var _layoutInsets:LayoutInsets;
	public function get layoutInsets():LayoutInsets
	{
		return _layoutInsets;
	}

	private var _contentInsets:Insets;
	public function get contentInsets():Insets
	{
		return _contentInsets;
	}

	public function configure(bitmaps:Vector.<BitmapData>):void
	{
		this.bitmaps = bitmaps;

		rightSliceInnerWidth = bitmaps[1].width + _layoutInsets.right;
		bottomSliceInnerHeight = bitmaps[2].height + _layoutInsets.bottom;
	}

	public function draw(object:UIComponent, g:Graphics, w:Number, h:Number):void
	{
		sharedMatrix.tx = _layoutInsets.left;
		sharedMatrix.ty = _layoutInsets.top;

		const rightSliceX:Number = w - rightSliceInnerWidth;
		const bottomSliceY:Number = h - bottomSliceInnerHeight;

		const topAreaHeight:Number = bottomSliceY - _layoutInsets.top;
		const bottomAreaHeight:Number = bitmaps[2].height;
		const leftAreaWidth:Number = rightSliceX - _layoutInsets.left;
		const rightAreaWidth:Number = bitmaps[1].width;

		g.beginBitmapFill(bitmaps[0], sharedMatrix, false);
		g.drawRect(_layoutInsets.left, sharedMatrix.ty, leftAreaWidth, topAreaHeight);
		g.endFill();

		sharedMatrix.tx = rightSliceX;
		g.beginBitmapFill(bitmaps[1], sharedMatrix, false);
		g.drawRect(rightSliceX, sharedMatrix.ty, rightAreaWidth, topAreaHeight);
		g.endFill();

		sharedMatrix.ty = bottomSliceY;

		sharedMatrix.tx = _layoutInsets.left;
		g.beginBitmapFill(bitmaps[2], sharedMatrix, false);
		g.drawRect(_layoutInsets.left, bottomSliceY, leftAreaWidth, bottomAreaHeight);
		g.endFill();

		sharedMatrix.tx = rightSliceX;
		g.beginBitmapFill(bitmaps[3], sharedMatrix, false);
		g.drawRect(rightSliceX, bottomSliceY, rightAreaWidth, bottomAreaHeight);
		g.endFill();
	}

	override public function readExternal(input:ByteArray):void
	{
		super.readExternal(input);

		_contentInsets = readInsets(input);
		_layoutInsets = new LayoutInsets(input.readByte(), input.readByte(), input.readByte(), input.readByte());

		rightSliceInnerWidth = bitmaps[1].width + _layoutInsets.right;
		bottomSliceInnerHeight = bitmaps[2].height + _layoutInsets.bottom;
	}

	override public function writeExternal(output:IDataOutput):void
	{
		output.writeByte(2);

		super.writeExternal(output);

		writeInsets(output, _contentInsets);

		output.writeByte(_layoutInsets.left);
		output.writeByte(_layoutInsets.top);
		output.writeByte(_layoutInsets.right);
		output.writeByte(_layoutInsets.bottom);
	}
}
}