package cocoa.keyboard
{
internal class ClientBindabilityInfo
{
	public var eventMetadata:EventMetadata;
	public var states:Vector.<String>;

	public function ClientBindabilityInfo(eventMetadata:EventMetadata, states:Vector.<String>)
	{
		this.eventMetadata = eventMetadata;
		this.states = states;
	}
}
}