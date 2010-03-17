package cocoa.resources
{
import flash.utils.Dictionary;

public class ResourceMetadata
{
	private static const instances:Dictionary = new Dictionary();

	public var resourceName:String;
	public var bundleName:String;
	public var parameters:Array;

	public function ResourceMetadata(resourceName:String = null, bundleName:String = null, parameters:Array = null):void
	{
		this.resourceName = resourceName;
		this.bundleName = bundleName;
		this.parameters = parameters;

		instances[resourceName + bundleName] = this;
	}

	public static function create(resourceName:String, bundleName:String):ResourceMetadata
	{
		var resource:ResourceMetadata = instances[resourceName + bundleName];
		return resource != null ? resource : new ResourceMetadata(resourceName, bundleName);
	}

	public function clone():ResourceMetadata
	{
		return new ResourceMetadata(resourceName, bundleName, parameters);
	}
}
}