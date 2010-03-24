package cocoa.plaf
{
import cocoa.Border;
import cocoa.LabelHelper;

public class LabeledListItemRenderer extends AbstractItemRenderer
{
	protected var labelHelper:LabelHelper;
	protected var border:Border;

	public function LabeledListItemRenderer()
	{
		labelHelper = new LabelHelper(this);
		mouseChildren = false;
	}

	override public function get baselinePosition():Number
	{
		return border.layoutHeight - border.contentInsets.bottom;
	}

	override public function get label():String
	{
		return labelHelper.text;
	}

	override public function set label(value:String):void
	{
		if (value == labelHelper.text)
		{
			return;
		}

		labelHelper.text = value;

		invalidateSize();
		invalidateDisplayList();
	}

	override public function set laf(value:LookAndFeel):void
	{
		super.laf = value;
		labelHelper.font = getFont("SystemFont");
	}

	override protected function measure():void
	{
		measuredMinHeight = measuredHeight = border.layoutHeight;

		if (labelHelper.hasText)
		{
			labelHelper.validate();
			measuredMinWidth = measuredWidth = Math.round(labelHelper.textWidth) + border.contentInsets.width;
		}
		else
		{
			measuredMinWidth = measuredWidth = 0;
		}
	}
}
}