package cocoa
{
import cocoa.layout.AdvancedLayout;
import cocoa.layout.LayoutMetrics;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;

import com.asfusion.mate.events.InjectorEvent;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import mx.core.IFlexDisplayObject;
import mx.core.IFlexModule;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;

import org.flyti.plexus.Injectable;

import spark.components.supportClasses.GroupBase;
import spark.components.supportClasses.SkinnableComponent;
import spark.layouts.BasicLayout;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

// компилятор flex не поддерживает массивы при генерации states
// и свойство обязано быть названо mxmlContent — AddItems

[DefaultProperty("mxmlContent")]
public class Container extends GroupBase implements ViewContainer, LookAndFeelProvider
{
	private var createChildrenCalled:Boolean;
	private var subviewsChanged:Boolean;

	public function Container()
	{
		super();

		mouseEnabledWhereTransparent = false;
	}

	private var _subviews:Array;
	public function set subviews(value:Array):void
	{
		if (value == _subviews)
		{
			return;
		}

		_subviews = value;

		if (createChildrenCalled)
        {
            createSubviews();
        }
        else
        {
            subviewsChanged = true;
        }
	}

	public function set mxmlContent(value:Array):void
    {
		subviews = value;
	}

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
		if (_laf == null)
		{
			var p:DisplayObjectContainer = parent;
			while (p != null)
			{
				if (p is LookAndFeelProvider)
				{
					_laf = LookAndFeelProvider(p).laf;
					break;
				}
				else if (p is Skin && Skin(p).component is LookAndFeelProvider)
				{
					_laf = LookAndFeelProvider(Skin(p).component).laf;
					break;
				}
				else
				{
					p = p.parent;
				}
			}
		}

		if (_laf == null)
		{
			throw new Error("laf not found");
		}

		if (layout == null)
		{
			layout = new BasicLayout();
		}

		createChildrenCalled = true;

		if (subviewsChanged)
		{
			subviewsChanged = false;
            createSubviews();
        }
	}

	private function createSubviews():void
	{
		for (var i:int = 0, n:int = _subviews.length; i < n; i++)
		{
			subviewAdded(_subviews[i], i);
		}
	}
	
	private function subviewAdded(view:Object, index:int):void
    {
		if (view is Component)
		{
			var component:Component = Component(view);
			view = component.skin == null ? component.createView(_laf) : component.skin;
		}
		else if (view is Injectable || view is SkinnableComponent || (view is GroupBase && GroupBase(view).id != null))
		{
			dispatchEvent(new InjectorEvent(view));
		}

		if (layout)
		{
			layout.elementAdded(index);
		}

		if (view is IFlexModule && IFlexModule(view).moduleFactory == null)
		{
			if (moduleFactory != null)
			{
				IFlexModule(view).moduleFactory = moduleFactory;
			}
			else if (document is IFlexModule && document.moduleFactory != null)
			{
				IFlexModule(view).moduleFactory = document.moduleFactory;
			}
			else if (parent is IFlexModule && IFlexModule(view).moduleFactory != null)
			{
				IFlexModule(view).moduleFactory = IFlexModule(parent).moduleFactory;
			}
		}

		super.addChildAt(DisplayObject(view), index != -1 ? index : super.numChildren);

		invalidateSize();
        invalidateDisplayList();
	}

	override public function get numElements():int
    {
		return _subviews == null ? 0 : _subviews.length;
	}

	override public function getElementAt(index:int):IVisualElement
    {
//		var element:Viewable = _subviews[index];
		var element:Object = _subviews[index];
		return IVisualElement(element is Component ? Component(element).skin : element);
	}

	override public function getElementIndex(element:IVisualElement):int
    {
		return _subviews.indexOf(element);
	}

	public function getSubviewIndex(view:Viewable):int
	{
		return _subviews.indexOf(view);
	}

	public function removeElementAt(index:int):IVisualElement
	{
		var element:Viewable = _subviews[index];
		if (element is Component)
		{
			element = Component(element).skin;
		}
		if (!subviewsChanged)
		{
			super.removeChild(DisplayObject(element));

			invalidateSize();
			invalidateDisplayList();

			if (layout)
			{
				layout.elementRemoved(index);
			}
		}

		_subviews.splice(index, 1);

		return IVisualElement(element);
	}

	public function addSubview(view:Viewable, index:int = -1):void
	{
		if (index == -1)
		{
			index = numElements;
		}

		var host:DisplayObject;
		if (view is Component)
		{
			var component:Component = Component(view);
			if (component.skin != null)
			{
				host = IFlexDisplayObject(component.skin).parent;
			}
		}
		else
		{
			host = IFlexDisplayObject(view).parent;
		}

		if (host is IVisualElementContainer)
        {
			assert(host != this);

            IVisualElementContainer(host).removeElement(IVisualElement(view));
        }
		else if (host is ViewContainer)
		{
			ViewContainer(host).removeSubview(view);
		}

		if (_subviews == null)
		{
			_subviews = [view];
			if (!createChildrenCalled)
			{
				subviewsChanged = true;
			}
		}
		else
		{
			_subviews.splice(index, 0, view);
		}

		if (!subviewsChanged)
		{
			subviewAdded(view, index);
		}
	}

	public function removeSubview(view:Viewable):void
	{
		removeElementAt(_subviews.indexOf(view));
	}

	override protected function canSkipMeasurement():Boolean
	{
		var advancedLayout:AdvancedLayout;
		if (parent is GroupBase)
		{
			var parentLayout:LayoutBase = GroupBase(parent).layout;
			if (parentLayout is AdvancedLayout)
			{
				advancedLayout = AdvancedLayout(parentLayout);
			}
		}
		else if (parent is AdvancedLayout)
		{
			advancedLayout = AdvancedLayout(parent);
		}

		if (advancedLayout != null && advancedLayout.childCanSkipMeasurement(this))
		{
			return true;
		}

		return super.canSkipMeasurement();
	}

	public final function addDisplayObject(displayObject:DisplayObject, index:int = -1):void
	{
		$addChildAt(displayObject, index == -1 ? numChildren : index);
	}

	public final function removeDisplayObject(child:DisplayObject):void
	{
		$removeChild(child);
	}

	public function getSubviewAt(index:int):View
	{
		return View(getElementAt(index));
	}

	private var layoutMetrics:LayoutMetrics;

	public function get numSubviews():int
	{
		return numElements;
	}

	// disable unwanted legacy
	include "../../unwantedLegacy.as";

	override public function getConstraintValue(constraintName:String):*
    {
		if (layoutMetrics == null)
		{
			return undefined;
		}
		else
		{
			var value:Number = layoutMetrics[constraintName];
			return isNaN(value) ? undefined : value;
		}
	}

	override public function setConstraintValue(constraintName:String, value:*):void
    {
		if (layoutMetrics == null)
		{
			layoutMetrics = new LayoutMetrics();
		}

		layoutMetrics[constraintName] = value;
	}

	override public function parentChanged(p:DisplayObjectContainer):void
	{
		super.parentChanged(p);

		if (p != null)
		{
			_parent = p; // так как наше AbstractView не есть ни IStyleClient, ни ISystemManager
		}
	}

//	override public function getStyle(styleProp:String):*
//	{
//		return super.getStyle(styleProp);
//	}
}
}