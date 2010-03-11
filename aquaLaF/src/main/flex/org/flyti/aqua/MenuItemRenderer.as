package org.flyti.aqua
{
import cocoa.Icon;
import cocoa.LabelHelper;
import cocoa.plaf.AbstractItemRenderer;
import cocoa.plaf.MenuItemRenderer;
import cocoa.plaf.Scale1HBitmapBorder;

public class MenuItemRenderer extends cocoa.plaf.MenuItemRenderer
{
	private var stateIcon:Icon;

	public function MenuItemRenderer()
	{
		labelHelper = new LabelHelper(this, AquaFonts.SYSTEM_FONT);

		addRollHandlers();
	}

	override public function set data(value:Object):void
	{
		super.data = value;

		if (menuItem.isSeparatorItem)
		{
			border = AquaBorderFactory.separatorMenuItemBorder;
		}
		else
		{
			border = AquaBorderFactory.menuItemBorder;
		}
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		Scale1HBitmapBorder(border) = ((state & AbstractItemRenderer.HOVERED) == 0) ? 0 : 1;
		labelHelper.font = ((state & HOVERED) == 0) ? AquaFonts.SYSTEM_FONT : AquaFonts.SYSTEM_FONT_WHITE;

		super.updateDisplayList(w, h);

		// checkmarks, пока что значения забиты сюда.
		// В mac os x исходный image как-то вроде антиалиасится и инвертируется для голубого выделения (черный в белый), и, хотя мы можем получить исходный image,
		// нам пока что слишком неоправданно ислледовать данный вопрос глубоко и поэтому мы просто вырезали битмапу из уже computed image.
		stateIcon = AquaBorderFactory.getMenuItemStateIcon((state & AbstractItemRenderer.HOVERED) != 0);
		stateIcon.draw(this, graphics, 5, 3);
	}
}
}