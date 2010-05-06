package cocoa
{
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;

import com.asfusion.mate.events.InjectorEvent;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import mx.core.ILayoutElement;

import org.flyti.plexus.Injectable;

import spark.components.supportClasses.GroupBase;
import spark.components.supportClasses.SkinnableComponent;

public class LayoutlessContainer extends AbstractView implements ViewContainer, LookAndFeelProvider
{
	private var _laf:LookAndFeel;
	public function get laf():LookAndFeel
	{
		return _laf;
	}
	public function set laf(value:LookAndFeel):void
	{
		_laf = value;
	}

	override protected function createChildren():void
	{
		if (_laf != null)
		{
			return;
		}

		var p:DisplayObjectContainer = parent;
		while (p != null)
		{
			if (p is LookAndFeelProvider)
			{
				_laf = LookAndFeelProvider(p).laf;
				return;
			}
			else
			{
				if (p is Skin && Skin(p).component is LookAndFeelProvider)
				{
					_laf = LookAndFeelProvider(Skin(p).component).laf;
					return;
				}
				else
				{
					p = p.parent;
				}
			}
		}

		throw new Error("laf not found");
	}

	public function addSubview(viewable:Viewable, index:int = -1):void
	{
		if (viewable is Component)
		{
			var component:Component = Component(viewable);
			addChildAt(DisplayObject(component.skin == null ? component.createView(laf) : component.skin), index == -1 ? numChildren : index);
		}
		else
		{
			if (viewable is Injectable || viewable is SkinnableComponent || (viewable is GroupBase && GroupBase(viewable).id != null))
			{
				dispatchEvent(new InjectorEvent(viewable));
			}

			addChildAt(DisplayObject(viewable), index == -1 ? numChildren : index);
		}
	}

	public function removeSubview(view:Viewable):void
	{
		removeChild(DisplayObject(view is Component ? Component(view).skin : view));
	}

	public function getSubviewIndex(view:Viewable):int
	{
		return getChildIndex(DisplayObject(view is Component ? Component(view).skin : view));
	}

	public function getSubviewAt(index:int):View
	{
		return View(getChildAt(index));
	}

	public function get numSubviews():int
	{
		return numChildren;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var n:int = numChildren;
		while (n-- > 0)
		{
			ILayoutElement(getChildAt(n)).setLayoutBoundsSize(w, h);
		}
	}
}
}