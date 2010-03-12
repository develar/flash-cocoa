package org.flyti.resources
{
import mx.resources.ResourceManagerImpl;

import org.flyti.core.ISingleton;
import org.flyti.core.Singleton;

public class ResourceManager extends ResourceManagerImpl implements ISingleton
{
	public function ResourceManager():void
	{
		Singleton.checkInstantiation(_instance);
		super();
	}

	private static var _instance:ResourceManager;
	public static function get instance():ResourceManager
	{
		if (_instance == null)
		{
			_instance = new ResourceManager();
		}

		return _instance;
	}

	[Deprecated]
	public static function getInstance():ResourceManager
	{
		return instance;
	}

	public function getNullableString(bundleName:String, resourceName:String):String
	{
		return super.getString(bundleName, resourceName);
	}

	override public function getString(bundleName:String, resourceName:String, parameters:Array = null, locale:String = null):String
	{
		var currentParameters:Array = parameters;
		if (currentParameters != null && currentParameters.length > 0)
		{
			for (var i:int = currentParameters.length - 1; i >= 0; i--)
			{
				if (currentParameters[i] is ResourceMetadata)
				{
					if (currentParameters == parameters)
					{
						currentParameters = parameters.slice();
					}
					currentParameters[i] = getStringByRM(currentParameters[i]);
				}
			}
		}
		var string:String = super.getString(bundleName, resourceName, currentParameters, locale);
		checkValue(string, resourceName, bundleName);
		return string;
	}

	[Bindable("change")]
	public function getStringByRM(resourceMetadata:ResourceMetadata):String
	{
		return getString(resourceMetadata.bundleName, resourceMetadata.resourceName, resourceMetadata.parameters);
	}

	override public function getClass(bundleName:String, resourceName:String, locale:String = null):Class
	{
		return findClass([bundleName], resourceName, locale);
	}

	private function checkValue(value:Object, resourceName:String, bundleName:String):void
	{
		if (value == null && localeChain.length > 0) // если localeChain пуст, значит еще не загружены языковые модули
		{
			const messageLocaleChain:String = "locale chain \"" + localeChain.join(", ") + '"';
			for each (var locale:String in localeChain)
			{
				if (getResourceBundle(locale, bundleName) != null)
				{
					throw new Error("Resource " + resourceName + " not found in " + bundleName + " and " + messageLocaleChain);
				}
			}

			throw new Error("Resource bundle " + bundleName + " not found in " + messageLocaleChain);
		}
	}

	public function findClass(bundleNames:Array, resourceName:String, locale:String = null):Class
	{
		for each (var bundleName:String in bundleNames)
		{
			var clazz:Class = super.getClass(bundleName, resourceName, locale);
			if (clazz != null)
			{
				break;
			}
		}
		checkValue(clazz, resourceName, bundleName);
		return clazz;
	}

	public function getStringWithDefault(bundleName:String, resourceName:String, defaultBundleName:String, defaultResourceName:String):String
	{
		var result:String = resourceName == null ? null : super.getString(bundleName, resourceName);
		if (result == null)
		{
			return getString(defaultBundleName, defaultResourceName);
		}
		else
		{
			return result;
		}
	}
}
}