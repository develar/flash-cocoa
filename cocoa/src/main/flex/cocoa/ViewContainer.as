package cocoa
{
public interface ViewContainer extends View
{
	function addSubview(view:Viewable, index:int = -1):void;
	function removeSubview(view:Viewable):void;

	function getSubviewIndex(view:Viewable):int;

	function getSubviewAt(index:int):View;

	function get numSubviews():int;

	function set measuredWidth(value:Number):void;
	function set measuredHeight(value:Number):void;
}
}