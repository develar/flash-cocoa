package cocoa
{
import flash.display.DisplayObjectContainer;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.utils.getDefinitionByName;

import mx.core.DesignLayer;
import mx.core.IFlexModule;
import mx.core.IFlexModuleFactory;
import mx.core.IMXMLObject;
import mx.core.IVisualElement;
import mx.geom.TransformOffsets;
import mx.styles.CSSStyleDeclaration;
import mx.styles.IAdvancedStyleClient;
import mx.styles.StyleProtoChain;

import org.flyti.layout.LayoutMetrics;
import org.flyti.resources.ResourceManager;
import org.flyti.view;
import org.flyti.view.*;

use namespace ui;

[Exclude(kind="property", name="parent")]

[Style(name="skinClass", type="Class")]
public class AbstractView extends ViewBase implements View, IAdvancedStyleClient, IFlexModule, IMXMLObject
{
	// только как прокси
	private var layoutMetrics:LayoutMetrics = new LayoutMetrics();

	protected var resourceManager:ResourceManager;

	private var _skinClass:Class;

	private var _skin:Skin;
	public function get skin():Skin
	{
		return _skin;
	}

	protected var skinV:IVisualElement;

	protected function listenResourceChange():void
	{
		resourceManager = ResourceManager.instance;
		resourceManager.addEventListener(Event.CHANGE, resourceChangeHandler, false, 0, true);
	}

	protected function resourceChangeHandler(event:Event):void
	{
		resourcesChanged();
	}

	protected function resourcesChanged():void
    {

	}

	/* ILayoutElement */
	public function get left():Object
	{
		return layoutMetrics.left;
	}
	public function set left(value:Object):void
	{
		layoutMetrics.left = Number(value);
	}

	public function get right():Object
	{
		return layoutMetrics.right;
	}
	public function set right(value:Object):void
	{
		layoutMetrics.right = Number(value);
	}

	public function get top():Object
	{
		return layoutMetrics.top;
	}
	public function set top(value:Object):void
	{
		layoutMetrics.top = Number(value);
	}

	public function get bottom():Object
	{
		return layoutMetrics.bottom;
	}
	public function set bottom(value:Object):void
	{
		layoutMetrics.bottom = Number(value);
	}

	public function get horizontalCenter():Object
	{
		return layoutMetrics.horizontalCenter;
	}
	public function set horizontalCenter(value:Object):void
	{
		layoutMetrics.horizontalCenter = Number(value);
	}

	public function get verticalCenter():Object
	{
		throw new IllegalOperationError();
	}
	public function set verticalCenter(value:Object):void
	{
		layoutMetrics.verticalCenter = Number(value);
	}

	public function get baseline():Object
	{
		throw new IllegalOperationError();
	}
	public function set baseline(value:Object):void
	{
		layoutMetrics.baseline = Number(value);
	}

	public function get baselinePosition():Number
	{
		throw new IllegalOperationError();
	}

	public function get percentWidth():Number
	{
		throw new IllegalOperationError();
	}
	public function set percentWidth(value:Number):void
	{
		layoutMetrics.percentWidth = value;
	}

	public function get percentHeight():Number
	{
		throw new IllegalOperationError();
	}
	public function set percentHeight(value:Number):void
	{
		layoutMetrics.percentHeight = value;
	}

	public function get includeInLayout():Boolean
	{
		throw new IllegalOperationError();
	}
	public function set includeInLayout(value:Boolean):void
	{
		throw new IllegalOperationError();
	}

	public function getPreferredBoundsWidth(postLayoutTransform:Boolean = true):Number
	{
		throw new IllegalOperationError();
	}

	public function getPreferredBoundsHeight(postLayoutTransform:Boolean = true):Number
	{
		throw new IllegalOperationError();
	}

	public function getMinBoundsWidth(postLayoutTransform:Boolean = true):Number
	{
		throw new IllegalOperationError();
	}

	public function getMinBoundsHeight(postLayoutTransform:Boolean = true):Number
	{
		throw new IllegalOperationError();
	}

	public function getMaxBoundsWidth(postLayoutTransform:Boolean = true):Number
	{
		throw new IllegalOperationError();
	}

	public function getMaxBoundsHeight(postLayoutTransform:Boolean = true):Number
	{
		throw new IllegalOperationError();
	}

	public function getBoundsXAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
	{
		throw new IllegalOperationError();
	}

	public function getBoundsYAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
	{
		throw new IllegalOperationError();
	}

	public function getLayoutBoundsWidth(postLayoutTransform:Boolean = true):Number
	{
		throw new IllegalOperationError();
	}

	public function getLayoutBoundsHeight(postLayoutTransform:Boolean = true):Number
	{
		throw new IllegalOperationError();
	}

	public function getLayoutBoundsX(postLayoutTransform:Boolean = true):Number
	{
		throw new IllegalOperationError();
	}

	public function getLayoutBoundsY(postLayoutTransform:Boolean = true):Number
	{
		throw new IllegalOperationError();
	}

	public function setLayoutBoundsPosition(x:Number, y:Number, postLayoutTransform:Boolean = true):void
	{
		throw new IllegalOperationError();
	}

	public function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean = true):void
	{
		throw new IllegalOperationError();
	}

	public function getLayoutMatrix():Matrix
	{
		throw new IllegalOperationError();
	}
	public function setLayoutMatrix(value:Matrix, invalidateLayout:Boolean):void
	{
		throw new IllegalOperationError();
	}

	public function get hasLayoutMatrix3D():Boolean
	{
		throw new IllegalOperationError();
	}

	public function getLayoutMatrix3D():Matrix3D
	{
		throw new IllegalOperationError();
	}
	public function setLayoutMatrix3D(value:Matrix3D, invalidateLayout:Boolean):void
	{
		throw new IllegalOperationError();
	}

	public function transformAround(transformCenter:Vector3D, scale:Vector3D = null, rotation:Vector3D = null, translation:Vector3D = null,
									postLayoutScale:Vector3D = null, postLayoutRotation:Vector3D = null, postLayoutTranslation:Vector3D = null,
									invalidateLayout:Boolean = true):void
	{
		throw new IllegalOperationError();
	}

	public function get owner():DisplayObjectContainer
	{
		throw new IllegalOperationError();
	}
	public function set owner(value:DisplayObjectContainer):void
	{
		throw new IllegalOperationError();
	}

	public function get parent():DisplayObjectContainer
	{
		// Данный метод используется в:
		// StyleProtoChain для inherited styles — мы такие стили не поддерживаем, поэтому можем возвратить null;
		// Group в addElementAt для удаления из старого родителя — наш View вставляется только в наш Container, а он переопределяет addElementAt.
		return null;
	}

	public function get depth():Number
	{
		throw new IllegalOperationError();
	}
	public function set depth(value:Number):void
	{
		throw new IllegalOperationError();
	}

	public function get visible():Boolean
	{
		throw new IllegalOperationError();
	}
	public function set visible(value:Boolean):void
	{
		throw new IllegalOperationError();
	}

	public function get alpha():Number
	{
		throw new IllegalOperationError();
	}

	public function set alpha(value:Number):void
	{
		throw new IllegalOperationError();
	}

	[PercentProxy("percentWidth")]
	public function get width():Number
	{
		return layoutMetrics.width;
	}
	public function set width(value:Number):void
	{
		layoutMetrics.width = value;
	}

	[PercentProxy("percentHeight")]
	public function get height():Number
	{
		return layoutMetrics.height;
	}
	public function set height(value:Number):void
	{
		layoutMetrics.height = value;
	}

	public function get x():Number
	{
		throw new IllegalOperationError();
	}

	public function set x(value:Number):void
	{
		throw new IllegalOperationError();
	}

	public function get y():Number
	{
		throw new IllegalOperationError();
	}

	public function set y(value:Number):void
	{
		throw new IllegalOperationError();
	}

	public function get designLayer():DesignLayer
	{
		throw new IllegalOperationError();
	}

	public function set designLayer(value:DesignLayer):void
	{
		throw new IllegalOperationError();
	}

	public function get postLayoutTransformOffsets():TransformOffsets
	{
		throw new IllegalOperationError();
	}

	public function set postLayoutTransformOffsets(value:TransformOffsets):void
	{
		throw new IllegalOperationError();
	}

	public function get is3D():Boolean
	{
		throw new IllegalOperationError();
	}

	/* IAdvancedStyleClient */

	public function get styleName():Object
	{
		return null;
	}

	public function set styleName(value:Object):void
	{
		throw new IllegalOperationError();
	}

	public function styleChanged(styleProp:String):void
	{
//		var allStyles:Boolean = styleProp == null || styleProp == "styleName";
//
//		if (allStyles || styleProp == "skinClass")
//		{
//			skinChanged = true;
//			invalidateProperties();
//		}
	}

	public function get className():String
	{
		throw new IllegalOperationError();
	}

	private var _inheritingStyles:Object = StyleProtoChain.STYLE_UNINITIALIZED;
	public function get inheritingStyles():Object
	{
		return _inheritingStyles;
	}
	public function set inheritingStyles(value:Object):void
	{
		_inheritingStyles = value;
	}

	private var _nonInheritingStyles:Object;
	public function get nonInheritingStyles():Object
	{
		return _nonInheritingStyles;
	}
	public function set nonInheritingStyles(value:Object):void
	{
		_nonInheritingStyles = value;
	}

	public function get styleDeclaration():CSSStyleDeclaration
	{
		return null;
	}
	public function set styleDeclaration(value:CSSStyleDeclaration):void
	{
		throw new IllegalOperationError();
	}

	public function getStyle(styleProp:String):*
	{
		return _nonInheritingStyles[styleProp];
	}

	public function setStyle(styleProp:String, newValue:*):void
	{
		if (styleProp == "skinClass")
		{
			_skinClass = newValue;
		}
		else
		{
			throw new IllegalOperationError();
		}
	}

	public function clearStyle(styleProp:String):void
	{
		throw new IllegalOperationError();
	}

	public function getClassStyleDeclarations():Array
	{
		return StyleProtoChain.getClassStyleDeclarations(this);
	}

	public function notifyStyleChangeInChildren(styleProp:String, recursive:Boolean):void
	{
	}

	public function regenerateStyleCache(recursive:Boolean):void
	{
		StyleProtoChain.initProtoChain(this);
	}

	public function registerEffects(effects:Array):void
	{
		throw new IllegalOperationError();
	}

	public function get styleParent():IAdvancedStyleClient
	{
		if (skinV.parent == null)
		{
			return null;
		}

		// null будет при popup — первый parent будет system manager, а вторым stage
		var candidate:DisplayObjectContainer = skinV.parent.parent;
		if (candidate is IAdvancedStyleClient)
		{
			return IAdvancedStyleClient(skinV.parent.parent).styleParent;
		}
		else
		{
			return null;
		}
	}

	public function stylesInitialized():void
	{
	}

	public function matchesCSSState(cssState:String):Boolean
	{
		return false;
	}

	public function matchesCSSType(cssType:String):Boolean
	{
		var clazz:Class = getDefinitionByName(cssType) as Class;
		return this is clazz;
	}
	
	/* IViewHost */
	public function createSkin():Skin
	{
		regenerateStyleCache(false);
		var skinClass:Class = _skinClass == null ? getStyle("skinClass") : _skinClass;
		_skin = new skinClass();
		initializeSkin();
		return _skin;
	}

	protected function initializeSkin():void
	{
		skinV = _skin;
		_skin.layoutMetrics = layoutMetrics;
		_skin.untypedHostComponent = this;
		if ("hostComponent" in _skin)
		{
			_skin["hostComponent"] = this;
		}

		_skin.styleName = this;
		listenSkinParts(_skin);
	}

	public function commitProperties():void
	{
		if (skinStateIsDirty)
		{
			// This component must first be updated to the pending state as the skin inherits styles from this component.
			//noinspection UnnecessaryLocalVariableJS
			var pendingState:String = getCurrentSkinState();
			// stateChanged(skin.currentState, pendingState, false);
			_skin.currentState = pendingState;
			skinStateIsDirty = false;
		}
	}

	private var skinStateIsDirty:Boolean = false;
	protected function invalidateSkinState():void
	{
		if (!skinStateIsDirty)
		{
			skinStateIsDirty = true;
			invalidateProperties();
		}
	}

	protected function getCurrentSkinState():String
    {
        return null;
    }

	/* IFlexModule */
	private var _moduleFactory:IFlexModuleFactory;
	public function get moduleFactory():IFlexModuleFactory
	{
		return _moduleFactory;
	}
	public function set moduleFactory(factory:IFlexModuleFactory):void
	{
		_moduleFactory = factory;
	}

	/* IID */
	private var _id:String;
	public function get id():String
	{
		return _id;
	}
	public function set id(value:String):void
	{
		_id = value;
	}

	/* IEventDispatcher */
//	private var eventDispather:EventDispatcher;
//	public function dispatchEvent(event:Event):Boolean
//	{
//		return eventDispather.dispatchEvent(event);
//	}
//
//	public function hasEventListener(type:String):Boolean
//	{
//		return eventDispather.hasEventListener(type);
//	}
//
//	public function willTrigger(type:String):Boolean
//	{
//		return eventDispather.willTrigger(type);
//	}
//
//	public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
//	{
//		eventDispather.removeEventListener(type, listener, useCapture);
//	}
//
//	public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
//	{
//		eventDispather.addEventListener(type, listener, useCapture, priority, useWeakReference);
//	}

	public function initialized(document:Object, id:String):void
	{
		this.id = id;
	}

	public function get layoutDirection():String
	{
		throw new IllegalOperationError();
	}

	public function set layoutDirection(value:String):void
	{
		throw new IllegalOperationError();
	}

	public function invalidateLayoutDirection():void
	{
		throw new IllegalOperationError();
	}
}
}