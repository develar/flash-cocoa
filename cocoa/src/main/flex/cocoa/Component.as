package cocoa
{
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;

import flash.events.IEventDispatcher;

public interface Component extends Viewable, IEventDispatcher, UIPartController
{
	/**
	 * Префикс, используемый компонентом при составлении абсолютного ключа для получения некого стиля.
	 * В самом компоненте указывается путем переопределения геттера defaultLaFPrefix.
	 */
	function get lafKey():String;
	/**
	 * Если компонент используется как часть скина другого, то нам может потребоваться изменить его LaF,
	 * но не таким дорогим способом как создание дочернего LaF — поэтому для компонента laf prefix может быть указан явно (в этом случае defaultLaFPrefix не будет использоваться).
	 */
	function set lafKey(value:String):void

	function get skin():Skin;

	function set skinClass(value:Class):void;
	
	function set enabled(value:Boolean):void;

	function get hidden():Boolean;
	function set hidden(value:Boolean):void;
	
	function createView(laf:LookAndFeel):Skin;

	function commitProperties():void;
}
}