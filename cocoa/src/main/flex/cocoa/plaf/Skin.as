package cocoa.plaf
{
import cocoa.Component;

import mx.core.IStateClient;
import mx.managers.IToolTipManagerClient;
import mx.styles.ISimpleStyleClient;

import cocoa.layout.LayoutMetrics;

public interface Skin extends SimpleSkin, IStateClient, ISimpleStyleClient, IToolTipManagerClient
{
	function set layoutMetrics(value:LayoutMetrics):void;

	function get untypedComponent():Component;
	function set untypedComponent(value:Component):void;

	function set resourceBundle(value:String):void;
	function m(key:String):String;

	function setFocus():void;
}
}