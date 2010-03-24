package cocoa
{
import cocoa.layout.LayoutMetrics;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;
import cocoa.resources.ResourceManager;

import flash.events.Event;

import mx.core.IFlexModule;
import mx.core.IFlexModuleFactory;
import mx.core.IMXMLObject;
import mx.core.IStateClient2;
import mx.core.IVisualElement;

use namespace ui;

public class AbstractComponent extends ComponentBase implements Component, IFlexModule, IMXMLObject
{
	// только как прокси
	private var layoutMetrics:LayoutMetrics = new LayoutMetrics();

	protected var resourceManager:ResourceManager;

	private var _skinClass:Class;
	public function set skinClass(value:Class):void
	{
		_skinClass = value;
	}

	private var _skin:Skin;
	public function get skin():Skin
	{
		return _skin;
	}

	protected var skinV:IVisualElement;

	protected function listenResourceChange():void
	{
		resourceManager = ResourceManager.instance;
		resourceManager.addEventListener(Event.CHANGE, resourceChangeHandler, false, 0, true);
	}

	protected function resourceChangeHandler(event:Event):void
	{
		resourcesChanged();
	}

	protected function resourcesChanged():void
    {

	}

	/* proxy for compiler */
	public function set left(value:Number):void
	{
		layoutMetrics.left = value;
	}

	public function set right(value:Number):void
	{
		layoutMetrics.right = value;
	}

	public function set top(value:Number):void
	{
		layoutMetrics.top = value;
	}

	public function set bottom(value:Number):void
	{
		layoutMetrics.bottom = value;
	}

	public function set horizontalCenter(value:Number):void
	{
		layoutMetrics.horizontalCenter = value;
	}

	public function set verticalCenter(value:Number):void
	{
		layoutMetrics.verticalCenter = value;
	}

	public function set baseline(value:Object):void
	{
		layoutMetrics.baseline = Number(value);
	}

	public function set percentWidth(value:Number):void
	{
		layoutMetrics.percentWidth = value;
	}

	public function set percentHeight(value:Number):void
	{
		layoutMetrics.percentHeight = value;
	}

	[PercentProxy("percentWidth")]
	public function set width(value:Number):void
	{
		layoutMetrics.width = value;
	}

	[PercentProxy("percentHeight")]
	public function set height(value:Number):void
	{
		layoutMetrics.height = value;
	}
	
	/* Component */
	public function createView(laf:LookAndFeel):Skin
	{
		if (_skinClass == null)
		{
			_skinClass = laf.getUI(lafPrefix);
		}
		_skin = new _skinClass();
		_skinClass = null;
		if (!_enabled)
		{
			_skin.enabled = false;
		}

		skinV = _skin;
		_skin.layoutMetrics = layoutMetrics;
		_skin.attach(this, laf);
		skinAttachedHandler();
		listenSkinParts(_skin);
		return _skin;
	}

	public function get lafPrefix():String
	{
		throw new Error("abstract");
	}

	protected function skinAttachedHandler():void
	{

	}

	public function commitProperties():void
	{
		if (skinStateIsDirty)
		{
			// This component must first be updated to the pending state as the skin inherits styles from this component.
			//noinspection UnnecessaryLocalVariableJS
			var pendingState:String = getCurrentSkinState();
			// stateChanged(skin.currentState, pendingState, false);
			IStateClient2(_skin).currentState = pendingState;
			skinStateIsDirty = false;
		}
	}

	private var skinStateIsDirty:Boolean = false;
	protected function invalidateSkinState():void
	{
		if (!skinStateIsDirty)
		{
			skinStateIsDirty = true;
			invalidateProperties();
		}
	}

	protected function getCurrentSkinState():String
    {
        return null;
    }

	protected var _enabled:Boolean = true;
	public function set enabled(value:Boolean):void
	{
		_enabled = value;
		if (_skin != null)
		{
			_skin.enabled = _enabled;
		}
	}

	/* IFlexModule */
	private var _moduleFactory:IFlexModuleFactory;
	public function get moduleFactory():IFlexModuleFactory
	{
		return _moduleFactory;
	}
	public function set moduleFactory(factory:IFlexModuleFactory):void
	{
		_moduleFactory = factory;
	}

	/* IID */
	private var _id:String;
	public function get id():String
	{
		return _id;
	}
	public function set id(value:String):void
	{
		_id = value;
	}

	public function initialized(document:Object, id:String):void
	{
		this.id = id;
	}
}
}