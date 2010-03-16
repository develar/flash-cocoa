package cocoa
{
import cocoa.plaf.Skin;

import mx.core.IVisualElement;
import mx.styles.IAdvancedStyleClient;

public interface View extends IVisualElement, IAdvancedStyleClient
{
	function get skin():Skin;
	
	function createSkin():Skin;

	function uiPartAdded(id:String, instance:Object):void;
	
	function commitProperties():void;
}
}