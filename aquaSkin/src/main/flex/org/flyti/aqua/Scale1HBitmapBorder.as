package org.flyti.aqua
{
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.utils.IDataOutput;

import mx.core.UIComponent;

import org.flyti.view.AbstractItemRenderer;
import org.flyti.view.ListItemRendererBorder;
import org.flyti.view.TextInsets;

public final class Scale1HBitmapBorder extends AbstractControlBitmapBorder implements ListItemRendererBorder
{
	internal static function create(bitmaps:Vector.<BitmapData>, layoutHeight:Number, textInsets:TextInsets):Scale1HBitmapBorder
	{
		var border:Scale1HBitmapBorder = new Scale1HBitmapBorder();
		border.bitmaps = bitmaps;
		border._layoutHeight = layoutHeight;
		border._textInsets = textInsets;
		return border;
	}

	public function draw(object:UIComponent, g:Graphics, w:Number, h:Number, state:uint):void
	{
		sharedMatrix.tx = 0;
		sharedMatrix.ty = 0;

		g.beginBitmapFill(bitmaps[((state & AbstractItemRenderer.HOVERED) == 0) ? 0 : 1], sharedMatrix, true);
		g.drawRect(0, 0, w, _layoutHeight);
		g.endFill();

		// checkmarts, пока что значения забиты сюда.
		// В mac os x исходный image как-то вроде антиалиасится и инвертируется для голубого выделения (черный в белый), и, хотя мы можем получить исходный image,
		// нам пока что слишком неоправданно ислледовать данный вопрос глубоко и поэтому мы  просто вырезали битмапу из уже computed image.
		if (state & AbstractItemRenderer.SELECTED)
		{
			sharedMatrix.tx = 5;
			sharedMatrix.ty = 3;
			g.beginBitmapFill(bitmaps[((state & AbstractItemRenderer.HOVERED) == 0) ? 2 : 3], sharedMatrix, false);
			g.drawRect(sharedMatrix.tx, sharedMatrix.ty, 10, 10);
			g.endFill();
		}
	}

	override public function writeExternal(output:IDataOutput):void
	{
		output.writeByte(1);

		super.writeExternal(output);
	}
}
}