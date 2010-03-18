package cocoa
{
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;

import com.asfusion.mate.events.InjectorEvent;

import flash.display.DisplayObject;

import mx.core.FlexGlobals;
import mx.core.IVisualElement;
import mx.core.mx_internal;

import org.flyti.plexus.Injectable;

import spark.components.supportClasses.GroupBase;
import spark.components.supportClasses.SkinnableComponent;

use namespace mx_internal;

public class LightContainer extends LightUIComponent implements ViewContainer
{
	public function addElement(element:IVisualElement):IVisualElement
	{
		if (element is Component)
		{
			var view:Component = Component(element);
			var skin:Skin = view.skin;
			if (skin == null)
			{
				skin = view.createView(LookAndFeelProvider(FlexGlobals.topLevelApplication).laf);
			}

			addChild(DisplayObject(skin));
		}
		else
		{
			if (element is Injectable || element is SkinnableComponent || (element is GroupBase && GroupBase(element).id != null))
			{
				dispatchEvent(new InjectorEvent(element));
			}

			addChild(DisplayObject(element));
		}

		return element;
	}

	override mx_internal function childAdded(child:DisplayObject):void
    {
		if (child is Skin)
		{
			child.dispatchEvent(new InjectorEvent(Skin(child).untypedComponent));
		}

		super.childAdded(child);
	}

	public function removeElement(element:IVisualElement):IVisualElement
	{
		if (element is Component)
		{
			element = Component(element).skin;
		}

		removeChild(DisplayObject(element));

		return element;
	}
}
}