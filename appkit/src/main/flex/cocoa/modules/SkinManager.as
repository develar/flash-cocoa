package cocoa.modules
{
import cocoa.modules.events.LoadModuleEvent;
import cocoa.modules.loaders.StyleModuleLoader;

import mx.core.Singleton;
import mx.styles.IStyleManager2;

public class SkinManager extends ModuleManager
{
	override protected function get initialModuleLoadedEventType():String
	{
		return LoadModuleEvent.INITIAL_STYLE_LOADED;
	}

	override protected function get moduleLoadedEventType():String
	{
		return LoadModuleEvent.STYLE_LOADED;
	}

	override protected function get loadEventType():String
	{
		return LoadModuleEvent.LOAD_STYLE;
	}

	override protected function get requestParameterName():String
	{
		return "skin";
	}

	override protected function get applicationCategory():String
	{
		return ModuleCategory.APPLICATION_STYLE;
	}

	override public function load(module:ModuleInfo):void
	{
		startLoad(new StyleModuleLoader(IStyleManager2(Singleton.getInstance("mx.styles::IStyleManager2")), module, String(uri.get(module.category))));
	}

	override protected function unloadApplicationWideModule():void
	{
//		Application(FlexGlobals.topLevelApplication).styleManager.unloadStyleDeclarations(currentApplicationWideModule.uri, false);
	}
}
}