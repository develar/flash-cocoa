package cocoa.modules.loaders
{
import cocoa.plaf.LookAndFeelProvider;

import cocoa.modules.ModuleInfo;

import flash.events.Event;
import flash.system.ApplicationDomain;

import mx.core.FlexGlobals;
import mx.events.StyleEvent;
import mx.styles.IStyleManager2;

public class StyleModuleLoader extends FlexModuleLoader
{
	private var styleManager:IStyleManager2;

	public function StyleModuleLoader(styleManager:IStyleManager2, module:ModuleInfo, rootURI:String, applicationDomain:ApplicationDomain = null)
	{
		this.styleManager = styleManager;

		super(module, rootURI, applicationDomain == null ? new ApplicationDomain(ApplicationDomain.currentDomain) : applicationDomain);
	}

	override protected function get loadErrorMessage():String
	{
		return "errorLoadStyleModule";
	}

	override public function load():void
	{
		adjustURI();
		loadEventDispatcher = styleManager.loadStyleDeclarations2(_moduleInfo.uri, true, applicationDomain);
		loadEventDispatcher.addEventListener(StyleEvent.ERROR, loadErrorHandler);
		loadEventDispatcher.addEventListener(StyleEvent.COMPLETE, loadCompleteHandler);
	}

	override protected function clear(event:Event):void
	{
		loadEventDispatcher.removeEventListener(StyleEvent.ERROR, loadErrorHandler);
		loadEventDispatcher.removeEventListener(StyleEvent.COMPLETE, loadCompleteHandler);
		loadEventDispatcher = null;
	}

	override protected function loadCompleteHandler(event:Event):void
	{
		super.loadCompleteHandler(event);

		var lafClass:Class = Class(applicationDomain.getDefinition("cocoa.plaf.aqua.AquaLookAndFeel"));
		LookAndFeelProvider(FlexGlobals.topLevelApplication).laf = new lafClass();
	}
}
}