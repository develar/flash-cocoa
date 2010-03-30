package cocoa.plaf.aqua
{
import cocoa.Insets;

import mx.core.SpriteAsset;
import mx.core.mx_internal;

use namespace mx_internal;

public class TabViewSkin extends AbstractTabViewSkin
{
	[Embed(source="/GroupBox.png", scaleGridTop="7", scaleGridBottom="11", scaleGridLeft="7", scaleGridRight="13")]
	private static const contentBorderClass:Class;

	private static const CONTENT_INSETS:Insets = new Insets(16, 16 + 10, 16, 16);

	private var contentBorder:SpriteAsset;

	override protected function get contentInsets():Insets
	{
		return CONTENT_INSETS;
	}

	override protected function createChildren():void
	{
		super.createChildren();

		if (contentBorder == null)
		{
			contentBorder = new contentBorderClass();
			contentBorder.y = 10;
			contentBorder.mouseEnabled = false;
			addDisplayObject(contentBorder);
		}
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);
		
		contentBorder.width = w;
		contentBorder.height = h - contentBorder.y;
	}
}
}