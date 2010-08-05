package cocoa.modules
{
import flash.events.IEventDispatcher;

public interface ModuleInfo extends IEventDispatcher
{
	function get id():ArtifactCoordinate;

	function get category():String;
	function set category(value:String):void;

	function get uri():String;
	function set uri(value:String):void;

	/**
	 * Загружается или уже загружен — состояние готовности к использованию оценивайте по @see #ready
	 */
	function get loaded():Boolean;
	function set loaded(value:Boolean):void;

	function get ready():Boolean;
	function set ready(value:Boolean):void;
	
	function equal(module:ModuleInfo):Boolean;
	function absolutizeURI(rootURI:String):void

	function clone():ModuleInfo;
}
}