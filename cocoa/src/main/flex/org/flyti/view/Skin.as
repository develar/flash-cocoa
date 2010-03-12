package org.flyti.view
{
import mx.core.IStateClient;
import mx.managers.IToolTipManagerClient;
import mx.styles.ISimpleStyleClient;

import org.flyti.layout.LayoutMetrics;

public interface Skin extends SimpleSkin, IStateClient, ISimpleStyleClient, IToolTipManagerClient
{
	function set layoutMetrics(value:LayoutMetrics):void;

	function get untypedHostComponent():View;
	function set untypedHostComponent(value:View):void;

	function set resourceBundle(value:String):void;
	function m(key:String):String;

	function setFocus():void;
}
}