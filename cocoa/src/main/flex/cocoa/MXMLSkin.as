package cocoa
{
import org.flyti.view.*;

import mx.core.mx_internal;
import mx.styles.IAdvancedStyleClient;

import org.flyti.layout.LayoutMetrics;

use namespace mx_internal;

public class MXMLSkin extends Container implements Skin
{
	private var _untypedHostComponent:View;
	public function get untypedHostComponent():View
	{
		return _untypedHostComponent;
	}
	public function set untypedHostComponent(value:View):void
	{
		_untypedHostComponent = value;
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
		untypedHostComponent.commitProperties();
		super.commitProperties();
	}

	override public function get styleParent():IAdvancedStyleClient
	{
		return untypedHostComponent;
	}
}
}