package cocoa
{
import mx.core.IVisualElement;

public interface ViewContainer
{
	function addElement(element:IVisualElement):IVisualElement;
	function removeElement(element:IVisualElement):IVisualElement;
}
}