package cocoa.pane
{
import mx.core.IFactory;
import mx.core.IVisualElement;

import cocoa.resources.ResourceMetadata;

public class PaneItem extends LabeledItem
{
	public var viewFactory:IFactory;

	public var view:IVisualElement;

	public function PaneItem(label:ResourceMetadata, viewFactory:IFactory)
	{
		super(label);
		
		this.viewFactory = viewFactory;
	}
}
}