package cocoa
{
import com.asfusion.mate.core.EventMap;
import com.asfusion.mate.events.InjectorEvent;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.external.ExternalInterface;
import flash.system.Capabilities;
import flash.ui.ContextMenu;
import flash.utils.setInterval;

import mx.core.ContainerCreationPolicy;
import mx.core.FlexGlobals;
import mx.core.IFlexDisplayObject;
import mx.core.IInvalidating;
import mx.core.Singleton;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.FocusManager;
import mx.managers.IActiveWindowManager;
import mx.managers.IFocusManagerContainer;
import mx.managers.ILayoutManager;
import mx.managers.ISystemManager;
import mx.utils.LoaderUtil;

use namespace mx_internal;

[Frame(factoryClass='cocoa.SystemManager')]

[DefaultProperty("mxmlContent")]
public class ApplicationImpl extends LayoutlessContainer implements Application, IFocusManagerContainer
{
	public var frameRate:Number;
	public var pageTitle:String;
	public var preloader:Object;

	protected var maps:Vector.<EventMap>;

	private var resizeWidth:Boolean = true;
	private var resizeHeight:Boolean = true;
	private var synchronousResize:Boolean = false;

	private var resizeHandlerAdded:Boolean = false;
	private var percentBoundsChanged:Boolean;

	private var mxmlContentCreated:Boolean = false;

	public function ApplicationImpl()
	{
		UIComponentGlobals.layoutManager = ILayoutManager(Singleton.getInstance("mx.managers::ILayoutManager"));
		UIComponentGlobals.layoutManager.usePhasedInstantiation = true;

		if (FlexGlobals.topLevelApplication == null)
		{
			FlexGlobals.topLevelApplication = this;
		}

		showInAutomationHierarchy = true;

		var version:Array = Capabilities.version.split(' ')[1].split(',');
		synchronousResize = (parseFloat(version[0]) > 10 || (parseFloat(version[0]) == 10 && parseFloat(version[1]) >= 1)) && (Capabilities.playerType != "Desktop");

		initializeMaps();
		if (maps != null)
		{
			maps.fixed = true;
		}

		invalidateProperties();
	}

	private var _creationPolicy:String;
	public function get creationPolicy():String
	{
		return _creationPolicy;
	}
	public function set creationPolicy(value:String):void
	{
		_creationPolicy = value;
	}

	private var _deferredContentCreated:Boolean;
	public function get deferredContentCreated():Boolean
	{
		return _deferredContentCreated;
	}

	private var _mxmlContent:Vector.<Viewable>;
	public function set mxmlContent(value:Vector.<Viewable>):void
	{
		_mxmlContent = value;
		if (creationPolicy == ContainerCreationPolicy.ALL)
		{
			createDeferredContent();
		}
	}

	override protected function childrenCreated():void
	{
		systemManager.dispatchEvent(new InjectorEvent(this));

		super.childrenCreated();
	}

	override protected function createChildren():void
	{
		if (creationPolicy == ContainerCreationPolicy.ALL)
		{
			super.createChildren();
		}
	}

	public function createDeferredContent():void
	{
		if (mxmlContentCreated)
		{
			return;
		}

		if (creationPolicy == ContainerCreationPolicy.NONE)
		{
			super.createChildren();
		}

		if (_mxmlContent != null)
		{
			for each (var subview:Viewable in _mxmlContent)
			{
				addSubview(subview);
			}
			_mxmlContent = null;
		}

		mxmlContentCreated = true;
		_deferredContentCreated = true;
		dispatchEvent(new FlexEvent(FlexEvent.CONTENT_CREATION_COMPLETE));
	}

	protected function initializeMaps():void
	{

	}

	override public function get id():String
	{
		if (!super.id && this == FlexGlobals.topLevelApplication && ExternalInterface.available)
		{
			return ExternalInterface.objectID;
		}

		return super.id;
	}

	override public function set percentHeight(value:Number):void
	{
		if (value != super.percentHeight)
		{
			super.percentHeight = value;
			percentBoundsChanged = true;
			invalidateProperties();
		}
	}

	override public function set percentWidth(value:Number):void
	{
		if (value != super.percentWidth)
		{
			super.percentWidth = value;
			percentBoundsChanged = true;
			invalidateProperties();
		}
	}

	override public function set tabIndex(value:int):void
	{
	}

	override public function set toolTip(value:String):void
	{
	}

	mx_internal var _parameters:Object;

	/**
	 *  An Object containing name-value
	 *  pairs representing the parameters provided to this Application.
	 *
	 *  <p>You can use a for-in loop to extract all the names and values
	 *  from the parameters Object.</p>
	 *
	 *  <p>There are two sources of parameters: the query string of the
	 *  Application's URL, and the value of the FlashVars HTML parameter
	 *  (this affects only the main Application).</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get parameters():Object
	{
		return _parameters;
	}

	mx_internal var _url:String;

	/**
	 *  The URL from which this Application's SWF file was loaded
	 */
	public function get url():String
	{
		return _url;
	}

	override protected function invalidateParentSizeAndDisplayList():void
	{
		if (!includeInLayout)
		{
			return;
		}

		var p:IInvalidating = parent as IInvalidating;
		if (!p)
		{
			if (parent is ISystemManager)
			{
				ISystemManager(parent).invalidateParentSizeAndDisplayList();
			}

			return;
		}

		super.invalidateParentSizeAndDisplayList();
	}

	override public function initialize():void
	{
		var sm:ISystemManager = systemManager;

		_url = LoaderUtil.normalizeURL(sm.loaderInfo);
		_parameters = sm.loaderInfo.parameters;

		var focusManager:FocusManager = new FocusManager(this);
		var awm:IActiveWindowManager = IActiveWindowManager(systemManager.getImplementation("mx.managers::IActiveWindowManager"));
		awm == null ? focusManager.activate() : awm.activate(this);

		// Setup the default context menu here. This allows the application
		// developer to override it in the initialize event, if desired.
		initContextMenu();

		super.initialize();

		// Stick a timer here so that we will execute script every 1.5s
		// no matter what.
		// This is strictly for the debugger to be able to halt.
		// Note: isDebugger is true only with a Debugger Player.
		if (sm.isTopLevel() && Capabilities.isDebugger)
		{
			setInterval(debugTickler, 1500);
		}
	}

	/**
	 *  @private
	 */
	override protected function commitProperties():void
	{
		super.commitProperties();

		resizeWidth = isNaN(explicitWidth);
		resizeHeight = isNaN(explicitHeight);

		if (resizeWidth || resizeHeight)
		{
			resizeHandler(new Event(Event.RESIZE));

			if (!resizeHandlerAdded)
			{
				// weak reference
				systemManager.addEventListener(Event.RESIZE, resizeHandler, false, 0, true);
				resizeHandlerAdded = true;
			}
		}
		else if (resizeHandlerAdded)
		{
			systemManager.removeEventListener(Event.RESIZE, resizeHandler);
			resizeHandlerAdded = false;
		}

		if (percentBoundsChanged)
		{
			updateBounds();
			percentBoundsChanged = false;
		}
	}

	/**
	 *  This is here so we get the this pointer set to Application.
	 */
	private function debugTickler():void
	{
		// We need some bytes of code in order to have a place to break.
		//noinspection JSUnusedLocalSymbols
		var i:int = 0;
	}

	/**
	 *  @private
	 *  Disable all the built-in items except "Print...".
	 */
	private function initContextMenu():void
	{
		// context menu already set
		// nothing to init
		if (flexContextMenu != null)
		{
			// make sure we set it back on systemManager b/c it may have been overridden by now
			if (systemManager is InteractiveObject)
			{
				InteractiveObject(systemManager).contextMenu = contextMenu;
			}
			return;
		}

		var defaultMenu:ContextMenu = new ContextMenu();
		defaultMenu.hideBuiltInItems();
		defaultMenu.builtInItems.print = true;

		contextMenu = defaultMenu;

		if (systemManager is InteractiveObject)
		{
			InteractiveObject(systemManager).contextMenu = defaultMenu;
		}
	}

	/**
	 *  @private
	 *  Triggered by a resize event of the stage.
	 *  Sets the new width and height.
	 *  After the SystemManager performs its function,
	 *  it is only necessary to notify the children of the change.
	 */
	private function resizeHandler(event:Event):void
	{
		// If we're already due to update our bounds on the next
		// commitProperties pass, avoid the redundancy.
		if (!percentBoundsChanged)
		{
			updateBounds();

			// Update immediately when stage resizes so that we may appear
			// in synch with the stage rather than visually "catching up".
			if (synchronousResize)
				UIComponentGlobals.layoutManager.validateNow();
		}
	}

	private function updateBounds():void
	{
		// When user has not specified any width/height, application assumes the size of the stage.
		// If developer has specified width/height, the application will not resize.
		// If developer has specified percent width/height, application will resize to the required value
		// based on the current SystemManager's width/height.
		// If developer has specified min/max values, then application will not resize beyond those values.

		var w:Number;
		var h:Number;

		if (resizeWidth)
		{
			if (isNaN(percentWidth))
			{
				w = DisplayObject(systemManager).width;
			}
			else
			{
				super.percentWidth = Math.max(percentWidth, 0);
				super.percentWidth = Math.min(percentWidth, 100);
				w = percentWidth * DisplayObject(systemManager).width / 100;
			}

			if (!isNaN(explicitMaxWidth))
			{
				w = Math.min(w, explicitMaxWidth);
			}

			if (!isNaN(explicitMinWidth))
			{
				w = Math.max(w, explicitMinWidth);
			}
		}
		else
		{
			w = width;
		}

		if (resizeHeight)
		{
			if (isNaN(percentHeight))
			{
				h = DisplayObject(systemManager).height;
			}
			else
			{
				super.percentHeight = Math.max(percentHeight, 0);
				super.percentHeight = Math.min(percentHeight, 100);
				h = percentHeight * DisplayObject(systemManager).height / 100;
			}

			if (!isNaN(explicitMaxHeight))
				h = Math.min(h, explicitMaxHeight);

			if (!isNaN(explicitMinHeight))
				h = Math.max(h, explicitMinHeight);
		}
		else
		{
			h = height;
		}

		if (w != width || h != height)
		{
			invalidateProperties();
			invalidateSize();
		}

		setActualSize(w, h);

		invalidateDisplayList();
	}

	public function get defaultButton():IFlexDisplayObject
	{
		return null;
	}

	public function set defaultButton(value:IFlexDisplayObject):void
	{
	}
}
}