package cocoa.plaf
{
import cocoa.Border;
import cocoa.Component;
import cocoa.Icon;
import cocoa.LightUIComponent;
import cocoa.layout.LayoutMetrics;

import flash.display.DisplayObjectContainer;
import flash.text.engine.ElementFormat;

import mx.core.mx_internal;

use namespace mx_internal;

/**
 * Default base skin implementation for view
 */
public class AbstractSkin extends LightUIComponent implements Skin
{
	protected var laf:LookAndFeel;

	protected function getFont(key:String):ElementFormat
	{
		return laf.getFont(key);
	}

	protected function getBorder(key:String):Border
	{
		return laf.getBorder(_untypedComponent.stylePrefix + "." + key);
	}

	protected function getIcon(key:String):Icon
	{
		return laf.getIcon(_untypedComponent.stylePrefix + "." + key);
	}

	override protected function createChildren():void
	{
		if (untypedComponent is LookAndFeelProvider)
		{
			laf = LookAndFeelProvider(untypedComponent).laf;
		}
		else
		{
			var p:DisplayObjectContainer = parent;
			while (p != null)
			{
				if (p is LookAndFeelProvider)
				{
					laf = LookAndFeelProvider(p).laf;
					return;
				}
				else if (p is Skin && Skin(p).untypedComponent is LookAndFeelProvider)
				{
					laf = LookAndFeelProvider(Skin(p).untypedComponent).laf;
					return;
				}
				else
				{
					p = p.parent;
				}
			}

			throw new Error("laf not found");
		}
	}

	private var _untypedComponent:Component;
	public function get untypedComponent():Component
	{
		return _untypedComponent;
	}
	public function set untypedComponent(value:Component):void
	{
		_untypedComponent = value;
	}

	protected var _layoutMetrics:LayoutMetrics;
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
		untypedComponent.commitProperties();
		super.commitProperties();
	}
}
}