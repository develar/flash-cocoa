package cocoa
{
import cocoa.layout.AdvancedLayout;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelClient;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;

import com.asfusion.mate.events.InjectorEvent;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;

import org.flyti.plexus.Injectable;

import spark.components.Group;
import spark.components.supportClasses.GroupBase;
import spark.layouts.BasicLayout;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

// компилятор flex не поддерживает массивы при генерации states
// и свойство обязано быть названо mxmlContent — AddItems

[DefaultProperty("mxmlContent")]
public class MXMLContainer extends Group implements ViewContainer, LookAndFeelProvider
{
	protected var _laf:LookAndFeel;
	public function get laf():LookAndFeel
	{
		return _laf;
	}
	public function set $laf(value:LookAndFeel):void
	{
		_laf = value;
	}
	
	private var createChildrenCalled:Boolean;
	private var elementsChanged:Boolean;

	public function MXMLContainer()
	{
		super();
		
		mouseEnabledWhereTransparent = false;
	}

	private var _subviews:Array;
	public function set elements(value:Array):void
	{
		if (value == _subviews)
		{
			return;
		}

		_subviews = value;

		if (createChildrenCalled)
        {
            createElements();
        }
        else
        {
            elementsChanged = true;
        }
	}

	override public function set mxmlContent(value:Array):void
    {
		elements = value;
	}

	override protected function createChildren():void
	{
		if (layout == null)
		{
			layout = new BasicLayout();
		}

		createChildrenCalled = true;

		if (elementsChanged)
		{
			elementsChanged = false;
            createElements();
        }
	}

	private function createElements():void
	{
		for (var i:int = 0, n:int = _subviews.length; i < n; i++)
		{
			subviewAdded(_subviews[i], i);
		}
	}

	override mx_internal function getMXMLContent():Array
    {
		throw new IllegalOperationError();
	}

	private function subviewAdded(view:Object, index:int):void
    {
		if (view is Component)
		{
			var component:Component = Component(view);
			view = component.skin == null ? component.createView(_laf) : component.skin;
		}
		else if (view is Injectable || (view is GroupBase && GroupBase(view).id != null))
		{
			dispatchEvent(new InjectorEvent(view));
		}

		if (view is LookAndFeelClient)
		{
			LookAndFeelClient(view).$laf = laf;
		}

		elementAdded(IVisualElement(view), index, false);
	}

	private function subviewRemoved(element:Object, index:int):void
	{
		elementRemoved(IVisualElement(element is Component ? Component(element).skin : element), index, false);
	}

	override public function get numElements():int
    {
		return _subviews == null ? 0 : _subviews.length;
	}

	override public function getElementAt(index:int):IVisualElement
    {
		var element:Object = _subviews[index];
		return IVisualElement(element is Component ? Component(element).skin : element);
	}

	override public function removeElementAt(index:int):IVisualElement
	{
		var element:Viewable = _subviews[index];
		if (!elementsChanged)
		{
			subviewRemoved(element, index);
		}

		_subviews.splice(index, 1);

		return element as IVisualElement;
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

	override public function addElementAt(view:IVisualElement, index:int):IVisualElement
    {
		addFlexOrCocoaView(view, index);
		return view;
	}

	public function addSubview(view:Viewable, index:int = -1):void
	{
		addFlexOrCocoaView(view, index);
	}

	private function addFlexOrCocoaView(view:Object, index:int = -1):void
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
				host = IVisualElement(component.skin).parent;
			}
		}
		else
		{
			host = IVisualElement(view).parent;
		}

		if (host is IVisualElementContainer)
        {
			assert(host != this);

            IVisualElementContainer(host).removeElement(IVisualElement(view));
        }
		else if (host is ViewContainer)
		{
			ViewContainer(host).removeSubview(Viewable(view));
		}

		if (_subviews == null)
		{
			_subviews = [view];
		}
		else
		{
			_subviews.splice(index, 0, view);
		}

		if (!elementsChanged)
		{
			subviewAdded(view, index);
		}

		subviewAdded(view, index);
	}

	public function removeSubview(view:Viewable):void
	{
		removeElementAt(_subviews.indexOf(view));
	}

	public function getSubviewIndex(view:Viewable):int
	{
		return _subviews.indexOf(view);
	}

	override public function getElementIndex(element:IVisualElement):int
    {
		var index:int = _subviews.indexOf(element is Skin ? Skin(element).component : element);
		assert(index != -1);
		return index;
	}

	public final function addDisplayObject(displayObject:DisplayObject, index:int = -1):void
	{
		$addChildAt(displayObject, index == -1 ? numChildren : index);
	}

	public final function removeDisplayObject(displayObject:DisplayObject):void
	{
		$removeChild(displayObject);
	}

	public function getSubviewAt(index:int):View
	{
		return View(getElementAt(index));
	}

	public function get numSubviews():int
	{
		return numElements;
	}

	// disable unwanted legacy
	include "../../unwantedLegacy.as";
	include "../../legacyConstraints.as";

	override public function parentChanged(p:DisplayObjectContainer):void
	{
		super.parentChanged(p);

		if (p != null)
		{
			_parent = p; // так как наше AbstractView не есть ни IStyleClient, ни ISystemManager
		}
	}
}
}