package cocoa
{
import cocoa.layout.AdvancedLayout;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;

import com.asfusion.mate.events.InjectorEvent;

import flash.display.DisplayObject;

import mx.core.FlexGlobals;
import mx.core.IFlexModule;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;

import org.flyti.plexus.Injectable;
import org.flyti.util.Assert;

import spark.components.supportClasses.GroupBase;
import spark.components.supportClasses.SkinnableComponent;
import spark.layouts.BasicLayout;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

// компилятор flex не поддерживает массивы при генерации states
// и свойство обязано быть названо mxmlContent — AddItems

[DefaultProperty("mxmlContent")]
public class Container extends GroupBase implements ViewContainer
{
	private var createChildrenCalled:Boolean;
	private var elementsChanged:Boolean;

	private var _elements:Array;
	public function set elements(value:Array):void
	{
		if (value == _elements)
		{
			return;
		}

		_elements = value;
		//_elements.fixed = _contentFixed;

		if (createChildrenCalled)
        {
            createElements();
        }
        else
        {
            elementsChanged = true;
        }
	}

	/**
	 * Если вектор элементов создается на лету по addElementAt, то он не фиксирован.
	 * Если вектор определен компилятором, то фиксирован. Но иногда нам хочется иметь смешанное — указать вектор элементов в MXML и потом еще добавить
	 */
	private var _contentFixed:Boolean = true;
	public function set fixedContent(value:Boolean):void
	{
		_contentFixed = value;
		if (_elements != null)
		{
			//_elements.fixed = _contentFixed;
		}
	}

	public function set mxmlContent(value:Array):void
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
		for (var i:int = 0, n:int = _elements.length; i < n; i++)
		{
			elementAdded(_elements[i], i);
		}
	}
	
	private function elementAdded(element:IVisualElement, index:int):void
    {
		if (element is Component)
		{
			var view:Component = Component(element);
			var skin:Skin = view.skin;
			if (skin == null)
			{
				skin = view.createView(LookAndFeelProvider(FlexGlobals.topLevelApplication).laf);
			}

			element = skin;
		}
		else if (element is Injectable || element is SkinnableComponent || (element is GroupBase && GroupBase(element).id != null))
		{
			dispatchEvent(new InjectorEvent(element));
		}

		if (layout)
		{
			layout.elementAdded(index);
		}

		if (element is IFlexModule && IFlexModule(element).moduleFactory == null)
		{
			if (moduleFactory != null)
			{
				IFlexModule(element).moduleFactory = moduleFactory;
			}
			else if (document is IFlexModule && document.moduleFactory != null)
			{
				IFlexModule(element).moduleFactory = document.moduleFactory;
			}
			else if (parent is IFlexModule && IFlexModule(element).moduleFactory != null)
			{
				IFlexModule(element).moduleFactory = IFlexModule(parent).moduleFactory;
			}
		}

		super.addChildAt(DisplayObject(element), index != -1 ? index : super.numChildren);

		invalidateSize();
        invalidateDisplayList();
	}

	/**
	 * Скин, в отличии от других элементов, также может содержать local event map — а контейнер с инжекторами мы находим посредством баблинга
	 *  — поэтому отослать InjectorEvent мы должны от самого скина и только после того, как он будет добавлен в display list.
	 */
	override mx_internal function childAdded(child:DisplayObject):void
    {
		if (child is Skin)
		{
			child.dispatchEvent(new InjectorEvent(Skin(child).untypedComponent));
		}

		super.childAdded(child);
	}

	override public function get numElements():int
    {
		return _elements == null ? 0 : _elements.length;
	}

	override public function getElementAt(index:int):IVisualElement
    {
		var element:IVisualElement = _elements[index];
		return element is Component ? Component(element).skin : element;
	}

	public function addElementAt(element:IVisualElement, index:int):IVisualElement
    {
		Assert.assert(element != this);

		var host:DisplayObject;
		if (element is Component)
		{
			var view:Component = Component(element);
			if (view.skin != null)
			{
				host = IVisualElement(view.skin).parent;
			}
		}
		else
		{
			host = element.parent;
		}

		if (host is IVisualElementContainer)
        {
			Assert.assert(host != this);
            // Remove the item from the group if that group isn't this group
            IVisualElementContainer(host).removeElement(element);
        }

		if (_elements == null)
		{
			_elements = [element];
		}
		else
		{
			_elements.splice(index, 0, element);
		}

		if (!elementsChanged)
		{
			elementAdded(element, index);
		}

		return element;
	}

	override public function getElementIndex(element:IVisualElement):int
    {
		return _elements.indexOf(element);
	}

	public function removeElementAt(index:int):IVisualElement
	{
		var element:IVisualElement = _elements[index];
		if (!elementsChanged)
		{
			super.removeChild(DisplayObject(element is Component ? Component(element).skin : element));

			invalidateSize();
			invalidateDisplayList();

			if (layout)
			{
				layout.elementRemoved(index);
			}
		}

		_elements.splice(index, 1);

		return element;
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

	public function addElement(element:IVisualElement):IVisualElement
	{
		return addElementAt(element, element.parent == this ? (numElements - 1) : numElements);
	}

	public function removeElement(element:IVisualElement):IVisualElement
	{
		return removeElementAt(getElementIndex(element));
	}
}
}