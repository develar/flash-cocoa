package cocoa
{
import cocoa.plaf.AbstractItemRenderer;
import cocoa.plaf.ListViewSkin;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;

import flash.display.DisplayObjectContainer;

import mx.core.IVisualElement;
import mx.core.mx_internal;

import spark.components.List;

use namespace mx_internal;

public class ListView extends List implements Viewable, Control
{
	private var skinClass:Class;

	protected var _action:Function;
	public function set action(value:Function):void
	{
		_action = value;
	}

	protected override function commitSelection(dispatchChangedEvents:Boolean = true):Boolean
	{
		var result:Boolean = super.commitSelection(dispatchChangedEvents);
		if (_action != null && result && dispatchChangedEvents)
		{
			_action();
		}

		return result;
	}

	private var laf:LookAndFeel;

	override protected function createChildren():void
	{
		// ImageView и не скин компонента, и не item renderer, так что пока что он сам ищет для себя LaF.
		var p:DisplayObjectContainer = parent;
		while (p != null)
		{
			if (p is LookAndFeelProvider)
			{
				laf = LookAndFeelProvider(p).laf;
				break;
			}
			else
			{
				if (p is Skin && Skin(p).component is LookAndFeelProvider)
				{
					laf = LookAndFeelProvider(Skin(p).component).laf;
					break;
				}
				else
				{
					p = p.parent;
				}
			}
		}

		skinClass = laf.getClass("ListView");
		super.createChildren();
	}

	public function get objectValue():Object
	{
		return selectedItem;
	}

	public function set objectValue(value:Object):void
	{
		selectedItem = value;
	}

	private var _verticalScrollbarPolicy:int = ScrollPolicy.AUTO;
	public function set verticalScrollbarPolicy(value:uint):void
	{
		_verticalScrollbarPolicy = value;
		if (skin != null)
		{
			ListViewSkin(skin).verticalScrollbarPolicy = _verticalScrollbarPolicy;
		}
	}

	private var _horizontalScrollbarPolicy:int = ScrollPolicy.AUTO;
	public function set horizontalScrollbarPolicy(value:uint):void
	{
		_horizontalScrollbarPolicy = value;
		if (skin != null)
		{
			ListViewSkin(skin).horizontalScrollbarPolicy = _horizontalScrollbarPolicy;
		}
	}

	public override function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void
	{
		if (renderer is AbstractItemRenderer)
		{
			AbstractItemRenderer(renderer).laf = laf;
		}

		super.updateRenderer(renderer, itemIndex, data);
	}

	// disable unwanted legacy
	include "../../unwantedLegacy.as";
	
	override public function getStyle(styleProp:String):*
	{
		if (styleProp == "skinClass")
		{
			return skinClass;
		}
		else if (styleProp == "layoutDirection")
		{
			return layoutDirection;
		}
		else
		{
			return undefined;
		}
	}

	override protected function attachSkin():void
	{
		super.attachSkin();

		ListViewSkin(skin).verticalScrollbarPolicy = _verticalScrollbarPolicy;
		ListViewSkin(skin).horizontalScrollbarPolicy = _horizontalScrollbarPolicy;
	}
}
}