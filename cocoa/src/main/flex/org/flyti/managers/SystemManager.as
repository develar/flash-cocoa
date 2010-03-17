package org.flyti.managers
{
import mx.core.Singleton;
import mx.core.mx_internal;
import mx.managers.SystemManager;

use namespace mx_internal;

public class SystemManager extends mx.managers.SystemManager
{
	protected function registerSingletons():void
	{
		Singleton.registerClass("mx.resources::IResourceManager", Class(getDefinitionByName("cocoa.resources::ResourceManager")));
		Singleton.registerClass("mx.managers::IBrowserManager", Class(getDefinitionByName("org.flyti.flyf.managers.browserManager::BrowserManager")));
	}

	override mx_internal function kickOff():void
	{
		if (document != null)
		{
			return;
		}

		registerSingletons();

		super.kickOff();
	}
}
}