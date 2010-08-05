package cocoa.modules
{
import mx.utils.OnDemandEventDispatcher;

public class ModuleInfoImpl extends OnDemandEventDispatcher implements ModuleInfo
{
	public static const MODULE_EXTENSION:String = "swf";

	public function ModuleInfoImpl(id:ArtifactCoordinate)
	{
		_id = id;
	}

	private var _uri:String;
	[Transient]
	public function get uri():String
	{
		return _uri;
	}
	public function set uri(value:String):void
	{
		_uri = value;
	}

	private var _category:String;
	[Transient]
	public function get category():String
	{
		return _category;
	}
	public function set category(value:String):void
	{
		_category = value;
	}

	private var _id:ArtifactCoordinate;
	public function get id():ArtifactCoordinate
	{
		return _id;
	}
	
	private var _loaded:Boolean;
	[Transient]
	public function get loaded():Boolean
	{
		return _loaded;
	}
	public function set loaded(value:Boolean):void
	{
		_loaded = value;
	}
	
	private var _ready:Boolean;
	[Transient]
	public function get ready():Boolean
	{
		return _ready;
	}
	public function set ready(value:Boolean):void
	{
		_ready = value;
	}

	public function absolutizeURI(rootURI:String):void
	{
		uri = rootURI + "/" + id.id + "." + MODULE_EXTENSION;
	}

	public function equal(moduleInfo:ModuleInfo):Boolean
	{
		return id.equals(moduleInfo.id);
	}

	public function clone():ModuleInfo
	{
		var moduleInfo:ModuleInfoImpl = new ModuleInfoImpl(id.clone());
		moduleInfo.category = category;
		return moduleInfo;
	}
}
}