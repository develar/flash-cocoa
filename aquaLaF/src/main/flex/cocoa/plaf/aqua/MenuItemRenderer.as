package cocoa.plaf.aqua
{
import cocoa.plaf.basic.MenuItemRenderer;

internal class MenuItemRenderer extends cocoa.plaf.basic.MenuItemRenderer
{
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		// checkmarks, пока что значения забиты сюда.
		// В mac os x исходный image как-то вроде антиалиасится и инвертируется для голубого выделения (черный в белый), и, хотя мы можем получить исходный image,
		// нам пока что слишком неоправданно исcледовать данный вопрос глубоко и поэтому мы просто вырезали битмапу из уже computed image.
		if (selected)
		{
			getIcon(((state & HIGHLIGHTED) != 0) ? "onStateIcon.highlighted" : "onStateIcon").draw(this, graphics, 5, 3);
		}
	}
}
}