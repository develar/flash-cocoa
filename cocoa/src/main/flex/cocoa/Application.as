package cocoa
{
import com.asfusion.mate.core.EventMap;
import com.asfusion.mate.events.InjectorEvent;

import mx.core.ContainerCreationPolicy;
import mx.core.IFlexDisplayObject;
import mx.events.FlexEvent;

import org.flyti.view.Container;

import spark.components.Application;

[Frame(factoryClass='org.flyti.managers.SystemManager')]

[DefaultProperty("mxmlContent")]
public class Application extends spark.components.Application
{
	protected var maps:Vector.<EventMap>;

	private var mxmlContentCreated:Boolean = false;

	public function Application()
	{
		super();

		initializeMaps();
		if (maps != null)
		{
			maps.fixed = true;
		}
	}

	private var _deferredContentCreated:Boolean;
	override public function get deferredContentCreated():Boolean
    {
        return _deferredContentCreated;
    }

	private var _elements:Array;
	override public function set mxmlContent(value:Array):void
	{
		_elements = value;
		if (contentGroup != null && creationPolicy != ContainerCreationPolicy.NONE)
		{
            createDeferredContent();
		}
	}

	override protected function partAdded(partName:String, instance:Object):void
    {
		super.partAdded(partName, instance);

        if (instance == contentGroup && creationPolicy != ContainerCreationPolicy.NONE)
        {
			createDeferredContent();
		}
	}

	override protected function createChildren():void
	{
		super.createChildren();
	}

	override protected function childrenCreated():void
    {
		parent.dispatchEvent(new InjectorEvent(this));
		
		super.childrenCreated();
	}

	override public function prepareToPrint(target:IFlexDisplayObject):Object
	{
		return super.prepareToPrint(target);
	}

	override public function createDeferredContent():void
	{
		if (mxmlContentCreated)
		{
			return;
		}

		if (_elements != null)
		{
			Container(contentGroup).elements = _elements;
			_elements = null;
		}

		mxmlContentCreated = true;
		_deferredContentCreated = true;
		dispatchEvent(new FlexEvent(FlexEvent.CONTENT_CREATION_COMPLETE));
	}

	protected function initializeMaps():void
	{

	}
}
}