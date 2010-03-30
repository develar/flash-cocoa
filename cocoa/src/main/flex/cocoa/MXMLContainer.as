package cocoa
{
import cocoa.layout.AdvancedLayout;
import cocoa.layout.LayoutMetrics;
import cocoa.plaf.LookAndFeel;

import com.asfusion.mate.events.InjectorEvent;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.errors.IllegalOperationError;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;

import org.flyti.plexus.Injectable;

import spark.components.Group;
import spark.components.supportClasses.GroupBase;
import spark.components.supportClasses.SkinnableComponent;
import spark.layouts.BasicLayout;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

// компилятор flex не поддерживает массивы при генерации states
// и свойство обязано быть названо mxmlContent — AddItems

[DefaultProperty("mxmlContent")]
public class MXMLContainer extends Group implements ViewContainer
{
	protected var laf:LookAndFeel;
	
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
			view = component.skin == null ? component.createView(laf) : component.skin;
		}
		else if (view is Injectable || view is SkinnableComponent || (view is GroupBase && GroupBase(view).id != null))
		{
			dispatchEvent(new InjectorEvent(view));
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

	override public function addElementAt(element:IVisualElement, index:int):IVisualElement
    {
		assert(element != this);

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
			assert(host != this);
            // Remove the item from the group if that group isn't this group
            IVisualElementContainer(host).removeElement(element);
        }

		if (_subviews == null)
		{
			_subviews = [element];
		}
		else
		{
			_subviews.splice(index, 0, element);
		}

		if (!elementsChanged)
		{
			elementAdded(element, index);
		}

		return element;
	}

	override public function removeElementAt(index:int):IVisualElement
	{
		var element:IVisualElement = _subviews[index];
		if (!elementsChanged)
		{
			subviewRemoved(element, index);
		}

		_subviews.splice(index, 1);

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

	public function addSubview(view:Viewable, index:int = -1):void
	{
		if (index == -1)
		{
			index = numElements;
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
		return _subviews.indexOf(element);
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

	protected var _layoutMetrics:LayoutMetrics;

	// disable unwanted legacy
	override public function regenerateStyleCache(recursive:Boolean):void
	{

	}

	override public function styleChanged(styleProp:String):void
    {

	}

	override protected function resourcesChanged():void
    {

	}

	override public function get layoutDirection():String
    {
		return AbstractView.LAYOUT_DIRECTION_LTR;
	}

	override public function registerEffects(effects:Array /* of String */):void
    {

	}

	override mx_internal function initThemeColor():Boolean
    {
		return true;
	}

	override public function getConstraintValue(constraintName:String):*
    {
		if (_layoutMetrics == null)
		{
			return undefined;
		}
		else
		{
			var value:Number = _layoutMetrics[constraintName];
			return isNaN(value) ? undefined : value;
		}
	}

	override public function setConstraintValue(constraintName:String, value:*):void
    {
		if (_layoutMetrics == null)
		{
			_layoutMetrics = new LayoutMetrics();
		}

		_layoutMetrics[constraintName] = value;
	}

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