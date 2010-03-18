package cocoa
{
public interface ViewContainer extends View
{
	function addSubview(view:Viewable, index:int = -1):void;
	function removeSubview(view:Viewable):void;

	function getSubviewIndex(view:Viewable):int;
}
}