package cocoa.plaf.basic
{
import cocoa.LabelHelper;
import cocoa.plaf.FontID;
import cocoa.plaf.TitledComponentSkin;

public class TitledComponentSkin extends AbstractSkin implements cocoa.plaf.TitledComponentSkin
{
	protected var labelHelper:LabelHelper;

	protected function get titleFontId():String
	{
		return FontID.SYSTEM;
	}

	public function set title(value:String):void
	{
		if (labelHelper == null)
		{
			if (value == null)
			{
				return;
			}

			labelHelper = new LabelHelper(this, laf == null ? null : getFont(titleFontId));
		}
		else if (value == labelHelper.text)
		{
			return;
		}

		labelHelper.text = value;

		invalidateSize();
		invalidateDisplayList();
	}

	override protected function createChildren():void
	{
		super.createChildren();

		if (labelHelper != null)
		{
			labelHelper.font = getFont(FontID.SYSTEM);
		}
	}
}
}