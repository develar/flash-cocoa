package cocoa
{
import mx.core.IVisualElement;
import mx.styles.IAdvancedStyleClient;

public interface View extends IVisualElement, IAdvancedStyleClient
{
	function get skin():Skin;
	
	function createSkin():Skin;

	function commitProperties():void;
}
}