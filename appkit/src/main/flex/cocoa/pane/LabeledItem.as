package cocoa.pane
{
import cocoa.resources.ResourceMetadata;

[Abstract]
public class LabeledItem
{
	public var label:ResourceMetadata;
	[Transient]
	public var localizedLabel:String;

	public function LabeledItem(label:ResourceMetadata)
	{
		this.label = label;
	}

	public function toString():String
	{
		return localizedLabel;
	}
}
}