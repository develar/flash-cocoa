package cocoa.plaf
{
import cocoa.Component;
import cocoa.MXMLContainer;
import cocoa.layout.LayoutMetrics;

import com.asfusion.mate.events.InjectorEvent;

import flash.display.DisplayObject;

import mx.core.IStateClient;
import mx.core.mx_internal;

import org.flyti.plexus.Injectable;

use namespace mx_internal;

public class MXMLSkin extends MXMLContainer implements Skin, IStateClient
{
	protected var laf:LookAndFeel;
	
	private var _component:Component;
	public function get component():Component
	{
		return _component;
	}

	private var _layoutMetrics:LayoutMetrics;
	public function set layoutMetrics(value:LayoutMetrics):void
	{
		_layoutMetrics = value;
		if (!isNaN(_layoutMetrics.width))
		{
			explicitWidth = _layoutMetrics.width;
			_width = _layoutMetrics.width;
		}
		if (!isNaN(_layoutMetrics.height))
		{
			explicitHeight = _layoutMetrics.height;
			_height = _layoutMetrics.height;
		}
	}

	override public function get left():Object
	{
		return _layoutMetrics.left;
	}
	override public function set left(value:Object):void
	{
		_layoutMetrics.left = Number(value);
	}

	override public function get right():Object
	{
		return _layoutMetrics.right;
	}
	override public function set right(value:Object):void
	{
		_layoutMetrics.right = Number(value);
	}

	override public function get top():Object
	{
		return _layoutMetrics.top;
	}
	override public function set top(value:Object):void
	{
		_layoutMetrics.top = Number(value);
	}

	override public function get bottom():Object
	{
		return _layoutMetrics.bottom;
	}
	override public function set bottom(value:Object):void
	{
		_layoutMetrics.bottom = Number(value);
	}

	override public function get horizontalCenter():Object
	{
		return _layoutMetrics.horizontalCenter;
	}
	override public function set horizontalCenter(value:Object):void
	{
		_layoutMetrics.horizontalCenter = Number(value);
	}

	override public function get verticalCenter():Object
	{
		return _layoutMetrics.verticalCenter;
	}
	override public function set verticalCenter(value:Object):void
	{
		_layoutMetrics.verticalCenter = Number(value);
	}

	override public function get baseline():Object
	{
		return _layoutMetrics.baseline;
	}
	override public function set baseline(value:Object):void
	{
		_layoutMetrics.baseline = Number(value);
	}

	override public function get percentWidth():Number
    {
        return _layoutMetrics.percentWidth;
    }
	override public function set percentWidth(value:Number):void
    {
		_layoutMetrics.percentWidth = value;
		super.percentWidth = value;
	}

	override public function get percentHeight():Number
    {
        return _layoutMetrics.percentHeight;
    }
	override public function set percentHeight(value:Number):void
    {
		_layoutMetrics.percentHeight = value;
		super.percentHeight = value;
	}

	override protected function commitProperties():void
	{
		component.commitProperties();
		super.commitProperties();
	}

	override protected function createChildren():void
	{
		// Скин, в отличии от других элементов, также может содержать local event map — а контейнер с инжекторами мы находим посредством баблинга,
		// поэтому отослать InjectorEvent мы должны от самого скина и только после того, как он будет добавлен в display list.
		if (_component is Injectable)
		{
			dispatchEvent(new InjectorEvent(_component));
		}
	}

	public function attach(component:Component, laf:LookAndFeel):void
	{
		_component = component;
		this.laf = laf;
	}

	public final function addDisplayObject(displayObject:DisplayObject, index:int = -1):void
	{
		$addChildAt(displayObject, index == -1 ? numChildren : index);
	}

	public final function removeDisplayObject(value:DisplayObject):void
	{
		$removeChild(value);
	}
}
}