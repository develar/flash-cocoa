package cocoa
{
import mx.core.ILayoutElement;
import mx.core.UIComponent;

import cocoa.layout.AdvancedLayout;

public class ViewStack extends LayoutlessContainer implements AdvancedLayout
{
	private var currentView:UIComponent;

	public function show(view:UIComponent):void
	{
		if (view.parent == null)
		{
			addSubview(Viewable(view));
		}

		view.visible = true;
		currentView = view;
	}

	public function hide():void
	{
		currentView.visible = false;
		currentView = null;
	}

	override protected function measure():void
	{
		measuredMinWidth = currentView.minWidth;
        measuredMinHeight = currentView.minHeight;
        measuredWidth = currentView.getExplicitOrMeasuredWidth();
        measuredHeight = currentView.getExplicitOrMeasuredHeight();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		currentView.setLayoutBoundsSize(w, h);
	}

	public function childCanSkipMeasurement(element:ILayoutElement):Boolean
	{
		return (!isNaN(explicitWidth) || !isNaN(percentWidth)) && (!isNaN(explicitHeight) || !isNaN(percentHeight));
	}
}
}