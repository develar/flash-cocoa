package cocoa
{
import cocoa.layout.AdvancedLayout;

import mx.core.ILayoutElement;

public class ViewStack extends LayoutlessContainer implements AdvancedLayout
{
	private var currentView:View;

	public function show(viewable:Viewable):void
	{
		if (currentView != null)
		{
			currentView.visible = false;
		}

		if (viewable is Component)
		{
			currentView = Component(viewable).skin;
			if (currentView == null)
			{
				addSubview(viewable);
				currentView = Component(viewable).skin;
			}
		}
		else
		{
			currentView = View(viewable);
			if (currentView.parent == null)
			{
				addSubview(viewable);
			}
		}

		currentView.visible = true;
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
		currentView.setActualSize(w, h);
	}

	public function childCanSkipMeasurement(element:ILayoutElement):Boolean
	{
		return (!isNaN(explicitWidth) || !isNaN(percentWidth)) && (!isNaN(explicitHeight) || !isNaN(percentHeight));
	}
}
}