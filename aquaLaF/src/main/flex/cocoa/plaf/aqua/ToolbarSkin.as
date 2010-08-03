package cocoa.plaf.aqua
{
import cocoa.BorderedContainer;
import cocoa.plaf.basic.BoxSkin;

public class ToolbarSkin extends BoxSkin
{
	public function ToolbarSkin()
	{
		super();
		
		mouseEnabled = false;
	}

	override protected function createChildren():void
	{
		contentGroup = new BorderedContainer();

		super.createChildren();

		BorderedContainer(contentGroup).border = getBorder("border");
		contentGroup.mouseEnabled = false;
		contentGroup.laf = AquaLookAndFeel(laf).createWindowFrameLookAndFeel();
		component.uiPartAdded("contentGroup", contentGroup);

		if (contentGroup.layout == null)
		{
			var layout:BottomBarLayout = new BottomBarLayout();
			layout.padding = 10;
			layout.gap = 10;
			contentGroup.layout = layout;
		}

		addChild(contentGroup);
	}
}
}