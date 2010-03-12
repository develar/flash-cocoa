package org.flyti.view
{
import com.asfusion.mate.core.EventMap;
import com.asfusion.mate.events.InjectorEvent;

import mx.core.ContainerCreationPolicy;
import mx.events.FlexEvent;

import spark.components.WindowedApplication;

[Frame(factoryClass='org.flyti.managers.SystemManager')]

[DefaultProperty("elements")]
public class WindowedApplication extends spark.components.WindowedApplication
{
	protected var maps:Vector.<EventMap>;

	private var mxmlContentCreated:Boolean = false;

	public function WindowedApplication()
	{
		super();

		initializeMaps();
		maps.fixed = true;
	}

	private var _deferredContentCreated:Boolean;
	override public function get deferredContentCreated():Boolean
    {
        return _deferredContentCreated;
    }

	private var _elements:Array;
	public function set elements(value:Array):void
	{
		_elements = value;
		if (contentGroup != null && creationPolicy != ContainerCreationPolicy.NONE)
		{
            createDeferredContent();
		}
	}

	override protected function childrenCreated():void
    {
		parent.dispatchEvent(new InjectorEvent(this));

		super.childrenCreated();
	}
	
	override protected function partAdded(partName:String, instance:Object):void
    {
		super.partAdded(partName, instance);

        if (instance == contentGroup && creationPolicy != ContainerCreationPolicy.NONE)
        {
			createDeferredContent();
		}
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