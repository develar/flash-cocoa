package cocoa
{
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;

import com.asfusion.mate.events.InjectorEvent;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import org.flyti.plexus.Injectable;

import spark.components.supportClasses.GroupBase;
import spark.components.supportClasses.SkinnableComponent;

public class LayoutlessContainer extends AbstractView implements ViewContainer, LookAndFeelProvider
{
	protected var _laf:LookAndFeel;
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

	public function addSubview(view:Viewable, index:int = -1):void
	{
		if (view is Component)
		{
			var component:Component = Component(view);
			addChildAt(DisplayObject(component.skin == null ? component.createView(laf) : component.skin), index == -1 ? numChildren : index);
		}
		else
		{
			if (view is Injectable || view is SkinnableComponent || (view is GroupBase && GroupBase(view).id != null))
			{
				dispatchEvent(new InjectorEvent(view));
			}

			addChildAt(DisplayObject(view), index == -1 ? numChildren : index);
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
}
}