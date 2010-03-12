package cocoa
{
import com.asfusion.mate.events.InjectorEvent;

import flash.display.DisplayObject;
import flash.errors.IllegalOperationError;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;

import org.flyti.layout.AdvancedLayout;
import org.flyti.plexus.Injectable;
import org.flyti.util.Assert;

import spark.components.Group;
import spark.components.supportClasses.GroupBase;
import spark.components.supportClasses.SkinnableComponent;
import spark.layouts.BasicLayout;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

// компилятор flex не поддерживает массивы при генерации states
// и свойство обязано быть названо mxmlContent — AddItems

[DefaultProperty("mxmlContent")]
public class Container extends Group implements ViewContainer
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
		for (var i:int = 0, n:int = _elements.length; i < n; i++)
		{
			elementAdded(_elements[i], i);
		}
	}

	override mx_internal function getMXMLContent():Array
    {
		throw new IllegalOperationError();
	}
	
	override mx_internal function elementAdded(element:IVisualElement, index:int, notifyListeners:Boolean = true):void
    {
		if (element is View)
		{
			var view:View = View(element);
			var skin:Skin = view.skin;
			if (skin == null)
			{
				skin = view.createSkin();
			}

			super.elementAdded(skin, index, notifyListeners);
		}
		else
		{
			if (element is Injectable || element is SkinnableComponent || (element is GroupBase && GroupBase(element).id != null))
			{
				dispatchEvent(new InjectorEvent(element));
			}

			super.elementAdded(element, index, notifyListeners);
		}
	}

	/**
	 * Скин, в отличии от других элементов, также может содержать local event map — а контейнер с инжекторами мы находим посредством баблинга
	 *  — поэтому отослать InjectorEvent мы должны от самого скина и только после того, как он будет добавлен в display list.
	 */
	override mx_internal function childAdded(child:DisplayObject):void
    {
		if (child is Skin)
		{
			child.dispatchEvent(new InjectorEvent(Skin(child).untypedHostComponent));
		}

		super.childAdded(child);
	}

	override mx_internal function elementRemoved(element:IVisualElement, index:int, notifyListeners:Boolean = true):void
    {
		if (element is View)
		{
			element = View(element).skin;
		}
		super.elementRemoved(element, index, notifyListeners);
	}

	override public function get numElements():int
    {
		return _elements == null ? 0 : _elements.length;
	}

	override public function getElementAt(index:int):IVisualElement
    {
		var element:IVisualElement = _elements[index];
		return element is View ? View(element).skin : element;
	}

	override public function addElementAt(element:IVisualElement, index:int):IVisualElement
    {
		Assert.assert(element != this);

		var host:DisplayObject;
		if (element is View)
		{
			var view:View = View(element);
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
		var index:int = _elements.indexOf(element);
		Assert.assert(index != -1);
		return index;
	}

	override public function removeElementAt(index:int):IVisualElement
	{
		var element:IVisualElement = _elements[index];
		if (!elementsChanged)
		{
			elementRemoved(element, index);
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
}
}