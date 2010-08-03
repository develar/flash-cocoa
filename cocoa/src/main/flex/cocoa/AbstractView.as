package cocoa
{
import cocoa.layout.LayoutMetrics;

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.Loader;
import flash.display.Shader;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.EventPhase;
import flash.events.FocusEvent;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.PerspectiveProjection;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Transform;
import flash.geom.Vector3D;
import flash.ui.Keyboard;

import mx.automation.IAutomationObject;
import mx.controls.IFlexContextMenu;
import mx.core.AdvancedLayoutFeatures;
import mx.core.DesignLayer;
import mx.core.EventPriority;
import mx.core.FlexGlobals;
import mx.core.FlexSprite;
import mx.core.IFlexModule;
import mx.core.IFlexModuleFactory;
import mx.core.IInvalidating;
import mx.core.ILayoutDirectionElement;
import mx.core.IUIComponent;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.LayoutDirection;
import mx.core.LayoutElementUIComponentUtils;
import mx.core.UIComponent;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.effects.EffectManager;
import mx.effects.IEffectInstance;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.events.MoveEvent;
import mx.events.PropertyChangeEvent;
import mx.events.ResizeEvent;
import mx.filters.BaseFilter;
import mx.filters.IBitmapFilter;
import mx.geom.Transform;
import mx.geom.TransformOffsets;
import mx.graphics.shaderClasses.ColorBurnShader;
import mx.graphics.shaderClasses.ColorDodgeShader;
import mx.graphics.shaderClasses.ColorShader;
import mx.graphics.shaderClasses.ExclusionShader;
import mx.graphics.shaderClasses.HueShader;
import mx.graphics.shaderClasses.LuminosityShader;
import mx.graphics.shaderClasses.SaturationShader;
import mx.graphics.shaderClasses.SoftLightShader;
import mx.managers.CursorManager;
import mx.managers.ICursorManager;
import mx.managers.IFocusManager;
import mx.managers.IFocusManagerComponent;
import mx.managers.IFocusManagerContainer;
import mx.managers.ILayoutManagerClient;
import mx.managers.ISystemManager;
import mx.managers.IToolTipManagerClient;
import mx.managers.SystemManagerGlobals;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;
import mx.utils.MatrixUtil;

use namespace mx_internal;

//--------------------------------------
//  Lifecycle events
//--------------------------------------

/**
 *  Dispatched when the component is added to a container as a content child
 *  by using the <code>addChild()</code>, <code>addChildAt()</code>,
 *  <code>addElement()</code>, or <code>addElementAt()</code> method.
 *  If the component is added to the container as a noncontent child by
 *  using the <code>rawChildren.addChild()</code> or
 *  <code>rawChildren.addChildAt()</code> method, the event is not dispatched.
 *
 * <p>This event is only dispatched when there are one or more relevant listeners
 * attached to the dispatching object.</p>
 *
 *  @eventType mx.events.FlexEvent.ADD
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="add", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the component has finished its construction,
 *  property processing, measuring, layout, and drawing.
 *
 *  <p>At this point, depending on its <code>visible</code> property,
 *  the component is not visible even though it has been drawn.</p>
 *
 *  @eventType mx.events.FlexEvent.CREATION_COMPLETE
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="creationComplete", type="mx.events.FlexEvent")]

/**
 *  Dispatched when an object has had its <code>commitProperties()</code>,
 *  <code>measure()</code>, and
 *  <code>updateDisplayList()</code> methods called (if needed).
 *
 *  <p>This is the last opportunity to alter the component before it is
 *  displayed. All properties have been committed and the component has
 *  been measured and layed out.</p>
 *
 *  <p>This event is only dispatched when there are one or more
 *  relevant listeners attached to the dispatching object.</p>
 *
 *  @eventType mx.events.FlexEvent.UPDATE_COMPLETE
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="updateComplete", type="mx.events.FlexEvent")]

/**
 *  Dispatched when an object's state changes from visible to invisible.
 *
 *  @eventType mx.events.FlexEvent.HIDE
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="hide", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the component has finished its construction
 *  and has all initialization properties set.
 *
 *  <p>After the initialization phase, properties are processed, the component
 *  is measured, laid out, and drawn, after which the
 *  <code>creationComplete</code> event is dispatched.</p>
 *
 *  @eventType mx.events.FlexEvent.INITIALIZE
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="initialize", type="mx.events.FlexEvent")]

/**
 *  Dispatched at the beginning of the component initialization sequence.
 *  The component is in a very raw state when this event is dispatched.
 *  Many components, such as the Button control, create internal child
 *  components to implement functionality; for example, the Button control
 *  creates an internal UITextField component to represent its label text.
 *  When Flex dispatches the <code>preinitialize</code> event,
 *  the children, including the internal children, of a component
 *  have not yet been created.
 *
 *  @eventType mx.events.FlexEvent.PREINITIALIZE
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="preinitialize", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the component is removed from a container as a content child
 *  by using the <code>removeChild()</code>, <code>removeChildAt()</code>,
 *  <code>removeElement()</code>, or <code>removeElementAt()</code> method.
 *  If the component is removed from the container as a noncontent child by
 *  using the <code>rawChildren.removeChild()</code> or
 *  <code>rawChildren.removeChildAt()</code> method, the event is not dispatched.
 *
 * <p>This event only dispatched when there are one or more relevant listeners
 * attached to the dispatching object.</p>
 *
 *  @eventType mx.events.FlexEvent.REMOVE
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="remove", type="mx.events.FlexEvent")]

/**
 *  <p>The <code>resize</code> event is not
 *  dispatched until after the property changes.</p>
 *
 *  <p>This event only dispatched when there are one or more
 *  relevant listeners attached to the dispatching object.</p>
 *
 *  @eventType mx.events.ResizeEvent.RESIZE
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="resize", type="mx.events.ResizeEvent")]

/**
 *  Dispatched when an object's state changes from invisible to visible.
 *
 *  @eventType mx.events.FlexEvent.SHOW
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="show", type="mx.events.FlexEvent")]

//-------------------------------------- //  Mouse events //--------------------------------------

/**
 *  Dispatched from a component opened using the PopUpManager
 *  when the user clicks outside it.
 *
 *  @eventType mx.events.FlexMouseEvent.MOUSE_DOWN_OUTSIDE
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="mouseDownOutside", type="mx.events.FlexMouseEvent")]

/**
 *  Dispatched from a component opened using the PopUpManager
 *  when the user scrolls the mouse wheel outside it.
 *
 *  @eventType mx.events.FlexMouseEvent.MOUSE_WHEEL_OUTSIDE
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="mouseWheelOutside", type="mx.events.FlexMouseEvent")]

//-------------------------------------- //  Validation events //--------------------------------------

[Event(name="valueCommit", type="mx.events.FlexEvent")]

//-------------------------------------- //  Drag-and-drop events //--------------------------------------

[Event(name="dragEnter", type="mx.events.DragEvent")]
[Event(name="dragOver", type="mx.events.DragEvent")]

/**
 *  Dispatched by the component when the user drags outside the component,
 *  but does not drop the data onto the target.
 *
 *  <p>You use this event to restore the drop target to its normal appearance
 *  if you modified its appearance as part of handling the
 *  <code>dragEnter</code> or <code>dragOver</code> event.</p>
 *
 *  @eventType mx.events.DragEvent.DRAG_EXIT
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="dragExit", type="mx.events.DragEvent")]

/**
 *  Dispatched by the drop target when the user releases the mouse over it.
 *
 *  <p>You use this event handler to add the drag data to the drop target.</p>
 *
 *  <p>If you call <code>Event.preventDefault()</code> in the event handler
 *  for the <code>dragDrop</code> event for
 *  a Tree control when dragging data from one Tree control to another,
 *  it prevents the drop.</p>
 *
 *  @eventType mx.events.DragEvent.DRAG_DROP
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="dragDrop", type="mx.events.DragEvent")]

/**
 *  Dispatched by the drag initiator (the component that is the source
 *  of the data being dragged) when the drag operation completes,
 *  either when you drop the dragged data onto a drop target or when you end
 *  the drag-and-drop operation without performing a drop.
 *
 *  <p>You can use this event to perform any final cleanup
 *  of the drag-and-drop operation.
 *  For example, if you drag a List control item from one list to another,
 *  you can delete the List control item from the source if you no longer
 *  need it.</p>
 *
 *  <p>If you call <code>Event.preventDefault()</code> in the event handler
 *  for the <code>dragComplete</code> event for
 *  a Tree control when dragging data from one Tree control to another,
 *  it prevents the drop.</p>
 *
 *  @eventType mx.events.DragEvent.DRAG_COMPLETE
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="dragComplete", type="mx.events.DragEvent")]

/**
 *  Dispatched by the drag initiator when starting a drag operation.
 *  This event is used internally by the list-based controls;
 *  you do not handle it when implementing drag and drop.
 *  If you want to control the start of a drag-and-drop operation,
 *  use the <code>mouseDown</code> or <code>mouseMove</code> event.
 *
 *  @eventType mx.events.DragEvent.DRAG_START
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="dragStart", type="mx.events.DragEvent")]

//-------------------------------------- //  Effect events //--------------------------------------

/**
 *  Dispatched just before an effect starts.
 *
 *  <p>The effect does not start changing any visuals
 *  until after this event is fired.</p>
 *
 *  @eventType mx.events.EffectEvent.EFFECT_START
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="effectStart", type="mx.events.EffectEvent")]

/**
 *  Dispatched after an effect is stopped, which happens
 *  only by a call to <code>stop()</code> on the effect.
 *
 *  <p>The effect then dispatches the EFFECT_END event
 *  as the effect finishes. The purpose of the EFFECT_STOP
 *  event is to let listeners know that the effect came to
 *  a premature end, rather than ending naturally or as a
 *  result of a call to <code>end()</code>.</p>
 *
 *  @eventType mx.events.EffectEvent.EFFECT_STOP
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="effectStop", type="mx.events.EffectEvent")]

/**
 *  Dispatched after an effect ends.
 *
 *  <p>The effect makes the last set of visual changes
 *  before this event is fired, but those changes are not
 *  rendered on the screen.
 *  Thus, you might have to use the <code>callLater()</code> method
 *  to delay any other changes that you want to make until after the
 *  changes have been rendered onscreen.</p>
 *
 *  @eventType mx.events.EffectEvent.EFFECT_END
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="effectEnd", type="mx.events.EffectEvent")]


//-------------------------------------- //  Tooltip events //--------------------------------------

/**
 *  Dispatched by the component when it is time to create a ToolTip.
 *
 *  <p>If you create your own IToolTip object and place a reference
 *  to it in the <code>toolTip</code> property of the event object
 *  that is passed to your <code>toolTipCreate</code> handler,
 *  the ToolTipManager displays your custom ToolTip.
 *  Otherwise, the ToolTipManager creates an instance of
 *  <code>ToolTipManager.toolTipClass</code> to display.</p>
 *
 *  <p>The sequence of ToolTip events is <code>toolTipStart</code>,
 *  <code>toolTipCreate</code>, <code>toolTipShow</code>,
 *  <code>toolTipShown</code>, <code>toolTipHide</code>,
 *  and <code>toolTipEnd</code>.</p>
 *
 *  @eventType mx.events.ToolTipEvent.TOOL_TIP_CREATE
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="toolTipCreate", type="mx.events.ToolTipEvent")]

/**
 *  Dispatched by the component when its ToolTip has been hidden
 *  and is to be discarded soon.
 *
 *  <p>If you specify an effect using the
 *  <code>ToolTipManager.hideEffect</code> property,
 *  this event is dispatched after the effect stops playing.</p>
 *
 *  <p>The sequence of ToolTip events is <code>toolTipStart</code>,
 *  <code>toolTipCreate</code>, <code>toolTipShow</code>,
 *  <code>toolTipShown</code>, <code>toolTipHide</code>,
 *  and <code>toolTipEnd</code>.</p>
 *
 *  @eventType mx.events.ToolTipEvent.TOOL_TIP_END
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="toolTipEnd", type="mx.events.ToolTipEvent")]

/**
 *  Dispatched by the component when its ToolTip is about to be hidden.
 *
 *  <p>If you specify an effect using the
 *  <code>ToolTipManager.hideEffect</code> property,
 *  this event is dispatched before the effect starts playing.</p>
 *
 *  <p>The sequence of ToolTip events is <code>toolTipStart</code>,
 *  <code>toolTipCreate</code>, <code>toolTipShow</code>,
 *  <code>toolTipShown</code>, <code>toolTipHide</code>,
 *  and <code>toolTipEnd</code>.</p>
 *
 *  @eventType mx.events.ToolTipEvent.TOOL_TIP_HIDE
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="toolTipHide", type="mx.events.ToolTipEvent")]

/**
 *  Dispatched by the component when its ToolTip is about to be shown.
 *
 *  <p>If you specify an effect using the
 *  <code>ToolTipManager.showEffect</code> property,
 *  this event is dispatched before the effect starts playing.
 *  You can use this event to modify the ToolTip before it appears.</p>
 *
 *  <p>The sequence of ToolTip events is <code>toolTipStart</code>,
 *  <code>toolTipCreate</code>, <code>toolTipShow</code>,
 *  <code>toolTipShown</code>, <code>toolTipHide</code>,
 *  and <code>toolTipEnd</code>.</p>
 *
 *  @eventType mx.events.ToolTipEvent.TOOL_TIP_SHOW
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="toolTipShow", type="mx.events.ToolTipEvent")]

/**
 *  Dispatched by the component when its ToolTip has been shown.
 *
 *  <p>If you specify an effect using the
 *  <code>ToolTipManager.showEffect</code> property,
 *  this event is dispatched after the effect stops playing.</p>
 *
 *  <p>The sequence of ToolTip events is <code>toolTipStart</code>,
 *  <code>toolTipCreate</code>, <code>toolTipShow</code>,
 *  <code>toolTipShown</code>, <code>toolTipHide</code>,
 *  and <code>toolTipEnd</code>.</p>
 *
 *  @eventType mx.events.ToolTipEvent.TOOL_TIP_SHOWN
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="toolTipShown", type="mx.events.ToolTipEvent")]

/**
 *  Dispatched by a component whose <code>toolTip</code> property is set,
 *  as soon as the user moves the mouse over it.
 *
 *  <p>The sequence of ToolTip events is <code>toolTipStart</code>,
 *  <code>toolTipCreate</code>, <code>toolTipShow</code>,
 *  <code>toolTipShown</code>, <code>toolTipHide</code>,
 *  and <code>toolTipEnd</code>.</p>
 *
 *  @eventType mx.events.ToolTipEvent.TOOL_TIP_START
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="toolTipStart", type="mx.events.ToolTipEvent")]

//-------------------------------------- //  Effects //--------------------------------------

/**
 *  Played when the component is created.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Effect(name="creationCompleteEffect", event="creationComplete")]

/**
 *  Played when the component is moved.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Effect(name="moveEffect", event="move")]

/**
 *  Played when the component is resized.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Effect(name="resizeEffect", event="resize")]

/**
 *  Played when the component becomes visible.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Effect(name="showEffect", event="show")]

/**
 *  Played when the component becomes invisible.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Effect(name="hideEffect", event="hide")]

/**
 *  Played when the user presses the mouse button while over the component.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Effect(name="mouseDownEffect", event="mouseDown")]

/**
 *  Played when the user releases the mouse button while over the component.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Effect(name="mouseUpEffect", event="mouseUp")]

/**
 *  Played when the user rolls the mouse over the component.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Effect(name="rollOverEffect", event="rollOver")]

/**
 *  Played when the user rolls the mouse so it is no longer over the component.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Effect(name="rollOutEffect", event="rollOut")]

/**
 *  Played when the component gains keyboard focus.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Effect(name="focusInEffect", event="focusIn")]

/**
 *  Played when the component loses keyboard focus.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Effect(name="focusOutEffect", event="focusOut")]

/**
 *  Played when the component is added as a child to a Container.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Effect(name="addedEffect", event="added")]

/**
 *  Played when the component is removed from a Container.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Effect(name="removedEffect", event="removed")]

/**
 *  The UIComponent class is the base class for all visual components,
 *  both interactive and noninteractive.
 *
 *  <p>An interactive component can participate in tabbing and other kinds of
 *  keyboard focus manipulation, accept low-level events like keyboard and
 *  mouse input, and be disabled so that it does not receive keyboard and
 *  mouse input.
 *  This is in contrast to noninteractive components, like Label and
 *  ProgressBar, which simply display contents and are not manipulated by
 *  the user.</p>
 *  <p>The UIComponent class is not used as an MXML tag, but is used as a base
 *  class for other classes.</p>
 */
public class AbstractView extends FlexSprite implements View, IAutomationObject, IFlexModule, IInvalidating, ILayoutManagerClient, IToolTipManagerClient, IVisualElement
{
	public static const LAYOUT_DIRECTION_LTR:String = "ltr";

	private static const EMPTY_LAYOUT_METRICS:LayoutMetrics = new LayoutMetrics();

	protected var _layoutMetrics:LayoutMetrics = EMPTY_LAYOUT_METRICS;
	public function get layoutMetrics():LayoutMetrics
	{
		return _layoutMetrics;
	}
	public function set layoutMetrics(value:LayoutMetrics):void
	{
		_layoutMetrics = value;
		if (!isNaN(_layoutMetrics.width))
		{
			_width = _layoutMetrics.width;
		}
		if (!isNaN(_layoutMetrics.height))
		{
			_height = _layoutMetrics.height;
		}
	}

	/**
	 * This method allows access to the Player's native implementation of addChildAt(), which can be useful
	 * since components can override addChildAt() and thereby hide the native implementation.
	 */
	public final function addDisplayObject(displayObject:DisplayObject, index:int = -1):void
	{
		super.addChildAt(displayObject, index == -1 ? numChildren : index);
	}

	public final function removeDisplayObject(child:DisplayObject):void
	{
		super.removeChild(child);
	}

	private static const DEFAULT_MAX_WIDTH:Number = 10000;
	private static const DEFAULT_MAX_HEIGHT:Number = 10000;

	public function AbstractView()
	{
		super();

		// Override  variables in superclasses.
		focusRect = false; // We do our own focus drawing.
		// We are tab enabled by default if IFocusManagerComponent
		tabEnabled = (this is IFocusManagerComponent);
		tabFocusEnabled = (this is IFocusManagerComponent);

		// Make the component invisible until the initialization sequence
		// is complete.
		// It will be set visible when the 'initialized' flag is set.
		$visible = false;

		addEventListener(Event.REMOVED, removedHandler);

		_width = super.width;
		_height = super.height;
	}

	/**
	 *  Blocks the background processing of methods
	 *  queued by <code>callLater()</code>,
	 *  until <code>resumeBackgroundProcessing()</code> is called.
	 *
	 *  <p>These methods can be useful when you have time-critical code
	 *  which needs to execute without interruption.
	 *  For example, when you set the <code>suspendBackgroundProcessing</code>
	 *  property of an Effect to <code>true</code>,
	 *  <code>suspendBackgroundProcessing()</code> is automatically called
	 *  when it starts playing, and <code>resumeBackgroundProcessing</code>
	 *  is called when it stops, in order to ensure that the animation
	 *  is smooth.</p>
	 *
	 *  <p>Since the LayoutManager uses <code>callLater()</code>,
	 *  this means that <code>commitProperties()</code>,
	 *  <code>measure()</code>, and <code>updateDisplayList()</code>
	 *  is not called in between calls to
	 *  <code>suspendBackgroundProcessing()</code> and
	 *  <code>resumeBackgroundProcessing()</code>.</p>
	 *
	 *  <p>It is safe for both an outer method and an inner method
	 *  (i.e., one that the outer methods calls) to call
	 *  <code>suspendBackgroundProcessing()</code>
	 *  and <code>resumeBackgroundProcessing()</code>, because these
	 *  methods actually increment and decrement a counter
	 *  which determines whether background processing occurs.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static function suspendBackgroundProcessing():void
	{
		UIComponentGlobals.callLaterSuspendCount++;
	}

	/**
	 *  Resumes the background processing of methods
	 *  queued by <code>callLater()</code>, after a call to
	 *  <code>suspendBackgroundProcessing()</code>.
	 *
	 *  <p>Refer to the description of
	 *  <code>suspendBackgroundProcessing()</code> for more information.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static function resumeBackgroundProcessing():void
	{
		if (UIComponentGlobals.callLaterSuspendCount > 0)
		{
			UIComponentGlobals.callLaterSuspendCount--;

			// Once the suspend count gets back to 0, we need to
			// force a render event to happen
			if (UIComponentGlobals.callLaterSuspendCount == 0)
			{
				var sm:ISystemManager = SystemManagerGlobals.topLevelSystemManagers[0];
				if (sm && sm.stage)
				{
					sm.stage.invalidate();
				}
			}
		}
	}

	/**
	 *  @private
	 *  There is a bug (139381) where we occasionally get callLaterDispatcher()
	 *  even though we didn't expect it.
	 *  That causes us to do a removeEventListener() twice,
	 *  which messes up some internal thing in the player so that
	 *  the next addEventListener() doesn't actually get us the render event.
	 */
	private var listeningForRender:Boolean = false;

	/**
	 *  @private
	 *  List of methods used by callLater().
	 */
	private var methodQueue:Vector.<MethodQueueElement> = new <MethodQueueElement>[];

	/**
	 *  @private
	 */
	private var parentChangedFlag:Boolean = false;

	private var _initialized:Boolean = false;

	[Inspectable(environment="none")]

	/**
	 *  A flag that determines if an object has been through all three phases
	 *  of layout: commitment, measurement, and layout (provided that any were required).
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get initialized():Boolean
	{
		return _initialized;
	}

	public function set initialized(value:Boolean):void
	{
		_initialized = value;

		if (value)
		{
			setVisible(_visible, true);
			dispatchEvent(new FlexEvent(FlexEvent.CREATION_COMPLETE));
		}
	}

	//----------------------------------
	//  processedDescriptors
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the processedDescriptors property.
	 */
	private var _processedDescriptors:Boolean = false;

	[Inspectable(environment="none")]

	/**
	 *  Set to <code>true</code> after immediate or deferred child creation,
	 *  depending on which one happens. For a Container object, it is set
	 *  to <code>true</code> at the end of
	 *  the <code>createComponentsFromDescriptors()</code> method,
	 *  meaning after the Container object creates its children from its child descriptors.
	 *
	 *  <p>For example, if an Accordion container uses deferred instantiation,
	 *  the <code>processedDescriptors</code> property for the second pane of
	 *  the Accordion container does not become <code>true</code> until after
	 *  the user navigates to that pane and the pane creates its children.
	 *  But, if the Accordion had set the <code>creationPolicy</code> property
	 *  to <code>"all"</code>, the <code>processedDescriptors</code> property
	 *  for its second pane is set to <code>true</code> during application startup.</p>
	 *
	 *  <p>For classes that are not containers, which do not have descriptors,
	 *  it is set to <code>true</code> after the <code>createChildren()</code>
	 *  method creates any internal component children.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get processedDescriptors():Boolean
	{
		return _processedDescriptors;
	}

	/**
	 *  @private
	 */
	public function set processedDescriptors(value:Boolean):void
	{
		_processedDescriptors = value;

		if (value)
		{
			dispatchEvent(new FlexEvent(FlexEvent.INITIALIZE));
		}
	}

	//----------------------------------
	//  updateCompletePendingFlag
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the updateCompletePendingFlag property.
	 */
	private var _updateCompletePendingFlag:Boolean = false;

	[Inspectable(environment="none")]

	/**
	 *  A flag that determines if an object has been through all three phases
	 *  of layout validation (provided that any were required).
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get updateCompletePendingFlag():Boolean
	{
		return _updateCompletePendingFlag;
	}

	/**
	 *  @private
	 */
	public function set updateCompletePendingFlag(value:Boolean):void
	{
		_updateCompletePendingFlag = value;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables: Invalidation
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Whether this component needs to have its
	 *  commitProperties() method called.
	 */
	mx_internal var invalidatePropertiesFlag:Boolean = false;

	/**
	 *  @private
	 *  Whether this component needs to have its
	 *  measure() method called.
	 */
	mx_internal var invalidateSizeFlag:Boolean = false;

	/**
	 *  @private
	 *  Whether this component needs to be have its
	 *  updateDisplayList() method called.
	 */
	mx_internal var invalidateDisplayListFlag:Boolean = false;

	/**
	 *  @private
	 *  Whether setActualSize() has been called on this component
	 *  at least once.  This is used in validateBaselinePosition()
	 *  to resize the component to explicit or measured
	 *  size if baselinePosition getter is called before the
	 *  component has been resized by the layout.
	 */
	mx_internal var setActualSizeCalled:Boolean = false;

	//--------------------------------------------------------------------------
	//
	//  Variables: Measurement
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Holds the last recorded value of the width property.
	 *  Used in dispatching a ResizeEvent.
	 */
	private var oldWidth:Number = 0;

	/**
	 *  @private
	 *  Holds the last recorded value of the height property.
	 *  Used in dispatching a ResizeEvent.
	 */
	private var oldHeight:Number = 0;

	/**
	 *  @private
	 *  Holds the last recorded value of the minWidth property.
	 */
	private var oldMinWidth:Number;

	/**
	 *  @private
	 *  Holds the last recorded value of the minHeight property.
	 */
	private var oldMinHeight:Number;

	/**
	 *  @private
	 *  Holds the last recorded value of the explicitWidth property.
	 */
	private var oldExplicitWidth:Number;

	/**
	 *  @private
	 *  Holds the last recorded value of the explicitHeight property.
	 */
	private var oldExplicitHeight:Number;

	/**
	 * @private
	 *
	 * storage for advanced layout and transform properties.
	 */
	mx_internal var _layoutFeatures:AdvancedLayoutFeatures;

	/**
	 * @private
	 *
	 * storage for the modified Transform object that can dispatch change events correctly.
	 */
	private var _transform:flash.geom.Transform;

	//--------------------------------------------------------------------------
	//
	//  Variables: Effects
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Sprite used to display an overlay.
	 */
	mx_internal var effectOverlay:UIComponent;

	/**
	 *  @private
	 *  Color used for overlay.
	 */
	mx_internal var effectOverlayColor:uint;

	/**
	 *  @private
	 *  Counter to keep track of the number of current users
	 *  of the overlay.
	 */
	mx_internal var effectOverlayReferenceCount:int = 0;

	//--------------------------------------------------------------------------
	//
	//  Variables: Other
	//
	//--------------------------------------------------------------------------

	private var _usingBridge:int = -1;

	/**
	 *  @private
	 */
	private function get usingBridge():Boolean
	{
		if (_usingBridge == 0)
		{
			return false;
		}
		if (_usingBridge == 1)
		{
			return true;
		}

		if (!_systemManager)
		{
			return false;
		}

		// no types so no dependencies
		var mp:Object = _systemManager.getImplementation("mx.managers.IMarshallPlanSystemManager");
		if (!mp)
		{
			_usingBridge = 0;
			return false;
		}
		if (mp.useSWFBridge())
		{
			_usingBridge = 1;
			return true;
		}
		_usingBridge = 0;
		return false;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	mx_internal var _owner:DisplayObjectContainer;

	public function get owner():DisplayObjectContainer
	{
		return _owner != null ? _owner : parent;
	}

	public function set owner(value:DisplayObjectContainer):void
	{
		_owner = value;
	}

	//----------------------------------
	//  x
	//----------------------------------

	[Bindable("xChanged")]
	[Inspectable(category="General")]

	/**
	 *  Number that specifies the component's horizontal position,
	 *  in pixels, within its parent container.
	 *
	 *  <p>Setting this property directly or calling <code>move()</code>
	 *  has no effect -- or only a temporary effect -- if the
	 *  component is parented by a layout container such as HBox, Grid,
	 *  or Form, because the layout calculations of those containers
	 *  set the <code>x</code> position to the results of the calculation.
	 *  However, the <code>x</code> property must almost always be set
	 *  when the parent is a Canvas or other absolute-positioning
	 *  container because the default value is 0.</p>
	 *
	 *  @default 0
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override public function get x():Number
	{
		return (_layoutFeatures == null) ? super.x : _layoutFeatures.layoutX;
	}

	/**
	 *  @private
	 */
	override public function set x(value:Number):void
	{
		if (x == value)
		{
			return;
		}

		if (_layoutFeatures == null)
		{
			super.x = value;
		}
		else
		{
			_layoutFeatures.layoutX = value;
			invalidateTransform();
		}

		invalidateProperties();

		if (parent && parent is UIComponent)
		{
			UIComponent(parent).childXYChanged();
		}

		if (hasEventListener("xChanged"))
		{
			dispatchEvent(new Event("xChanged"));
		}
	}

	[Bindable("zChanged")]
	[Inspectable(category="General")]

	/**
	 *  @inheritDoc
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 3
	 */
	override public function get z():Number
	{
		return (_layoutFeatures == null) ? super.z : _layoutFeatures.layoutZ;
	}

	/**
	 *  @private
	 */
	override public function set z(value:Number):void
	{
		if (z == value)
		{
			return;
		}

		// validateMatrix when switching between 2D/3D, works around player bug
		// see sdk-23421
		var was3D:Boolean = is3D;
		if (_layoutFeatures == null)
		{
			initAdvancedLayoutFeatures();
		}

		_layoutFeatures.layoutZ = value;
		invalidateTransform();
		invalidateProperties();
		if (was3D != is3D)
		{
			validateMatrix();
		}

		if (hasEventListener("zChanged"))
		{
			dispatchEvent(new Event("zChanged"));
		}
	}

	/**
	 *  Sets the x coordinate for the transform center of the component.
	 *
	 *  <p>When this component is the target of a Spark transform effect,
	 *  you can override this property by setting
	 *  the <code>AnimateTransform.autoCenterTransform</code> property.
	 *  If <code>autoCenterTransform</code> is <code>false</code>, the transform
	 *  center is determined by the <code>transformX</code>,
	 *  <code>transformY</code>, and <code>transformZ</code> properties
	 *  of the effect target.
	 *  If <code>autoCenterTransform</code> is <code>true</code>,
	 *  the effect occurs around the center of the target,
	 *  <code>(width/2, height/2)</code>.</p>
	 *
	 *  <p>Setting this property on the Spark effect class
	 *  overrides the setting on the target component.</p>
	 *
	 *  @see spark.effects.AnimateTransform#autoCenterTransform
	 *  @see spark.effects.AnimateTransform#transformX
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get transformX():Number
	{
		return (_layoutFeatures == null) ? 0 : _layoutFeatures.transformX;
	}

	/**
	 *  @private
	 */
	public function set transformX(value:Number):void
	{
		if (transformX == value)
		{
			return;
		}
		if (_layoutFeatures == null)
		{
			initAdvancedLayoutFeatures();
		}
		_layoutFeatures.transformX = value;
		invalidateTransform();
		invalidateProperties();
		invalidateParentSizeAndDisplayList();
	}

	/**
	 *  Sets the y coordinate for the transform center of the component.
	 *
	 *  <p>When this component is the target of a Spark transform effect,
	 *  you can override this property by setting
	 *  the <code>AnimateTransform.autoCenterTransform</code> property.
	 *  If <code>autoCenterTransform</code> is <code>false</code>, the transform
	 *  center is determined by the <code>transformX</code>,
	 *  <code>transformY</code>, and <code>transformZ</code> properties
	 *  of the effect target.
	 *  If <code>autoCenterTransform</code> is <code>true</code>,
	 *  the effect occurs around the center of the target,
	 *  <code>(width/2, height/2)</code>.</p>
	 *
	 *  <p>Seeting this property on the Spark effect class
	 *  overrides the setting on the target component.</p>
	 *
	 *  @see spark.effects.AnimateTransform#autoCenterTransform
	 *  @see spark.effects.AnimateTransform#transformY
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get transformY():Number
	{
		return (_layoutFeatures == null) ? 0 : _layoutFeatures.transformY;
	}

	/**
	 *  @private
	 */
	public function set transformY(value:Number):void
	{
		if (transformY == value)
		{
			return;
		}
		if (_layoutFeatures == null)
		{
			initAdvancedLayoutFeatures();
		}
		_layoutFeatures.transformY = value;
		invalidateTransform();
		invalidateProperties();
		invalidateParentSizeAndDisplayList();
	}

	/**
	 *  Sets the z coordinate for the transform center of the component.
	 *
	 *  <p>When this component is the target of a Spark transform effect,
	 *  you can override this property by setting
	 *  the <code>AnimateTransform.autoCenterTransform</code> property.
	 *  If <code>autoCenterTransform</code> is <code>false</code>, the transform
	 *  center is determined by the <code>transformX</code>,
	 *  <code>transformY</code>, and <code>transformZ</code> properties
	 *  of the effect target.
	 *  If <code>autoCenterTransform</code> is <code>true</code>,
	 *  the effect occurs around the center of the target,
	 *  <code>(width/2, height/2)</code>.</p>
	 *
	 *  <p>Seeting this property on the Spark effect class
	 *  overrides the setting on the target component.</p>
	 *
	 *  @see spark.effects.AnimateTransform#autoCenterTransform
	 *  @see spark.effects.AnimateTransform#transformZ
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get transformZ():Number
	{
		return (_layoutFeatures == null) ? 0 : _layoutFeatures.transformZ;
	}

	/**
	 *  @private
	 */
	public function set transformZ(value:Number):void
	{
		if (transformZ == value)
		{
			return;
		}
		if (_layoutFeatures == null)
		{
			initAdvancedLayoutFeatures();
		}

		_layoutFeatures.transformZ = value;
		invalidateTransform();
		invalidateProperties();
		invalidateParentSizeAndDisplayList();
	}

	/**
	 *  @copy mx.core.IFlexDisplayObject#rotation
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override public function get rotation():Number
	{
		return (_layoutFeatures == null) ? super.rotation : _layoutFeatures.layoutRotationZ;
	}

	/**
	 * @private
	 */
	override public function set rotation(value:Number):void
	{
		if (rotation == value)
		{
			return;
		}

		_hasComplexLayoutMatrix = true;
		if (_layoutFeatures == null)
		{
			// clamp the rotation value between -180 and 180.  This is what
			// the Flash player does and what we mimic in CompoundTransform;
			// however, the Flash player doesn't handle values larger than
			// 2^15 - 1 (FP-749), so we need to clamp even when we're
			// just setting super.rotation.
			super.rotation = MatrixUtil.clampRotation(value);
		}
		else
		{
			_layoutFeatures.layoutRotationZ = value;
		}

		invalidateTransform();
		invalidateProperties();
		invalidateParentSizeAndDisplayList();
	}

	/**
	 *  @inheritDoc
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override public function get rotationZ():Number
	{
		return rotation;
	}

	/**
	 *  @private
	 */
	override public function set rotationZ(value:Number):void
	{
		rotation = value;
	}

	/**
	 * Indicates the x-axis rotation of the DisplayObject instance, in degrees, from its original orientation
	 * relative to the 3D parent container. Values from 0 to 180 represent clockwise rotation; values
	 * from 0 to -180 represent counterclockwise rotation. Values outside this range are added to or subtracted from
	 * 360 to obtain a value within the range.
	 *
	 * This property is ignored during calculation by any of Flex's 2D layouts.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 3
	 */
	override public function get rotationX():Number
	{
		return (_layoutFeatures == null) ? super.rotationX : _layoutFeatures.layoutRotationX;
	}

	/**
	 *  @private
	 */
	override public function set rotationX(value:Number):void
	{
		if (rotationX == value)
		{
			return;
		}

		// validateMatrix when switching between 2D/3D, works around player bug
		// see sdk-23421
		var was3D:Boolean = is3D;
		if (_layoutFeatures == null)
		{
			initAdvancedLayoutFeatures();
		}
		_layoutFeatures.layoutRotationX = value;
		invalidateTransform();
		invalidateProperties();
		invalidateParentSizeAndDisplayList();
		if (was3D != is3D)
		{
			validateMatrix();
		}
	}

	/**
	 * Indicates the y-axis rotation of the DisplayObject instance, in degrees, from its original orientation
	 * relative to the 3D parent container. Values from 0 to 180 represent clockwise rotation; values
	 * from 0 to -180 represent counterclockwise rotation. Values outside this range are added to or subtracted from
	 * 360 to obtain a value within the range.
	 *
	 * This property is ignored during calculation by any of Flex's 2D layouts.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override public function get rotationY():Number
	{
		return (_layoutFeatures == null) ? super.rotationY : _layoutFeatures.layoutRotationY;
	}

	/**
	 *  @private
	 */
	override public function set rotationY(value:Number):void
	{
		if (rotationY == value)
		{
			return;
		}

		// validateMatrix when switching between 2D/3D, works around player bug
		// see sdk-23421
		var was3D:Boolean = is3D;
		if (_layoutFeatures == null)
		{
			initAdvancedLayoutFeatures();
		}
		_layoutFeatures.layoutRotationY = value;
		invalidateTransform();
		invalidateProperties();
		invalidateParentSizeAndDisplayList();
		if (was3D != is3D)
		{
			validateMatrix();
		}
	}

	//----------------------------------
	//  y
	//----------------------------------

	[Bindable("yChanged")]
	[Inspectable(category="General")]

	/**
	 *  Number that specifies the component's vertical position,
	 *  in pixels, within its parent container.
	 *
	 *  <p>Setting this property directly or calling <code>move()</code>
	 *  has no effect -- or only a temporary effect -- if the
	 *  component is parented by a layout container such as HBox, Grid,
	 *  or Form, because the layout calculations of those containers
	 *  set the <code>x</code> position to the results of the calculation.
	 *  However, the <code>x</code> property must almost always be set
	 *  when the parent is a Canvas or other absolute-positioning
	 *  container because the default value is 0.</p>
	 *
	 *  @default 0
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */ override public function get y():Number
	{
		return (_layoutFeatures == null) ? super.y : _layoutFeatures.layoutY;
	}

	/**
	 *  @private
	 */
	override public function set y(value:Number):void
	{
		if (y == value)
		{
			return;
		}

		if (_layoutFeatures == null)
		{
			super.y = value;
		}
		else
		{
			_layoutFeatures.layoutY = value;
			invalidateTransform();
		}
		invalidateProperties();

		if (parent && parent is UIComponent)
		{
			UIComponent(parent).childXYChanged();
		}

		if (hasEventListener("yChanged"))
		{
			dispatchEvent(new Event("yChanged"));
		}
	}

	//----------------------------------
	//  width
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the width property.
	 */
	mx_internal var _width:Number;

	[Bindable("widthChanged")]
	[Inspectable(category="General")]
	[PercentProxy("percentWidth")]

	/**
	 *  Number that specifies the width of the component, in pixels,
	 *  in the parent's coordinates.
	 *  The default value is 0, but this property contains the actual component
	 *  width after Flex completes sizing the components in your application.
	 *
	 *  <p>Note: You can specify a percentage value in the MXML
	 *  <code>width</code> attribute, such as <code>width="100%"</code>,
	 *  but you cannot use a percentage value in the <code>width</code>
	 *  property in ActionScript.
	 *  Use the <code>percentWidth</code> property instead.</p>
	 *
	 *  <p>Setting this property causes a <code>resize</code> event to
	 *  be dispatched.
	 *  See the <code>resize</code> event for details on when
	 *  this event is dispatched.</p>
	 *
	 *  @see #percentWidth
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override public function get width():Number
	{
		return _width;
	}

	override public function set width(value:Number):void
	{
		if (_layoutMetrics.width != value)
		{
			explicitWidth = value;

			// We invalidate size because locking in width
			// may change the measured height in flow-based components.
			invalidateSize();
		}

		if (_width != value)
		{
			invalidateProperties();
			invalidateDisplayList();
			invalidateParentSizeAndDisplayList();

			_width = value;

			// The width is needed for the _layoutFeatures' mirror transform.
			if (_layoutFeatures)
			{
				_layoutFeatures.layoutWidth = _width;
				invalidateTransform();
			}

			if (hasEventListener("widthChanged"))
			{
				dispatchEvent(new Event("widthChanged"));
			}
		}
	}

	//----------------------------------
	//  height
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the height property.
	 */
	mx_internal var _height:Number;

	[Bindable("heightChanged")]
	[Inspectable(category="General")]
	[PercentProxy("percentHeight")]

	/**
	 *  Number that specifies the height of the component, in pixels,
	 *  in the parent's coordinates.
	 *  The default value is 0, but this property contains the actual component
	 *  height after Flex completes sizing the components in your application.
	 *
	 *  <p>Note: You can specify a percentage value in the MXML
	 *  <code>height</code> attribute, such as <code>height="100%"</code>,
	 *  but you cannot use a percentage value for the <code>height</code>
	 *  property in ActionScript;
	 *  use the <code>percentHeight</code> property instead.</p>
	 *
	 *  <p>Setting this property causes a <code>resize</code> event to be dispatched.
	 *  See the <code>resize</code> event for details on when
	 *  this event is dispatched.</p>
	 *
	 *  @see #percentHeight
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override public function get height():Number
	{
		return _height;
	}

	/**
	 *  @private
	 */
	override public function set height(value:Number):void
	{
		if (_layoutMetrics.height != value)
		{
			explicitHeight = value;

			// We invalidate size because locking in width
			// may change the measured height in flow-based components.
			invalidateSize();
		}

		if (_height != value)
		{
			invalidateProperties();
			invalidateDisplayList();
			invalidateParentSizeAndDisplayList();

			_height = value;

			if (hasEventListener("heightChanged"))
			{
				dispatchEvent(new Event("heightChanged"));
			}
		}
	}

	//----------------------------------
	//  scaleX
	//---------------------------------
	[Bindable("scaleXChanged")]
	[Inspectable(category="Size", defaultValue="1.0")]

	/**
	 *  Number that specifies the horizontal scaling factor.
	 *
	 *  <p>The default value is 1.0, which means that the object
	 *  is not scaled.
	 *  A <code>scaleX</code> of 2.0 means the object has been
	 *  magnified by a factor of 2, and a <code>scaleX</code> of 0.5
	 *  means the object has been reduced by a factor of 2.</p>
	 *
	 *  <p>A value of 0.0 is an invalid value.
	 *  Rather than setting it to 0.0, set it to a small value, or set
	 *  the <code>visible</code> property to <code>false</code> to hide the component.</p>
	 *
	 *  @default 1.0
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */

	override public function get scaleX():Number
	{
		return (_layoutFeatures == null) ? super.scaleX : _layoutFeatures.layoutScaleX;
	}

	override public function set scaleX(value:Number):void
	{
		var prevValue:Number = (_layoutFeatures == null) ? scaleX : _layoutFeatures.layoutScaleX;
		if (prevValue == value)
		{
			return;
		}

		_hasComplexLayoutMatrix = true;

		// trace("set scaleX:" + this + "value = " + value);
		if (_layoutFeatures == null)
		{
			super.scaleX = value;
		}
		else
		{
			_layoutFeatures.layoutScaleX = value;
		}
		invalidateTransform();
		invalidateProperties();

		// If we're not compatible with Flex3 (measuredWidth is pre-scale always)
		// and scaleX is changing we need to invalidate parent size and display list
		// since we are not going to detect a change in measured sizes during measure.
		invalidateParentSizeAndDisplayList();


		dispatchEvent(new Event("scaleXChanged"));
	}

	//----------------------------------
	//  scaleY
	//----------------------------------

	[Bindable("scaleYChanged")]
	[Inspectable(category="Size", defaultValue="1.0")]

	/**
	 *  Number that specifies the vertical scaling factor.
	 *
	 *  <p>The default value is 1.0, which means that the object
	 *  is not scaled.
	 *  A <code>scaleY</code> of 2.0 means the object has been
	 *  magnified by a factor of 2, and a <code>scaleY</code> of 0.5
	 *  means the object has been reduced by a factor of 2.</p>
	 *
	 *  <p>A value of 0.0 is an invalid value.
	 *  Rather than setting it to 0.0, set it to a small value, or set
	 *  the <code>visible</code> property to <code>false</code> to hide the component.</p>
	 *
	 *  @default 1.0
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override public function get scaleY():Number
	{
		return (_layoutFeatures == null) ? super.scaleY : _layoutFeatures.layoutScaleY;
	}

	override public function set scaleY(value:Number):void
	{
		var prevValue:Number = (_layoutFeatures == null) ? scaleY : _layoutFeatures.layoutScaleY;
		if (prevValue == value)
		{
			return;
		}

		_hasComplexLayoutMatrix = true;

		if (_layoutFeatures == null)
		{
			super.scaleY = value;
		}
		else
		{
			_layoutFeatures.layoutScaleY = value;
		}
		invalidateTransform();
		invalidateProperties();

		// If we're not compatible with Flex3 (measuredWidth is pre-scale always)
		// and scaleX is changing we need to invalidate parent size and display list
		// since we are not going to detect a change in measured sizes during measure.
		invalidateParentSizeAndDisplayList();

		dispatchEvent(new Event("scaleYChanged"));
	}

	//----------------------------------
	//  scaleZ
	//----------------------------------

	[Bindable("scaleZChanged")]
	[Inspectable(category="Size", defaultValue="1.0")]
	/**
	 *  Number that specifies the scaling factor along the z axis.
	 *
	 *  <p>A scaling along the z axis does not affect a typical component, which lies flat
	 *  in the z=0 plane.  components with children that have 3D transforms applied, or
	 *  components with a non-zero transformZ, is affected.</p>
	 *
	 *  <p>The default value is 1.0, which means that the object
	 *  is not scaled.</p>
	 *
	 *  <p>This property is ignored during calculation by any of Flex's 2D layouts. </p>
	 *
	 *  @default 1.0
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override public function get scaleZ():Number
	{
		return (_layoutFeatures == null) ? super.scaleZ : _layoutFeatures.layoutScaleZ;
	}

	/**
	 * @private
	 */
	override public function set scaleZ(value:Number):void
	{
		if (scaleZ == value)
		{
			return;
		}

		// validateMatrix when switching between 2D/3D, works around player bug
		// see sdk-23421
		var was3D:Boolean = is3D;
		if (_layoutFeatures == null)
		{
			initAdvancedLayoutFeatures();
		}

		_hasComplexLayoutMatrix = true;
		_layoutFeatures.layoutScaleZ = value;
		invalidateTransform();
		invalidateProperties();
		invalidateParentSizeAndDisplayList();
		if (was3D != is3D)
		{
			validateMatrix();
		}
		dispatchEvent(new Event("scaleZChanged"));
	}

	/**
	 *  This property allows access to the Player's native implementation
	 *  of the <code>scaleX</code> property, which can be useful since components
	 *  can override <code>scaleX</code> and thereby hide the native implementation.
	 *  Note that this "base property" is final and cannot be overridden,
	 *  so you can count on it to reflect what is happening at the player level.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	mx_internal final function get $scaleX():Number
	{
		return super.scaleX;
	}

	mx_internal final function set $scaleX(value:Number):void
	{
		super.scaleX = value;
	}

	/**
	 *  This property allows access to the Player's native implementation
	 *  of the <code>scaleY</code> property, which can be useful since components
	 *  can override <code>scaleY</code> and thereby hide the native implementation.
	 *  Note that this "base property" is final and cannot be overridden,
	 *  so you can count on it to reflect what is happening at the player level.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	mx_internal final function get $scaleY():Number
	{
		return super.scaleY;
	}

	mx_internal final function set $scaleY(value:Number):void
	{
		super.scaleY = value;
	}

	//----------------------------------
	//  visible
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the visible property.
	 */
	private var _visible:Boolean = true;

	[Bindable("hide")]
	[Bindable("show")]
	[Inspectable(category="General", defaultValue="true")]

	/**
	 *  Whether or not the display object is visible.
	 *  Display objects that are not visible are disabled.
	 *  For example, if <code>visible=false</code> for an InteractiveObject instance,
	 *  it cannot be clicked.
	 *
	 *  <p>When setting to <code>true</code>, the object dispatches
	 *  a <code>show</code> event.
	 *  When setting to <code>false</code>, the object dispatches
	 *  a <code>hide</code> event.
	 *  In either case the children of the object does not emit a
	 *  <code>show</code> or <code>hide</code> event unless the object
	 *  has specifically written an implementation to do so.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override public function get visible():Boolean
	{
		return _visible;
	}

	override public function set visible(value:Boolean):void
	{
		setVisible(value);
	}

	/**
	 *  Called when the <code>visible</code> property changes.
	 *  Set the <code>visible</code> property to show or hide
	 *  a component instead of calling this method directly.
	 *
	 *  @param value The new value of the <code>visible</code> property.
	 *  Specify <code>true</code> to show the component, and <code>false</code> to hide it.
	 *
	 *  @param noEvent If <code>true</code>, do not dispatch an event.
	 *  If <code>false</code>, dispatch a <code>show</code> event when
	 *  the component becomes visible, and a <code>hide</code> event when
	 *  the component becomes invisible.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function setVisible(value:Boolean, noEvent:Boolean = false):void
	{
		_visible = value;

		if (!initialized || $visible == value)
		{
			return;
		}

		$visible = value;

		if (!noEvent)
		{
			dispatchEvent(new FlexEvent(value ? FlexEvent.SHOW : FlexEvent.HIDE));
		}
	}

	private var _alpha:Number = 1;
	//[Bindable("alphaChanged")]
	[Inspectable(defaultValue="1.0", category="General", verbose="1", minValue="0.0", maxValue="1.0")]

	override public function get alpha():Number
	{
		// Here we roundtrip alpha in the same manner as the
		// player (purposely introducing a rounding error).
		return int(_alpha * 256.0) / 256.0;
	}

	override public function set alpha(value:Number):void
	{
		if (value != _alpha)
		{
			_alpha = value;
			$alpha = value;
			//dispatchEvent(new Event("alphaChanged"));
		}
	}

	//----------------------------------
	//  blendMode
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the blendMode property.
	 */
	private var _blendMode:String = BlendMode.NORMAL;
	private var blendShaderChanged:Boolean;
	private var blendModeChanged:Boolean;

	[Inspectable(category="General", enumeration="add,alpha,darken,difference,erase,hardlight,invert,layer,lighten,multiply,normal,subtract,screen,overlay,colordodge,colorburn,exclusion,softlight,hue,saturation,color,luminosity", defaultValue="normal")]

	override public function get blendMode():String
	{
		return _blendMode;
	}

	override public function set blendMode(value:String):void
	{
		if (_blendMode != value)
		{
			_blendMode = value;
			blendModeChanged = true;

			// If one of the non-native Flash blendModes is set,
			// record the new value and set the appropriate
			// blendShader on the display object.
			if (value == "colordodge" || value == "colorburn" || value == "exclusion" || value == "softlight" || value == "hue" || value == "saturation" || value == "color" || value == "luminosity")
			{
				blendShaderChanged = true;
			}
			invalidateProperties();
		}
	}

	//----------------------------------
	//  doubleClickEnabled
	//----------------------------------

	[Inspectable(enumeration="true,false", defaultValue="true")]

	/**
	 *  Specifies whether the UIComponent object receives <code>doubleClick</code> events.
	 *  The default value is <code>false</code>, which means that the UIComponent object
	 *  does not receive <code>doubleClick</code> events.
	 *
	 *  <p>The <code>mouseEnabled</code> property must also be set to <code>true</code>,
	 *  its default value, for the object to receive <code>doubleClick</code> events.</p>
	 *
	 *  @default false
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override public function get doubleClickEnabled():Boolean
	{
		return super.doubleClickEnabled;
	}

	/**
	 *  @private
	 *  Propagate to children.
	 */
	override public function set doubleClickEnabled(value:Boolean):void
	{
		super.doubleClickEnabled = value;

		for (var i:int = 0; i < this.numChildren; i++)
		{
			var child:InteractiveObject = getChildAt(i) as InteractiveObject;
			if (child)
			{
				child.doubleClickEnabled = value;
			}
		}
	}

	private var _enabled:Boolean = true;
	public function get enabled():Boolean
	{
		return _enabled;
	}

	public function set enabled(value:Boolean):void
	{
		if (value != _enabled)
		{
			_enabled = value;
			invalidateDisplayList();
		}

		//dispatchEvent(new Event("enabledChanged"));
	}

	/**
	 *  Storage for the filters property.
	 */
	private var _filters:Array;

	override public function get filters():Array
	{
		return _filters ? _filters : super.filters;
	}

	override public function set filters(value:Array):void
	{
		var n:int;
		var i:int;
		var e:IEventDispatcher;

		if (_filters)
		{
			n = _filters.length;
			for (i = 0; i < n; i++)
			{
				e = _filters[i] as IEventDispatcher;
				if (e)
				{
					e.removeEventListener(BaseFilter.CHANGE, filterChangeHandler);
				}
			}
		}

		_filters = value;

		var clonedFilters:Array = [];
		if (_filters)
		{
			n = _filters.length;
			for (i = 0; i < n; i++)
			{
				if (_filters[i] is IBitmapFilter)
				{
					e = _filters[i] as IEventDispatcher;
					if (e)
					{
						e.addEventListener(BaseFilter.CHANGE, filterChangeHandler);
					}
					clonedFilters.push(IBitmapFilter(_filters[i]).clone());
				}
				else
				{
					clonedFilters.push(_filters[i]);
				}
			}
		}

		super.filters = clonedFilters;
	}

	//----------------------------------
	//  layer
	//----------------------------------

	public function get designLayer():DesignLayer
	{
		return null;
	}

	public function set designLayer(value:DesignLayer):void
	{
	}

	//--------------------------------------------------------------------------
	//
	//  Properties: Display
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  $alpha
	//----------------------------------

	/**
	 *  @private
	 *  This property allows access to the Player's native implementation
	 *  of the 'alpha' property, which can be useful since components
	 *  can override 'alpha' and thereby hide the native implementation.
	 *  Note that this "base property" is final and cannot be overridden,
	 *  so you can count on it to reflect what is happening at the player level.
	 */
	mx_internal final function get $alpha():Number
	{
		return super.alpha;
	}

	mx_internal final function set $alpha(value:Number):void
	{
		super.alpha = value;
	}

	//----------------------------------
	//  $blendMode
	//----------------------------------

	/**
	 *  @private
	 *  This property allows access to the Player's native implementation
	 *  of the 'blendMode' property, which can be useful since components
	 *  can override 'alpha' and thereby hide the native implementation.
	 *  Note that this "base property" is final and cannot be overridden,
	 *  so you can count on it to reflect what is happening at the player level.
	 */
	mx_internal final function get $blendMode():String
	{
		return super.blendMode;
	}

	/**
	 *  @private
	 */
	mx_internal final function set $blendMode(value:String):void
	{
		super.blendMode = value;
	}

	//----------------------------------
	//  $blendShader
	//----------------------------------

	/**
	 *  @private
	 */
	mx_internal final function set $blendShader(value:Shader):void
	{
		super.blendShader = value;
	}

	//----------------------------------
	//  $parent
	//----------------------------------

	/**
	 *  @private
	 *  This property allows access to the Player's native implementation
	 *  of the 'parent' property, which can be useful since components
	 *  can override 'parent' and thereby hide the native implementation.
	 *  Note that this "base property" is final and cannot be overridden,
	 *  so you can count on it to reflect what is happening at the player level.
	 */
	mx_internal final function get $parent():DisplayObjectContainer
	{
		return super.parent;
	}

	//----------------------------------
	//  $x
	//----------------------------------

	/**
	 *  @private
	 *  This property allows access to the Player's native implementation
	 *  of the 'x' property, which can be useful since components
	 *  can override 'x' and thereby hide the native implementation.
	 *  Note that this "base property" is final and cannot be overridden,
	 *  so you can count on it to reflect what is happening at the player level.
	 */
	mx_internal final function get $x():Number
	{
		return super.x;
	}

	/**
	 *  @private
	 */
	mx_internal final function set $x(value:Number):void
	{
		super.x = value;
	}

	//----------------------------------
	//  $y
	//----------------------------------

	/**
	 *  @private
	 *  This property allows access to the Player's native implementation
	 *  of the 'y' property, which can be useful since components
	 *  can override 'y' and thereby hide the native implementation.
	 *  Note that this "base property" is final and cannot be overridden,
	 *  so you can count on it to reflect what is happening at the player level.
	 */
	mx_internal final function get $y():Number
	{
		return super.y;
	}

	/**
	 *  @private
	 */
	mx_internal final function set $y(value:Number):void
	{
		super.y = value;
	}

	//----------------------------------
	//  $width
	//----------------------------------

	/**
	 *  @private
	 *  This property allows access to the Player's native implementation
	 *  of the 'width' property, which can be useful since components
	 *  can override 'width' and thereby hide the native implementation.
	 *  Note that this "base property" is final and cannot be overridden,
	 *  so you can count on it to reflect what is happening at the player level.
	 */
	mx_internal final function get $width():Number
	{
		return super.width;
	}

	/**
	 *  @private
	 */
	mx_internal final function set $width(value:Number):void
	{
		super.width = value;
	}

	//----------------------------------
	//  $height
	//----------------------------------

	/**
	 *  @private
	 *  This property allows access to the Player's native implementation
	 *  of the 'height' property, which can be useful since components
	 *  can override 'height' and thereby hide the native implementation.
	 *  Note that this "base property" is final and cannot be overridden,
	 *  so you can count on it to reflect what is happening at the player level.
	 */
	mx_internal final function get $height():Number
	{
		return super.height;
	}

	/**
	 *  @private
	 */
	mx_internal final function set $height(value:Number):void
	{
		super.height = value;
	}

	//----------------------------------
	//  $visible
	//----------------------------------

	/**
	 *  @private
	 *  This property allows access to the Player's native implementation
	 *  of the 'visible' property, which can be useful since components
	 *  can override 'visible' and thereby hide the native implementation.
	 *  Note that this "base property" is final and cannot be overridden,
	 *  so you can count on it to reflect what is happening at the player level.
	 */
	mx_internal final function get $visible():Boolean
	{
		return super.visible;
	}

	/**
	 *  @private
	 */
	mx_internal final function set $visible(value:Boolean):void
	{
		super.visible = value;
	}

	//----------------------------------
	//  tweeningProperties
	//----------------------------------

	/**
	 *  @private
	 */
	private var _tweeningProperties:Array;

	[Inspectable(environment="none")]

	/**
	 *  Array of properties that are currently being tweened on this object.
	 *
	 *  <p>Used to alert the EffectManager that certain properties of this object
	 *  are being tweened, so that the EffectManger doesn't attempt to animate
	 *  the same properties.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get tweeningProperties():Array
	{
		return _tweeningProperties;
	}

	/**
	 *  @private
	 */
	public function set tweeningProperties(value:Array):void
	{
		_tweeningProperties = value;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties: Manager access
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  cursorManager
	//----------------------------------

	/**
	 *  Gets the CursorManager that controls the cursor for this component
	 *  and its peers.
	 *  Each top-level window has its own instance of a CursorManager;
	 *  To make sure you're talking to the right one, use this method.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get cursorManager():ICursorManager
	{
		var o:DisplayObject = parent;

		while (o)
		{
			if (o is IUIComponent && "cursorManager" in o)
			{
				return o["cursorManager"];
			}

			o = o.parent;
		}

		return CursorManager.getInstance();
	}

	//----------------------------------
	//  focusManager
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the focusManager property.
	 */
	private var _focusManager:IFocusManager;

	[Inspectable(environment="none")]

	/**
	 *  Gets the FocusManager that controls focus for this component
	 *  and its peers.
	 *  Each popup has its own focus loop and therefore its own instance
	 *  of a FocusManager.
	 *  To make sure you're talking to the right one, use this method.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get focusManager():IFocusManager
	{
		if (_focusManager)
		{
			return _focusManager;
		}

		var o:DisplayObject = parent;

		while (o)
		{
			if (o is IFocusManagerContainer)
			{
				return IFocusManagerContainer(o).focusManager;
			}

			o = o.parent;
		}

		return null;
	}

	/**
	 *  @private
	 *  IFocusManagerContainers have this property assigned by the framework
	 */
	public function set focusManager(value:IFocusManager):void
	{
		_focusManager = value;
		dispatchEvent(new FlexEvent(FlexEvent.ADD_FOCUS_MANAGER));
	}

	//----------------------------------
	//  systemManager
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the systemManager property.
	 *  Set by the SystemManager so that each UIComponent
	 *  has a references to its SystemManager
	 */
	private var _systemManager:ISystemManager;

	/**
	 *  @private
	 *  if component has been reparented, we need to potentially
	 *  reassign systemManager, cause we could be in a new Window.
	 */
	private var _systemManagerDirty:Boolean = false;

	[Inspectable(environment="none")]

	/**
	 *  Returns the SystemManager object used by this component.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get systemManager():ISystemManager
	{
		if (!_systemManager || _systemManagerDirty)
		{
			var r:DisplayObject = root;
			if (_systemManager && _systemManager.isProxy)
			{
				// keep the existing proxy
			}
			else if (r && !(r is Stage))
			{
				// If this object is attached to the display list, then
				// the root property holds its SystemManager.
				_systemManager = (r as ISystemManager);
			}
			else if (r)
			{
				// if the root is the Stage, then we are in a second AIR window
				_systemManager = Stage(r).getChildAt(0) as ISystemManager;
			}
			else
			{
				// If this object isn't attached to the display list, then
				// we need to walk up the parent chain ourselves.
				var o:DisplayObjectContainer = parent;
				while (o)
				{
					var ui:IUIComponent = o as IUIComponent;
					if (ui)
					{
						_systemManager = ui.systemManager;
						break;
					}
					else if (o is ISystemManager)
					{
						_systemManager = o as ISystemManager;
						break;
					}
					o = o.parent;
				}
			}
			_systemManagerDirty = false;
		}

		return _systemManager;
	}

	public function set systemManager(value:ISystemManager):void
	{
		_systemManager = value;
		_systemManagerDirty = false;
	}

	/**
	 *  @private
	 *  Returns the current system manager, <code>systemManager</code>,
	 *  unless it is null.
	 *  If the current system manager is null,
	 *  then search to find the correct system manager.
	 *
	 *  @return A system manager. This value is never null.
	 */
	mx_internal function getNonNullSystemManager():ISystemManager
	{
		var sm:ISystemManager = systemManager;

//		if (!sm) subapp не поддерживаем
//		{
//			sm = ISystemManager(SystemManager.getSWFRoot(this));
//		}

		if (!sm)
		{
			return SystemManagerGlobals.topLevelSystemManagers[0];
		}

		return sm;
	}

	/**
	 *  @private
	 */
	protected function invalidateSystemManager():void
	{
		var n:int = numChildren;
		for (var i:int = 0; i < n; i++)
		{
			var child:AbstractView = getChildAt(i) as AbstractView;
			if (child)
			{
				child.invalidateSystemManager();
			}
		}
		_systemManagerDirty = true;
	}

	private var _nestLevel:int = 0;

	[Inspectable(environment="none")]
	public function get nestLevel():int
	{
		return _nestLevel;
	}

	public function set nestLevel(value:int):void
	{
		// If my parent hasn't been attached to the display list, then its nestLevel
		// will be zero.  If it tries to set my nestLevel to 1, ignore it.  We'll
		// update nest levels again after the parent is added to the display list.
		//
		// Also punt if the new value for nestLevel is the same as my current value.
		if (value > 1 && _nestLevel != value)
		{
			_nestLevel = value;

			updateCallbacks();

			var n:int = numChildren;
			for (var i:int = 0; i < n; i++)
			{
				var ui:ILayoutManagerClient = getChildAt(i) as ILayoutManagerClient;
				if (ui)
				{
					ui.nestLevel = value + 1;
				}
			}
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Properties: MXML
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  document
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the document property.
	 *  This variable is initialized in the init() method.
	 *  A document object (i.e., an Object at the top of the hierarchy
	 *  of a Flex application, MXML component, or AS component) has an
	 *  autogenerated override of initalize() which sets its _document to
	 *  'this', so that its 'document' property is a reference to itself.
	 *  Other UIComponents set their _document to their parent's _document,
	 *  so that their 'document' property refers to the document object
	 *  that they are inside.
	 */
	mx_internal var _document:Object;

	[Inspectable(environment="none")]

	/**
	 *  A reference to the document object associated with this UIComponent.
	 *  A document object is an Object at the top of the hierarchy of a
	 *  Flex application, MXML component, or AS component.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get document():Object
	{
		return _document;
	}

	/**
	 *  A reference to the document object associated with this UIComponent.
	 *  A document object is an Object at the top of the hierarchy of a
	 *  Flex application, MXML component, or AS component.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function set document(value:Object):void
	{
		var n:int = numChildren;
		for (var i:int = 0; i < n; i++)
		{
			var child:IUIComponent = getChildAt(i) as IUIComponent;
			if (!child)
			{
				continue;
			}

			if (child.document == _document || child.document == FlexGlobals.topLevelApplication)
			{
				child.document = value;
			}
		}

		_document = value;
	}

	//----------------------------------
	//  id
	//----------------------------------

	/**
	 *  @private
	 */
	private var _id:String;

	/**
	 *  ID of the component. This value becomes the instance name of the object
	 *  and should not contain any white space or special characters. Each component
	 *  throughout an application should have a unique id.
	 *
	 *  <p>If your application is going to be tested by third party tools, give each component
	 *  a meaningful id. Testing tools use ids to represent the control in their scripts and
	 *  having a meaningful name can make scripts more readable. For example, set the
	 *  value of a button to submit_button rather than b1 or button1.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get id():String
	{
		return _id;
	}

	/**
	 *  @private
	 */
	public function set id(value:String):void
	{
		_id = value;
	}

	//----------------------------------
	//  isDocument
	//----------------------------------

	/**
	 *  Contains <code>true</code> if this UIComponent instance is a document object.
	 *  That means it is at the top of the hierarchy of a Flex
	 *  application, MXML component, or ActionScript component.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get isDocument():Boolean
	{
		return document == this;
	}

	//----------------------------------
	//  parentDocument
	//----------------------------------

	[Bindable("initialize")]

	/**
	 *  A reference to the parent document object for this UIComponent.
	 *  A document object is a UIComponent at the top of the hierarchy
	 *  of a Flex application, MXML component, or AS component.
	 *
	 *  <p>For the Application object, the <code>parentDocument</code>
	 *  property is null.
	 *  This property  is useful in MXML scripts to go up a level
	 *  in the chain of document objects.
	 *  It can be used to walk this chain using
	 *  <code>parentDocument.parentDocument</code>, and so on.</p>
	 *
	 *  <p>It is typed as Object so that authors can access properties
	 *  and methods on ancestor document objects without casting.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get parentDocument():Object
	{
		if (document == this)
		{
			var p:IUIComponent = parent as IUIComponent;
			if (p)
			{
				return p.document;
			}

			var sm:ISystemManager = parent as ISystemManager;
			if (sm)
			{
				return sm.document;
			}

			return null;
		}
		else
		{
			return document;
		}
	}

	//----------------------------------
	//  screen
	//----------------------------------

	/**
	 *  Returns an object that contains the size and position of the base
	 *  drawing surface for this object.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get screen():Rectangle
	{
		var sm:ISystemManager = systemManager;
		return sm ? sm.screen : null;
	}

	/**
	 *  Storage for the moduleFactory property.
	 */
	private var _moduleFactory:IFlexModuleFactory;

	[Inspectable(environment="none")]

	/**
	 *  A module factory is used as context for using embedded fonts and for
	 *  finding the style manager that controls the styles for this
	 *  component.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get moduleFactory():IFlexModuleFactory
	{
		return _moduleFactory;
	}

	public function set moduleFactory(factory:IFlexModuleFactory):void
	{
		var n:int = numChildren;
		for (var i:int = 0; i < n; i++)
		{
			var child:IFlexModule = getChildAt(i) as IFlexModule;
			if (!child)
			{
				continue;
			}

			if (child.moduleFactory == null || child.moduleFactory == _moduleFactory)
			{
				child.moduleFactory = factory;
			}
		}

		_moduleFactory = factory;
	}

	/**
	 *  Storage for the focusPane property.
	 */
	private var _focusPane:Sprite;

	[Inspectable(environment="none")]

	/**
	 *  The focus pane associated with this object.
	 *  An object has a focus pane when one of its children has focus.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get focusPane():Sprite
	{
		return _focusPane;
	}

	public function set focusPane(value:Sprite):void
	{
		if (value)
		{
			addChild(value);

			value.x = 0;
			value.y = 0;
			value.scrollRect = null;

			_focusPane = value;
		}
		else
		{
			removeChild(_focusPane);

			_focusPane.mask = null;
			_focusPane = null;
		}
	}

	//----------------------------------
	//  focusEnabled
	//----------------------------------

	/**
	 *  Storage for the focusEnabled property.
	 */
	private var _focusEnabled:Boolean = true;

	[Inspectable(defaultValue="true")]

	/**
	 *  Indicates whether the component can receive focus when tabbed to.
	 *  You can set <code>focusEnabled</code> to <code>false</code>
	 *  when a UIComponent is used as a subcomponent of another component
	 *  so that the outer component becomes the focusable entity.
	 *  If this property is <code>false</code>, focus is transferred to
	 *  the first parent that has <code>focusEnable</code>
	 *  set to <code>true</code>.
	 *
	 *  <p>The default value is <code>true</code>, except for the
	 *  spark.components.Scroller component.
	 *  For that component, the default value is <code>false</code>.</p>
	 *
	 *  @see spark.components.Scroller
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get focusEnabled():Boolean
	{
		return _focusEnabled;
	}

	/**
	 *  @private
	 */
	public function set focusEnabled(value:Boolean):void
	{
		_focusEnabled = value;
	}

	//----------------------------------
	//  hasFocusableChildren
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the hasFocusableChildren property.
	 */
	private var _hasFocusableChildren:Boolean = false;

	[Bindable("hasFocusableChildrenChange")]
	[Inspectable(defaultValue="false")]

	/**
	 *  A flag that indicates whether child objects can receive focus.
	 *
	 *  <p><b>Note: </b>This property is similar to the <code>tabChildren</code> property
	 *  used by Flash Player.
	 *  Use the <code>hasFocusableChildren</code> property with Flex applications.
	 *  Do not use the <code>tabChildren</code> property.</p>
	 *
	 *  <p>This property is usually <code>false</code> because most components
	 *  either receive focus themselves or delegate focus to a single
	 *  internal sub-component and appear as if the component has
	 *  received focus.
	 *  For example, a TextInput control contains a focusable
	 *  child RichEditableText control, but while the RichEditableText
	 *  sub-component actually receives focus, it appears as if the
	 *  TextInput has focus. TextInput sets <code>hasFocusableChildren</code>
	 *  to <code>false</code> because TextInput is considered the
	 *  component that has focus. Its internal structure is an
	 *  abstraction.</p>
	 *
	 *  <p>Usually only navigator components, such as TabNavigator and
	 *  Accordion, have this flag set to <code>true</code> because they
	 *  receive focus on Tab but focus goes to components in the child
	 *  containers on further Tabs.</p>
	 *
	 *  <p>The default value is <code>false</code>, except for the
	 *  spark.components.Scroller component.
	 *  For that component, the default value is <code>true</code>.</p>
	 *
	 *  @see spark.components.Scroller
	 *
	 *  @langversion 4.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get hasFocusableChildren():Boolean
	{
		return _hasFocusableChildren;
	}

	/**
	 *  @private
	 */
	public function set hasFocusableChildren(value:Boolean):void
	{
		if (value != _hasFocusableChildren)
		{
			_hasFocusableChildren = value;
			dispatchEvent(new Event("hasFocusableChildrenChange"));
		}
	}

	//----------------------------------
	//  mouseFocusEnabled
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the mouseFocusEnabled property.
	 */
	private var _mouseFocusEnabled:Boolean = true;

	[Inspectable(defaultValue="true")]

	/**
	 *  Whether you can receive focus when clicked on.
	 *  If <code>false</code>, focus is transferred to
	 *  the first parent that is <code>mouseFocusEnable</code>
	 *  set to <code>true</code>.
	 *  For example, you can set this property to <code>false</code>
	 *  on a Button control so that you can use the Tab key to move focus
	 *  to the control, but not have the control get focus when you click on it.
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get mouseFocusEnabled():Boolean
	{
		return _mouseFocusEnabled;
	}

	/**
	 *  @private
	 */
	public function set mouseFocusEnabled(value:Boolean):void
	{
		_mouseFocusEnabled = value;
	}

	/**
	 *  Storage for the tabFocusEnabled property.
	 */
	private var _tabFocusEnabled:Boolean = true;

	[Bindable("tabFocusEnabledChange")]
	[Inspectable(defaultValue="true")]

	/**
	 *  A flag that indicates whether this object can receive focus
	 *  via the TAB key
	 *
	 *  <p>This is similar to the <code>tabEnabled</code> property
	 *  used by the Flash Player.</p>
	 *
	 *  <p>This is usually <code>true</code> for components that
	 *  handle keyboard input, but some components in controlbars
	 *  have them set to <code>false</code> because they should not steal
	 *  focus from another component like an editor.
	 *  </p>
	 *
	 *  @default true
	 *
	 *  @langversion 4.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get tabFocusEnabled():Boolean
	{
		return _tabFocusEnabled;
	}

	/**
	 *  @private
	 */
	public function set tabFocusEnabled(value:Boolean):void
	{
		if (value != _tabFocusEnabled)
		{
			_tabFocusEnabled = value;
			dispatchEvent(new Event("tabFocusEnabledChange"));
		}
	}

	/**
	 *  Storage for the measuredMinWidth property.
	 */
	private var _measuredMinWidth:Number = 0;

	[Inspectable(environment="none")]

	/**
	 *  The default minimum width of the component, in pixels.
	 *  This value is set by the <code>measure()</code> method.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get measuredMinWidth():Number
	{
		return _measuredMinWidth;
	}
	public function set measuredMinWidth(value:Number):void
	{
		_measuredMinWidth = value;
	}

	/**
	 *  Storage for the measuredMinHeight property.
	 */
	private var _measuredMinHeight:Number = 0;

	[Inspectable(environment="none")]

	/**
	 *  The default minimum height of the component, in pixels.
	 *  This value is set by the <code>measure()</code> method.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get measuredMinHeight():Number
	{
		return _measuredMinHeight;
	}

	/**
	 *  @private
	 */
	public function set measuredMinHeight(value:Number):void
	{
		_measuredMinHeight = value;
	}

	//----------------------------------
	//  measuredWidth
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the measuredWidth property.
	 */
	private var _measuredWidth:Number = 0;

	[Inspectable(environment="none")]

	/**
	 *  The default width of the component, in pixels.
	 *  This value is set by the <code>measure()</code> method.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get measuredWidth():Number
	{
		return _measuredWidth;
	}

	/**
	 *  @private
	 */
	public function set measuredWidth(value:Number):void
	{
		_measuredWidth = value;
	}

	//----------------------------------
	//  measuredHeight
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the measuredHeight property.
	 */
	private var _measuredHeight:Number = 0;

	[Inspectable(environment="none")]

	/**
	 *  The default height of the component, in pixels.
	 *  This value is set by the <code>measure()</code> method.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get measuredHeight():Number
	{
		return _measuredHeight;
	}

	/**
	 *  @private
	 */
	public function set measuredHeight(value:Number):void
	{
		_measuredHeight = value;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties: Layout
	//
	//--------------------------------------------------------------------------

	[Bindable("resize")]
	[Inspectable(environment="none")]

	/**
	 *  Specifies the width of a component as a percentage
	 *  of its parent's size. Allowed values are 0-100. The default value is NaN.
	 *  Setting the <code>width</code> or <code>explicitWidth</code> properties
	 *  resets this property to NaN.
	 *
	 *  <p>This property returns a numeric value only if the property was
	 *  previously set; it does not reflect the exact size of the component
	 *  in percent.</p>
	 *
	 *  <p>This property is always set to NaN for the UITextField control.</p>
	 *
	 *  <p>When used with Spark layouts, this property is used to calculate the
	 *  width of the component's bounds after scaling and rotation. For example
	 *  if the component is rotated at 90 degrees, then specifying
	 *  <code>percentWidth</code> will affect the component's height.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get percentWidth():Number
	{
		return _layoutMetrics.percentWidth;
	}

	/**
	 *  @private
	 */
	public function set percentWidth(value:Number):void
	{
		if (_layoutMetrics.percentWidth == value)
		{
			return;
		}

		if (!isNaN(value))
		{
			_layoutMetrics.width = NaN;
		}

		_layoutMetrics.percentWidth = value;

		invalidateParentSizeAndDisplayList();
	}

	[Bindable("resize")]
	[Inspectable(environment="none")]

	/**
	 *  Specifies the height of a component as a percentage
	 *  of its parent's size. Allowed values are 0-100. The default value is NaN.
	 *  Setting the <code>height</code> or <code>explicitHeight</code> properties
	 *  resets this property to NaN.
	 *
	 *  <p>This property returns a numeric value only if the property was
	 *  previously set; it does not reflect the exact size of the component
	 *  in percent.</p>
	 *
	 *  <p>This property is always set to NaN for the UITextField control.</p>
	 *
	 *  <p>When used with Spark layouts, this property is used to calculate the
	 *  height of the component's bounds after scaling and rotation. For example
	 *  if the component is rotated at 90 degrees, then specifying
	 *  <code>percentHeight</code> will affect the component's width.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get percentHeight():Number
	{
		return _layoutMetrics.percentHeight;
	}

	/**
	 *  @private
	 */
	public function set percentHeight(value:Number):void
	{
		if (_layoutMetrics.percentHeight == value)
		{
			return;
		}

		if (!isNaN(value))
		{
			_layoutMetrics.height = NaN;
		}

		_layoutMetrics.percentHeight = value;

		invalidateParentSizeAndDisplayList();
	}

	//----------------------------------
	//  minWidth
	//----------------------------------

	[Bindable("explicitMinWidthChanged")]
	[Inspectable(category="Size", defaultValue="0")]

	/**
	 *  The minimum recommended width of the component to be considered
	 *  by the parent during layout. This value is in the
	 *  component's coordinates, in pixels. The default value depends on
	 *  the component's implementation.
	 *
	 *  <p>If the application developer sets the value of minWidth,
	 *  the new value is stored in explicitMinWidth. The default value of minWidth
	 *  does not change. As a result, at layout time, if
	 *  minWidth was explicitly set by the application developer, then the value of
	 *  explicitMinWidth is used for the component's minimum recommended width.
	 *  If minWidth is not set explicitly by the application developer, then the value of
	 *  measuredMinWidth is used.</p>
	 *
	 *  <p>This value is used by the container in calculating
	 *  the size and position of the component.
	 *  It is not used by the component itself in determining
	 *  its default size.
	 *  Thus this property may not have any effect if parented by
	 *  Container, or containers that don't factor in
	 *  this property.
	 *  Because the value is in component coordinates,
	 *  the true <code>minWidth</code> with respect to its parent
	 *  is affected by the <code>scaleX</code> property.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */ public function get minWidth():Number
	{
		if (!isNaN(explicitMinWidth))
		{
			return explicitMinWidth;
		}

		return measuredMinWidth;
	}

	/**
	 *  @private
	 */
	public function set minWidth(value:Number):void
	{
		if (explicitMinWidth == value)
		{
			return;
		}

		explicitMinWidth = value;
	}

	//----------------------------------
	//  minHeight
	//----------------------------------

	[Bindable("explicitMinHeightChanged")]
	[Inspectable(category="Size", defaultValue="0")]

	/**
	 *  The minimum recommended height of the component to be considered
	 *  by the parent during layout. This value is in the
	 *  component's coordinates, in pixels. The default value depends on
	 *  the component's implementation.
	 *
	 *  <p>If the application developer sets the value of minHeight,
	 *  the new value is stored in explicitMinHeight. The default value of minHeight
	 *  does not change. As a result, at layout time, if
	 *  minHeight was explicitly set by the application developer, then the value of
	 *  explicitMinHeight is used for the component's minimum recommended height.
	 *  If minHeight is not set explicitly by the application developer, then the value of
	 *  measuredMinHeight is used.</p>
	 *
	 *  <p>This value is used by the container in calculating
	 *  the size and position of the component.
	 *  It is not used by the component itself in determining
	 *  its default size.
	 *  Thus this property may not have any effect if parented by
	 *  Container, or containers that don't factor in
	 *  this property.
	 *  Because the value is in component coordinates,
	 *  the true <code>minHeight</code> with respect to its parent
	 *  is affected by the <code>scaleY</code> property.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */ public function get minHeight():Number
	{
		if (!isNaN(explicitMinHeight))
		{
			return explicitMinHeight;
		}

		return measuredMinHeight;
	}

	/**
	 *  @private
	 */
	public function set minHeight(value:Number):void
	{
		if (explicitMinHeight == value)
		{
			return;
		}

		explicitMinHeight = value;
	}

	//----------------------------------
	//  maxWidth
	//----------------------------------

	[Bindable("explicitMaxWidthChanged")]
	[Inspectable(category="Size", defaultValue="10000")]

	/**
	 *  The maximum recommended width of the component to be considered
	 *  by the parent during layout. This value is in the
	 *  component's coordinates, in pixels. The default value of this property is
	 *  set by the component developer.
	 *
	 *  <p>The component developer uses this property to set an upper limit on the
	 *  width of the component.</p>
	 *
	 *  <p>If the application developer overrides the default value of maxWidth,
	 *  the new value is stored in explicitMaxWidth. The default value of maxWidth
	 *  does not change. As a result, at layout time, if
	 *  maxWidth was explicitly set by the application developer, then the value of
	 *  explicitMaxWidth is used for the component's maximum recommended width.
	 *  If maxWidth is not set explicitly by the user, then the default value is used.</p>
	 *
	 *  <p>This value is used by the container in calculating
	 *  the size and position of the component.
	 *  It is not used by the component itself in determining
	 *  its default size.
	 *  Thus this property may not have any effect if parented by
	 *  Container, or containers that don't factor in
	 *  this property.
	 *  Because the value is in component coordinates,
	 *  the true <code>maxWidth</code> with respect to its parent
	 *  is affected by the <code>scaleX</code> property.
	 *  Some components have no theoretical limit to their width.
	 *  In those cases their <code>maxWidth</code> is set to
	 *  <code>UIComponent.DEFAULT_MAX_WIDTH</code>.</p>
	 *
	 *  @default 10000
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */ public function get maxWidth():Number
	{
		return !isNaN(explicitMaxWidth) ? explicitMaxWidth : DEFAULT_MAX_WIDTH;
	}

	/**
	 *  @private
	 */
	public function set maxWidth(value:Number):void
	{
		if (explicitMaxWidth == value)
		{
			return;
		}

		explicitMaxWidth = value;
	}

	//----------------------------------
	//  maxHeight
	//----------------------------------

	[Bindable("explicitMaxHeightChanged")]
	[Inspectable(category="Size", defaultValue="10000")]

	/**
	 *  The maximum recommended height of the component to be considered
	 *  by the parent during layout. This value is in the
	 *  component's coordinates, in pixels. The default value of this property is
	 *  set by the component developer.
	 *
	 *  <p>The component developer uses this property to set an upper limit on the
	 *  height of the component.</p>
	 *
	 *  <p>If the application developer overrides the default value of maxHeight,
	 *  the new value is stored in explicitMaxHeight. The default value of maxHeight
	 *  does not change. As a result, at layout time, if
	 *  maxHeight was explicitly set by the application developer, then the value of
	 *  explicitMaxHeight is used for the component's maximum recommended height.
	 *  If maxHeight is not set explicitly by the user, then the default value is used.</p>
	 *
	 *  <p>This value is used by the container in calculating
	 *  the size and position of the component.
	 *  It is not used by the component itself in determining
	 *  its default size.
	 *
	 *  Thus this property may not have any effect if parented by
	 *  Container, or containers that don't factor in
	 *  this property.
	 *  Because the value is in component coordinates,
	 *  the true <code>maxHeight</code> with respect to its parent
	 *  is affected by the <code>scaleY</code> property.
	 *  Some components have no theoretical limit to their height.
	 *  In those cases their <code>maxHeight</code> is set to
	 *  <code>UIComponent.DEFAULT_MAX_HEIGHT</code>.</p>
	 *
	 *  @default 10000
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */ public function get maxHeight():Number
	{
		return !isNaN(explicitMaxHeight) ? explicitMaxHeight : DEFAULT_MAX_HEIGHT;
	}

	/**
	 *  @private
	 */
	public function set maxHeight(value:Number):void
	{
		if (explicitMaxHeight == value)
		{
			return;
		}

		explicitMaxHeight = value;
	}

	//----------------------------------
	//  explicitMinWidth
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the minWidth property.
	 */
	mx_internal var _explicitMinWidth:Number;

	[Bindable("explicitMinWidthChanged")]
	[Inspectable(environment="none")]

	/**
	 *  The minimum recommended width of the component to be considered
	 *  by the parent during layout. This value is in the
	 *  component's coordinates, in pixels.
	 *
	 *  <p>Application developers typically do not set the explicitMinWidth property. Instead, they
	 *  set the value of the minWidth property, which sets the explicitMinWidth property. The
	 *  value of minWidth does not change.</p>
	 *
	 *  <p>At layout time, if minWidth was explicitly set by the application developer, then
	 *  the value of explicitMinWidth is used. Otherwise, the value of measuredMinWidth
	 *  is used.</p>
	 *
	 *  <p>This value is used by the container in calculating
	 *  the size and position of the component.
	 *  It is not used by the component itself in determining
	 *  its default size.
	 *  Thus this property may not have any effect if parented by
	 *  Container, or containers that don't factor in
	 *  this property.
	 *  Because the value is in component coordinates,
	 *  the true <code>minWidth</code> with respect to its parent
	 *  is affected by the <code>scaleX</code> property.</p>
	 *
	 *  @default NaN
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get explicitMinWidth():Number
	{
		return _explicitMinWidth;
	}

	/**
	 *  @private
	 */
	public function set explicitMinWidth(value:Number):void
	{
		if (_explicitMinWidth == value)
		{
			return;
		}

		_explicitMinWidth = value;

		// We invalidate size because locking in width
		// may change the measured height in flow-based components.
		invalidateSize();
		invalidateParentSizeAndDisplayList();

		dispatchEvent(new Event("explicitMinWidthChanged"));
	}

	//----------------------------------
	//  minHeight
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the minHeight property.
	 */
	mx_internal var _explicitMinHeight:Number;

	[Bindable("explictMinHeightChanged")]
	[Inspectable(environment="none")]

	/**
	 *  The minimum recommended height of the component to be considered
	 *  by the parent during layout. This value is in the
	 *  component's coordinates, in pixels.
	 *
	 *  <p>Application developers typically do not set the explicitMinHeight property. Instead, they
	 *  set the value of the minHeight property, which sets the explicitMinHeight property. The
	 *  value of minHeight does not change.</p>
	 *
	 *  <p>At layout time, if minHeight was explicitly set by the application developer, then
	 *  the value of explicitMinHeight is used. Otherwise, the value of measuredMinHeight
	 *  is used.</p>
	 *
	 *  <p>This value is used by the container in calculating
	 *  the size and position of the component.
	 *  It is not used by the component itself in determining
	 *  its default size.
	 *  Thus this property may not have any effect if parented by
	 *  Container, or containers that don't factor in
	 *  this property.
	 *  Because the value is in component coordinates,
	 *  the true <code>minHeight</code> with respect to its parent
	 *  is affected by the <code>scaleY</code> property.</p>
	 *
	 *  @default NaN
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */ public function get explicitMinHeight():Number
	{
		return _explicitMinHeight;
	}

	/**
	 *  @private
	 */
	public function set explicitMinHeight(value:Number):void
	{
		if (_explicitMinHeight == value)
		{
			return;
		}

		_explicitMinHeight = value;

		// We invalidate size because locking in height
		// may change the measured width in flow-based components.
		invalidateSize();
		invalidateParentSizeAndDisplayList();

		dispatchEvent(new Event("explicitMinHeightChanged"));
	}

	//----------------------------------
	//  explicitMaxWidth
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the maxWidth property.
	 */
	mx_internal var _explicitMaxWidth:Number;

	[Bindable("explicitMaxWidthChanged")]
	[Inspectable(environment="none")]

	/**
	 *  The maximum recommended width of the component to be considered
	 *  by the parent during layout. This value is in the
	 *  component's coordinates, in pixels.
	 *
	 *  <p>Application developers typically do not set the explicitMaxWidth property. Instead, they
	 *  set the value of the maxWidth property, which sets the explicitMaxWidth property. The
	 *  value of maxWidth does not change.</p>
	 *
	 *  <p>At layout time, if maxWidth was explicitly set by the application developer, then
	 *  the value of explicitMaxWidth is used. Otherwise, the default value for maxWidth
	 *  is used.</p>
	 *
	 *  <p>This value is used by the container in calculating
	 *  the size and position of the component.
	 *  It is not used by the component itself in determining
	 *  its default size.
	 *  Thus this property may not have any effect if parented by
	 *  Container, or containers that don't factor in
	 *  this property.
	 *  Because the value is in component coordinates,
	 *  the true <code>maxWidth</code> with respect to its parent
	 *  is affected by the <code>scaleX</code> property.
	 *  Some components have no theoretical limit to their width.
	 *  In those cases their <code>maxWidth</code> is set to
	 *  <code>UIComponent.DEFAULT_MAX_WIDTH</code>.</p>
	 *
	 *  @default NaN
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */ public function get explicitMaxWidth():Number
	{
		return _explicitMaxWidth;
	}

	/**
	 *  @private
	 */
	public function set explicitMaxWidth(value:Number):void
	{
		if (_explicitMaxWidth == value)
		{
			return;
		}

		_explicitMaxWidth = value;

		// Se invalidate size because locking in width
		// may change the measured height in flow-based components.
		invalidateSize();
		invalidateParentSizeAndDisplayList();

		dispatchEvent(new Event("explicitMaxWidthChanged"));
	}

	//----------------------------------
	//  explicitMaxHeight
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the maxHeight property.
	 */
	mx_internal var _explicitMaxHeight:Number;

	[Bindable("explicitMaxHeightChanged")]
	[Inspectable(environment="none")]

	/**
	 *  The maximum recommended height of the component to be considered
	 *  by the parent during layout. This value is in the
	 *  component's coordinates, in pixels.
	 *
	 *  <p>Application developers typically do not set the explicitMaxHeight property. Instead, they
	 *  set the value of the maxHeight property, which sets the explicitMaxHeight property. The
	 *  value of maxHeight does not change.</p>
	 *
	 *  <p>At layout time, if maxHeight was explicitly set by the application developer, then
	 *  the value of explicitMaxHeight is used. Otherwise, the default value for maxHeight
	 *  is used.</p>
	 *
	 *  <p>This value is used by the container in calculating
	 *  the size and position of the component.
	 *  It is not used by the component itself in determining
	 *  its default size.
	 *  Thus this property may not have any effect if parented by
	 *  Container, or containers that don't factor in
	 *  this property.
	 *  Because the value is in component coordinates,
	 *  the true <code>maxHeight</code> with respect to its parent
	 *  is affected by the <code>scaleY</code> property.
	 *  Some components have no theoretical limit to their height.
	 *  In those cases their <code>maxHeight</code> is set to
	 *  <code>UIComponent.DEFAULT_MAX_HEIGHT</code>.</p>
	 *
	 *  @default NaN
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */ public function get explicitMaxHeight():Number
	{
		return _explicitMaxHeight;
	}

	/**
	 *  @private
	 */
	public function set explicitMaxHeight(value:Number):void
	{
		if (_explicitMaxHeight == value)
		{
			return;
		}

		_explicitMaxHeight = value;

		// Se invalidate size because locking in height
		// may change the measured width in flow-based components.
		invalidateSize();
		invalidateParentSizeAndDisplayList();

		dispatchEvent(new Event("explicitMaxHeightChanged"));
	}

	//----------------------------------
	//  explicitWidth
	//----------------------------------

	[Inspectable(environment="none")]

	/**
	 *  Number that specifies the explicit width of the component,
	 *  in pixels, in the component's coordinates.
	 *
	 *  <p>This value is used by the container in calculating
	 *  the size and position of the component.
	 *  It is not used by the component itself in determining
	 *  its default size.
	 *  Thus this property may not have any effect if parented by
	 *  Container, or containers that don't factor in
	 *  this property.
	 *  Because the value is in component coordinates,
	 *  the true <code>explicitWidth</code> with respect to its parent
	 *  is affected by the <code>scaleX</code> property.</p>
	 *  <p>Setting the <code>width</code> property also sets this property to
	 *  the specified width value.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get explicitWidth():Number
	{
		return _layoutMetrics.width;
	}

	/**
	 *  @private
	 */
	public function set explicitWidth(value:Number):void
	{
		if (_layoutMetrics.width == value)
		{
			return;
		}

		if (_layoutMetrics == EMPTY_LAYOUT_METRICS)
		{
			_layoutMetrics = new LayoutMetrics();
		}
		// width can be pixel or percent not both
		else if (!isNaN(value))
		{
			_layoutMetrics.percentWidth = NaN;
		}

		_layoutMetrics.width = value;

		// We invalidate size because locking in width
		// may change the measured height in flow-based components.
		invalidateSize();
		invalidateParentSizeAndDisplayList();

		//dispatchEvent(new Event("explicitWidthChanged"));
	}

	[Inspectable(environment="none")]
	/**
	 *  Number that specifies the explicit height of the component,
	 *  in pixels, in the component's coordinates.
	 *
	 *  <p>This value is used by the container in calculating
	 *  the size and position of the component.
	 *  It is not used by the component itself in determining
	 *  its default size.
	 *  Thus this property may not have any effect if parented by
	 *  Container, or containers that don't factor in
	 *  this property.
	 *  Because the value is in component coordinates,
	 *  the true <code>explicitHeight</code> with respect to its parent
	 *  is affected by the <code>scaleY</code> property.</p>
	 *  <p>Setting the <code>height</code> property also sets this property to
	 *  the specified height value.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get explicitHeight():Number
	{
		return _layoutMetrics.height;
	}

	public function set explicitHeight(value:Number):void
	{
		if (_layoutMetrics.height == value)
		{
			return;
		}

		if (_layoutMetrics == EMPTY_LAYOUT_METRICS)
		{
			_layoutMetrics = new LayoutMetrics();
		}
		// height can be pixel or percent, not both
		else if (!isNaN(value))
		{
			_layoutMetrics.percentHeight = NaN;
		}

		_layoutMetrics.height = value;

		// We invalidate size because locking in height
		// may change the measured width in flow-based components.
		invalidateSize();
		invalidateParentSizeAndDisplayList();

//		dispatchEvent(new Event("explicitHeightChanged"));
	}

	/**
	 * when false, the transform on this component consists only of translation.  Otherwise, it may be arbitrarily complex.
	 */
	private var _hasComplexLayoutMatrix:Boolean = false;

	/**
	 *  Returns <code>true</code> if the UIComponent has any non-translation (x,y) transform properties.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	protected function get hasComplexLayoutMatrix():Boolean
	{
		// we set _hasComplexLayoutMatrix when any scale or rotation transform gets set
		// because sometimes when those are set, we don't allocate a layoutFeatures object.

		// if the flag isn't set, we def. don't have a complex layout matrix.
		// if the flag is set and we don't have an AdvancedLayoutFeatures object,
		// then we'll check the transform and see if it's actually transformed.
		// otherwise we'll check the layoutMatrix on the AdvancedLayoutFeatures object,
		// to see if we're actually transformed.
		if (!_hasComplexLayoutMatrix)
		{
			return false;
		}
		else
		{
			if (_layoutFeatures == null)
			{
				_hasComplexLayoutMatrix = !MatrixUtil.isDeltaIdentity(super.transform.matrix);
				return _hasComplexLayoutMatrix;
			}
			else
			{
				return !MatrixUtil.isDeltaIdentity(_layoutFeatures.layoutMatrix);
			}
		}
	}

	/**
	 *  Storage for the includeInLayout property.
	 */
	private var _includeInLayout:Boolean = true;

	[Bindable("includeInLayoutChanged")]
	[Inspectable(category="General", defaultValue="true")]

	/**
	 *  Specifies whether this component is included in the layout of the
	 *  parent container.
	 *  If <code>true</code>, the object is included in its parent container's
	 *  layout and is sized and positioned by its parent container as per its layout rules.
	 *  If <code>false</code>, the object size and position are not affected by its parent container's
	 *  layout.
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get includeInLayout():Boolean
	{
		return _includeInLayout;
	}

	public function set includeInLayout(value:Boolean):void
	{
		if (_includeInLayout != value)
		{
			_includeInLayout = value;

			var p:IInvalidating = parent as IInvalidating;
			if (p)
			{
				p.invalidateSize();
				p.invalidateDisplayList();
			}

			dispatchEvent(new Event("includeInLayoutChanged"));
		}
	}

	//----------------------------------
	//  layoutDirection
	//----------------------------------

	/**
	 *  Checked at commitProperties() time to see if our layoutDirection has changed,
	 *  or our parent's layoutDirection has changed.  This variable is reset after the
	 *  entire validateProperties() phase is complete so that it's possible for a child
	 *  to check if its parent's layoutDirection has changed, see commitProperties().
	 *  The flag is cleared in validateDisplayList().
	 */
	private var oldLayoutDirection:String = null;

	/**
	 *  @inheritDoc
	 */
	public function get layoutDirection():String
	{
		return LAYOUT_DIRECTION_LTR;
	}

	/**
	 *  @private
	 *  Changes to the layoutDirection style cause an invalidateProperties() call,
	 *  see StyleProtoChain/styleChanged().  At commitProperties() time we use
	 *  invalidateLayoutDirection() to add/remove the mirroring transform.
	 *
	 *  layoutDirection=undefined or layoutDirection=null has the same effect
	 *  as setStyle(“layoutDirection”, undefined).
	 */
	public function set layoutDirection(value:String):void
	{
	}

	//--------------------------------------------------------------------------
	//
	//  Properties: Other
	//
	//--------------------------------------------------------------------------

	public function get baselinePosition():Number
	{
		throw new Error("abstract");
	}

	//----------------------------------
	//  effectsStarted
	//----------------------------------

	/**
	 *  The list of effects that are currently playing on the component,
	 *  as an Array of EffectInstance instances.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get activeEffects():Array
	{
		return _effectsStarted;
	}

	//----------------------------------
	//  flexContextMenu
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the flexContextMenu property.
	 */
	private var _flexContextMenu:IFlexContextMenu;

	/**
	 *  The context menu for this UIComponent.
	 *
	 *  @default null
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get flexContextMenu():IFlexContextMenu
	{
		return _flexContextMenu;
	}

	/**
	 *  @private
	 */
	public function set flexContextMenu(value:IFlexContextMenu):void
	{
		if (_flexContextMenu)
		{
			_flexContextMenu.unsetContextMenu(this);
		}

		_flexContextMenu = value;

		if (value != null)
		{
			_flexContextMenu.setContextMenu(this);
		}
	}

	//----------------------------------
	//  toolTip
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the toolTip property.
	 */
	mx_internal var _toolTip:String;

	[Bindable("toolTipChanged")]
	[Inspectable(category="General", defaultValue="null")]

	/**
	 *  Text to display in the ToolTip.
	 *
	 *  @default null
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get toolTip():String
	{
		return _toolTip;
	}

	/**
	 *  @private
	 */
	public function set toolTip(value:String):void
	{
		var oldValue:String = _toolTip;
		_toolTip = value;

		ToolTipManager.instance.registerToolTip(this, oldValue, value);

		dispatchEvent(new Event("toolTipChanged"));
	}

	//----------------------------------
	//  uid
	//----------------------------------

	/**
	 *  @private
	 */
	private var _uid:String;

	/**
	 *  A unique identifier for the object.
	 *  Flex data-driven controls, including all controls that are
	 *  subclasses of List class, use a UID to track data provider items.
	 *
	 *  <p>Flex can automatically create and manage UIDs.
	 *  However, there are circumstances when you must supply your own
	 *  <code>uid</code> property by implementing the IUID interface,
	 *  or when supplying your own <code>uid</code> property improves processing efficiency.
	 *  UIDs do not need to be universally unique for most uses in Flex.
	 *  One exception is for messages sent by data services.</p>
	 *
	 *  @see IUID
	 *  @see mx.utils.UIDUtil
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get uid():String
	{
		if (!_uid)
		{
			_uid = toString();
		}

		return _uid;
	}

	/**
	 *  @private
	 */
	public function set uid(uid:String):void
	{
		this._uid = uid;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties: Popups
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  isPopUp
	//----------------------------------

	/**
	 *  @private
	 */
	private var _isPopUp:Boolean;

	[Inspectable(environment="none")]

	/**
	 *  Set to <code>true</code> by the PopUpManager to indicate
	 *  that component has been popped up.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get isPopUp():Boolean
	{
		return _isPopUp;
	}

	public function set isPopUp(value:Boolean):void
	{
		_isPopUp = value;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties: Required to support automated testing
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  automationDelegate
	//----------------------------------

	/**
	 *  @private
	 */
	private var _automationDelegate:IAutomationObject;

	/**
	 *  The delegate object that handles the automation-related functionality.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get automationDelegate():Object
	{
		return _automationDelegate;
	}

	/**
	 *  @private
	 */
	public function set automationDelegate(value:Object):void
	{
		_automationDelegate = value as IAutomationObject;
	}

	//----------------------------------
	//  automationName
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the <code>automationName</code> property.
	 */
	private var _automationName:String = null;

	/**
	 *  @inheritDoc
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get automationName():String
	{
		if (_automationName)
		{
			return _automationName;
		}
		if (automationDelegate)
		{
			return automationDelegate.automationName;
		}

		return "";
	}

	/**
	 *  @private
	 */
	public function set automationName(value:String):void
	{
		_automationName = value;
	}

	/**
	 *  @copy mx.automation.IAutomationObject#automationValue
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get automationValue():Array
	{
		if (automationDelegate)
		{
			return automationDelegate.automationValue;
		}

		return [];
	}

	//----------------------------------
	//  showInAutomationHierarchy
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the <code>showInAutomationHierarchy</code> property.
	 */
	private var _showInAutomationHierarchy:Boolean = true;

	/**
	 *  @inheritDoc
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get showInAutomationHierarchy():Boolean
	{
		return _showInAutomationHierarchy;
	}

	/**
	 *  @private
	 */
	public function set showInAutomationHierarchy(value:Boolean):void
	{
		_showInAutomationHierarchy = value;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	override public function addChild(child:DisplayObject):DisplayObject
	{
		var formerParent:DisplayObjectContainer = child.parent;
		if (formerParent != null && !(formerParent is Loader))
		{
			formerParent.removeChild(child);
		}

		addingChild(child);
		super.addChildAt(child, effectOverlayReferenceCount && child != effectOverlay ? Math.max(0, super.numChildren - 1) : super.numChildren);
		childAdded(child);

		return child;
	}

	override public function addChildAt(child:DisplayObject, index:int):DisplayObject
	{
		var formerParent:DisplayObjectContainer = child.parent;
		if (formerParent && !(formerParent is Loader))
		{
			formerParent.removeChild(child);
		}

		// If there is an overlay, place the child underneath it.
		if (effectOverlayReferenceCount && child != effectOverlay)
		{
			index = Math.min(index, Math.max(0, super.numChildren - 1));
		}

		addingChild(child);
		super.addChildAt(child, index);
		childAdded(child);

		return child;
	}

	override public function removeChild(child:DisplayObject):DisplayObject
	{
		super.removeChild(child);
		childRemoved(child);
		return child;
	}

	override public function removeChildAt(index:int):DisplayObject
	{
		var child:DisplayObject = super.removeChildAt(index);
		childRemoved(child);
		return child;
	}

	override public function setChildIndex(child:DisplayObject, newIndex:int):void
	{
		// Place the child underneath the overlay.
		if (effectOverlayReferenceCount && child != effectOverlay)
		{
			newIndex = Math.min(newIndex, Math.max(0, super.numChildren - 2));
		}

		super.setChildIndex(child, newIndex);
	}

	/**
	 *  @private
	 *  This method allows access to the Player's native implementation
	 *  of removeChildAt(), which can be useful since components
	 *  can override removeChildAt() and thereby hide the native implementation.
	 *  Note that this "base method" is final and cannot be overridden,
	 *  so you can count on it to reflect what is happening at the player level.
	 */
	mx_internal final function $removeChildAt(index:int):DisplayObject
	{
		return super.removeChildAt(index);
	}

	/**
	 *  @private
	 *  This method allows access to the Player's native implementation
	 *  of setChildIndex(), which can be useful since components
	 *  can override setChildIndex() and thereby hide the native implementation.
	 *  Note that this "base method" is final and cannot be overridden,
	 *  so you can count on it to reflect what is happening at the player level.
	 */
	mx_internal final function $setChildIndex(child:DisplayObject, index:int):void
	{
		super.setChildIndex(child, index);
	}

	//--------------------------------------------------------------------------
	//
	//  Methods: Initialization
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	mx_internal function updateCallbacks():void
	{
		if (invalidateDisplayListFlag)
		{
			UIComponentGlobals.layoutManager.invalidateDisplayList(this);
		}

		if (invalidateSizeFlag)
		{
			UIComponentGlobals.layoutManager.invalidateSize(this);
		}

		if (invalidatePropertiesFlag)
		{
			UIComponentGlobals.layoutManager.invalidateProperties(this);
		}

		// systemManager getter tries to set the internal _systemManager varaible
		// if it is null. Hence a call to the getter is necessary.
		// Stage can be null when an untrusted application is loaded by an application
		// that isn't on stage yet.
		if (systemManager && (_systemManager.stage || usingBridge))
		{
			if (methodQueue.length > 0 && !listeningForRender)
			{
				_systemManager.addEventListener(FlexEvent.RENDER, callLaterDispatcher);
				_systemManager.addEventListener(FlexEvent.ENTER_FRAME, callLaterDispatcher);
				listeningForRender = true;
			}

			if (_systemManager.stage)
			{
				_systemManager.stage.invalidate();
			}
		}
	}

	/**
	 *  Called by Flex when a UIComponent object is added to or removed from a parent.
	 *  Developers typically never need to call this method.
	 *
	 *  @param p The parent of this UIComponent object.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function parentChanged(p:DisplayObjectContainer):void
	{
		if (p == null)
		{
			_nestLevel = 0;
		}

		parentChangedFlag = true;
	}

	private function addingChild(child:DisplayObject):void
	{
		// If the document property isn't already set on the child,
		// set it to be the same as this component's document.
		// The document setter will recursively set it on any
		// descendants of the child that exist.
		if (child is IUIComponent && !IUIComponent(child).document)
		{
			IUIComponent(child).document = document == null ? document : FlexGlobals.topLevelApplication;
		}

		// Propagate moduleFactory to the child, but don't overwrite an existing moduleFactory.
		if (child is IFlexModule && IFlexModule(child).moduleFactory == null)
		{
			if (moduleFactory != null)
			{
				IFlexModule(child).moduleFactory = moduleFactory;
			}
			else if (document is IFlexModule && IFlexModule(document).moduleFactory != null)
			{
				IFlexModule(child).moduleFactory = IFlexModule(document).moduleFactory;
			}
			else if (parent is IFlexModule && IFlexModule(parent).moduleFactory != null)
			{
				IFlexModule(child).moduleFactory = IFlexModule(parent).moduleFactory;
			}
		}

		if (child is IUIComponent)
		{
			IUIComponent(child).parentChanged(this);
		}

		// Set the nestLevel of the child to be one greater than the nestLevel of this component.
		// The nestLevel setter will recursively set it on any descendants of the child that exist.
		if (child is ILayoutManagerClient)
		{
			ILayoutManagerClient(child).nestLevel = nestLevel + 1;
		}

		if (child is InteractiveObject && doubleClickEnabled)
		{
			InteractiveObject(child).doubleClickEnabled = true;
		}

		// Sets up the inheritingStyles and nonInheritingStyles objects and their proto chains so that getStyle() works.
		// If this object already has some children, then reinitialize the children's proto chains.
		if (child is IStyleClient)
		{
			IStyleClient(child).regenerateStyleCache(true);
		}

		if (child is ISimpleStyleClient)
		{
			ISimpleStyleClient(child).styleChanged(null);
		}

		if (child is IStyleClient)
		{
			IStyleClient(child).notifyStyleChangeInChildren(null, true);
		}

		if (child is UIComponent)
		{
			UIComponent(child).initThemeColor();
			UIComponent(child).stylesInitialized();
		}
	}

	private function childAdded(child:DisplayObject):void
	{
		if (child is UIComponent && !UIComponent(child).initialized)
		{
			UIComponent(child).initialize();
		}
		else if (child is View && !View(child).initialized)
		{
			View(child).initialize();
		}
		else if (child is UIComponent && !UIComponent(child).initialized)
		{
			UIComponent(child).initialize();
		}
	}

	private function childRemoved(child:DisplayObject):void
	{
		if (child is IUIComponent)
		{
			// only reset document if the child isn't a document itself
			if (IUIComponent(child).document != child)
			{
				IUIComponent(child).document = null;
			}
			IUIComponent(child).parentChanged(null);
		}
	}

	/**
	 *  Initializes the internal structure of this component.
	 *
	 *  <p>Initializing a UIComponent is the fourth step in the creation
	 *  of a visual component instance, and happens automatically
	 *  the first time that the instance is added to a parent.
	 *  Therefore, you do not generally need to call
	 *  <code>initialize()</code>; the Flex framework calls it for you
	 *  from UIComponent's override of the <code>addChild()</code>
	 *  and <code>addChildAt()</code> methods.</p>
	 *
	 *  <p>The first step in the creation of a visual component instance
	 *  is construction, with the <code>new</code> operator:</p>
	 *
	 *  <pre>
	 *  var okButton:Button = new Button();</pre>
	 *
	 *  <p>After construction, the new Button instance is a solitary
	 *  DisplayObject; it does not yet have a UITextField as a child
	 *  to display its label, and it doesn't have a parent.</p>
	 *
	 *  <p>The second step is configuring the newly-constructed instance
	 *  with the appropriate properties, styles, and event handlers:</p>
	 *
	 *  <pre>
	 *  okButton.label = "OK";
	 *  okButton.setStyle("cornerRadius", 0);
	 *  okButton.addEventListener(MouseEvent.CLICK, clickHandler);</pre>
	 *
	 *  <p>The third step is adding the instance to a parent:</p>
	 *
	 *  <pre>
	 *  someContainer.addChild(okButton);</pre>
	 *
	 *  <p>A side effect of calling <code>addChild()</code>
	 *  or <code>addChildAt()</code>, when adding a component to a parent
	 *  for the first time, is that <code>initialize</code> gets
	 *  automatically called.</p>
	 *
	 *  <p>This method first dispatches a <code>preinitialize</code> event,
	 *  giving developers using this component a chance to affect it
	 *  before its internal structure has been created.
	 *  Next it calls the <code>createChildren()</code> method
	 *  to create the component's internal structure; for a Button,
	 *  this method creates and adds the UITextField for the label.
	 *  Then it dispatches an <code>initialize</code> event,
	 *  giving developers a chance to affect the component
	 *  after its internal structure has been created.</p>
	 *
	 *  <p>Note that it is the act of attaching a component to a parent
	 *  for the first time that triggers the creation of its internal structure.
	 *  If its internal structure includes other UIComponents, then this is a
	 *  recursive process in which the tree of DisplayObjects grows by one leaf
	 *  node at a time.</p>
	 *
	 *  <p>If you are writing a component, you do not need
	 *  to override this method.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function initialize():void
	{
		if (initialized)
		{
			return;
		}

		// The "preinitialize" event gets dispatched after everything about this
		// DisplayObject has been initialized, and it has been attached to
		// its parent, but before any of its children have been created.
		// This allows a "preinitialize" event handler to set properties which
		// affect child creation.
		// Note that this implies that "preinitialize" handlers are called
		// top-down; i.e., parents before children.
		dispatchEvent(new FlexEvent(FlexEvent.PREINITIALIZE));

		// Create child objects.
		createChildren();
		childrenCreated();

		// This should always be the last thing that initialize() calls.
		initializationComplete();
	}

	/**
	 *  Finalizes the initialization of this component.
	 *
	 *  <p>This method is the last code that executes when you add a component
	 *  to a parent for the first time using <code>addChild()</code>
	 *  or <code>addChildAt()</code>.
	 *  It handles some housekeeping related to dispatching
	 *  the <code>initialize</code> event.
	 *  If you are writing a component, you do not need
	 *  to override this method.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	protected function initializationComplete():void
	{
		processedDescriptors = true;
	}

	/**
	 *  Create child objects of the component.
	 *  This is an advanced method that you might override
	 *  when creating a subclass of UIComponent.
	 *
	 *  <p>A component that creates other components or objects within it is called a composite component.
	 *  For example, the Flex ComboBox control is actually made up of a TextInput control
	 *  to define the text area of the ComboBox, and a Button control to define the ComboBox arrow.
	 *  Components implement the <code>createChildren()</code> method to create child
	 *  objects (such as other components) within the component.</p>
	 *
	 *  <p>From within an override of the <code>createChildren()</code> method,
	 *  you call the <code>addChild()</code> method to add each child object. </p>
	 *
	 *  <p>You do not call this method directly. Flex calls the
	 *  <code>createChildren()</code> method in response to the call to
	 *  the <code>addChild()</code> method to add the component to its parent. </p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	protected function createChildren():void
	{
	}

	/**
	 *  Performs any final processing after child objects are created.
	 */
	protected function childrenCreated():void
	{
		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();
	}

	/**
	 *  Marks a component so that its <code>commitProperties()</code>
	 *  method gets called during a later screen update.
	 *
	 *  <p>Invalidation is a useful mechanism for eliminating duplicate
	 *  work by delaying processing of changes to a component until a
	 *  later screen update.
	 *  For example, if you want to change the text color and size,
	 *  it would be wasteful to update the color immediately after you
	 *  change it and then update the size when it gets set.
	 *  It is more efficient to change both properties and then render
	 *  the text with its new size and color once.</p>
	 *
	 *  <p>Invalidation methods rarely get called.
	 *  In general, setting a property on a component automatically
	 *  calls the appropriate invalidation method.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function invalidateProperties():void
	{
		if (!invalidatePropertiesFlag)
		{
			invalidatePropertiesFlag = true;

			if (parent && UIComponentGlobals.layoutManager)
			{
				UIComponentGlobals.layoutManager.invalidateProperties(this);
			}
		}
	}

	/**
	 *  Marks a component so that its <code>measure()</code>
	 *  method gets called during a later screen update.
	 *
	 *  <p>Invalidation is a useful mechanism for eliminating duplicate
	 *  work by delaying processing of changes to a component until a
	 *  later screen update.
	 *  For example, if you want to change the text and font size,
	 *  it would be wasteful to update the text immediately after you
	 *  change it and then update the size when it gets set.
	 *  It is more efficient to change both properties and then render
	 *  the text with its new size once.</p>
	 *
	 *  <p>Invalidation methods rarely get called.
	 *  In general, setting a property on a component automatically
	 *  calls the appropriate invalidation method.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function invalidateSize():void
	{
		if (!invalidateSizeFlag)
		{
			invalidateSizeFlag = true;

			if (parent && UIComponentGlobals.layoutManager)
			{
				UIComponentGlobals.layoutManager.invalidateSize(this);
			}
		}
	}

	/**
	 *  Helper method to invalidate parent size and display list if
	 *  this object affects its layout (includeInLayout is true).
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	protected function invalidateParentSizeAndDisplayList():void
	{
		if (!includeInLayout)
		{
			return;
		}

		var p:IInvalidating = parent as IInvalidating;
		if (!p)
		{
			return;
		}

		p.invalidateSize();
		p.invalidateDisplayList();
	}

	/**
	 *  Marks a component so that its <code>updateDisplayList()</code>
	 *  method gets called during a later screen update.
	 *
	 *  <p>Invalidation is a useful mechanism for eliminating duplicate
	 *  work by delaying processing of changes to a component until a
	 *  later screen update.
	 *  For example, if you want to change the width and height,
	 *  it would be wasteful to update the component immediately after you
	 *  change the width and then update again with the new height.
	 *  It is more efficient to change both properties and then render
	 *  the component with its new size once.</p>
	 *
	 *  <p>Invalidation methods rarely get called.
	 *  In general, setting a property on a component automatically
	 *  calls the appropriate invalidation method.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function invalidateDisplayList():void
	{
		if (!invalidateDisplayListFlag)
		{
			invalidateDisplayListFlag = true;

			if (isOnDisplayList() && UIComponentGlobals.layoutManager)
			{
				UIComponentGlobals.layoutManager.invalidateDisplayList(this);
			}
		}
	}

	private function invalidateTransform():void
	{
		if (_layoutFeatures && !_layoutFeatures.updatePending)
		{
			_layoutFeatures.updatePending = true;
			if (isOnDisplayList() && UIComponentGlobals.layoutManager && !invalidateDisplayListFlag)
			{
				UIComponentGlobals.layoutManager.invalidateDisplayList(this);
			}
		}
	}

	/**
	 * @inheritDoc
	 */
	public function invalidateLayoutDirection():void
	{
		const parentElt:ILayoutDirectionElement = parent as ILayoutDirectionElement;
		const thisLayoutDirection:String = layoutDirection;

		// If this element's layoutDirection doesn't match its parent's, then
		// set the _layoutFeatures.mirror flag.  Similarly, if mirroring isn't
		// required, then clear the _layoutFeatures.mirror flag.

		const mirror:Boolean = (parentElt) ? (parentElt.layoutDirection != thisLayoutDirection) : (LayoutDirection.LTR != thisLayoutDirection);

		if ((_layoutFeatures) ? (mirror != _layoutFeatures.mirror) : mirror)
		{
			if (_layoutFeatures == null)
			{
				initAdvancedLayoutFeatures();
			}
			_layoutFeatures.mirror = mirror;
			invalidateTransform();
		}

		// Children are notified only if the component's layoutDirection has changed.
		if (oldLayoutDirection != layoutDirection)
		{
			var i:int;

			//  If we have children, the styleChanged() machinery (via commitProperties()) will
			//  deal with UIComponent children. We have to deal with IVisualElement and
			//  ILayoutDirectionElement children that don't support styles, like GraphicElements, here.
			if (this is IVisualElementContainer)
			{
				const thisContainer:IVisualElementContainer = IVisualElementContainer(this);
				const thisContainerNumElements:int = thisContainer.numElements;

				for (i = 0; i < thisContainerNumElements; i++)
				{
					var elt:IVisualElement = thisContainer.getElementAt(i);
					// Can be null if IUITextField or IUIFTETextField.
					if (elt && !(elt is IStyleClient))
					{
						elt.invalidateLayoutDirection();
					}
				}
			}
			else
			{
				const thisNumChildren:int = numChildren;

				for (i = 0; i < thisNumChildren; i++)
				{
					var child:DisplayObject = getChildAt(i);
					if (!(child is IStyleClient) && child is ILayoutDirectionElement)
					{
						ILayoutDirectionElement(child).invalidateLayoutDirection();
					}
				}
			}
		}
	}

	private function transformOffsetsChangedHandler(e:Event):void
	{
		invalidateTransform();
	}

	private function isOnDisplayList():Boolean
	{
		var p:DisplayObjectContainer;
		try
		{
			p = super.parent;
		}
		catch (e:SecurityError)
		{
			return true; // we are on the display list but the parent is in another sandbox
		}

		return p != null;
	}

	/**
	 *  Validate and update the properties and layout of this object
	 *  and redraw it, if necessary.
	 *
	 *  Processing properties that require substantial computation are normally
	 *  not processed until the script finishes executing.
	 *  For example setting the <code>width</code> property is delayed, because it can
	 *  require recalculating the widths of the objects children or its parent.
	 *  Delaying the processing prevents it from being repeated
	 *  multiple times if the script sets the <code>width</code> property more than once.
	 *  This method lets you manually override this behavior.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function validateNow():void
	{
		UIComponentGlobals.layoutManager.validateClient(this);
	}

	/**
	 *  Queues a function to be called later.
	 *
	 *  <p>Before each update of the screen, Flash Player or AIR calls
	 *  the set of functions that are scheduled for the update.
	 *  Sometimes, a function should be called in the next update
	 *  to allow the rest of the code scheduled for the current
	 *  update to be executed.
	 *  Some features, like effects, can cause queued functions to be
	 *  delayed until the feature completes.</p>
	 *
	 *  @param method Reference to a method to be executed later.
	 *
	 *  @param args Array of Objects that represent the arguments to pass to the method.
	 *
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function callLater(method:Function, args:Array /* of Object */ = null):void
	{
		// trace(">>calllater " + this)
		// Push the method and the arguments onto the method queue.
		methodQueue.push(new MethodQueueElement(method, args));

		// Register to get the next "render" event
		// just before the next rasterization.
		var sm:ISystemManager = systemManager;

		// Stage can be null when an untrusted application is loaded by an application
		// that isn't on stage yet.
		if (sm && (sm.stage || usingBridge))
		{
			if (!listeningForRender)
			{
				// trace("  added");
				sm.addEventListener(FlexEvent.RENDER, callLaterDispatcher);
				sm.addEventListener(FlexEvent.ENTER_FRAME, callLaterDispatcher);
				listeningForRender = true;
			}

			// Force a "render" event to happen soon
			if (sm.stage)
			{
				sm.stage.invalidate();
			}
		}

		// trace("<<calllater " + this)
	}

	/**
	 *  @private
	 *  Cancels all queued functions.
	 */
	mx_internal function cancelAllCallLaters():void
	{
		var sm:ISystemManager = systemManager;

		// Stage can be null when an untrusted application is loaded by an application
		// that isn't on stage yet.
		if (sm && (sm.stage || usingBridge))
		{
			if (listeningForRender)
			{
				sm.removeEventListener(FlexEvent.RENDER, callLaterDispatcher);
				sm.removeEventListener(FlexEvent.ENTER_FRAME, callLaterDispatcher);
				listeningForRender = false;
			}
		}

		// Empty the method queue.
		methodQueue.length = 0;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods: Commitment
	//
	//--------------------------------------------------------------------------

	/**
	 *  Used by layout logic to validate the properties of a component
	 *  by calling the <code>commitProperties()</code> method.
	 *  In general, subclassers should
	 *  override the <code>commitProperties()</code> method and not this method.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function validateProperties():void
	{
		if (invalidatePropertiesFlag)
		{
			commitProperties();

			invalidatePropertiesFlag = false;
		}
	}

	/**
	 *  Processes the properties set on the component.
	 *  This is an advanced method that you might override
	 *  when creating a subclass of UIComponent.
	 *
	 *  <p>You do not call this method directly.
	 *  Flex calls the <code>commitProperties()</code> method when you
	 *  use the <code>addChild()</code> method to add a component to a container,
	 *  or when you call the <code>invalidateProperties()</code> method of the component.
	 *  Calls to the <code>commitProperties()</code> method occur before calls to the
	 *  <code>measure()</code> method. This lets you set property values that might
	 *  be used by the <code>measure()</code> method.</p>
	 *
	 *  <p>Some components have properties that affect the number or kinds
	 *  of child objects that they need to create, or have properties that
	 *  interact with each other, such as the <code>horizontalScrollPolicy</code>
	 *  and <code>horizontalScrollPosition</code> properties.
	 *  It is often best at startup time to process all of these
	 *  properties at one time to avoid duplicating work.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	protected function commitProperties():void
	{
		if (width != oldWidth || height != oldHeight)
		{
			dispatchResizeEvent();
		}

		if (blendModeChanged)
		{
			blendModeChanged = false;

			if (!blendShaderChanged)
			{
				$blendMode = _blendMode;
			}
			else
			{
				// The graphic element's blendMode was set to a non-Flash
				// blendMode. We mimic the look by instantiating the
				// appropriate shader class and setting the blendShader
				// property on the displayObject.
				blendShaderChanged = false;

				$blendMode = BlendMode.NORMAL;

				switch (_blendMode)
				{
					case "color":
					{
						$blendShader = new ColorShader();
						break;
					}
					case "colordodge":
					{
						$blendShader = new ColorDodgeShader();
						break;
					}
					case "colorburn":
					{
						$blendShader = new ColorBurnShader();
						break;
					}
					case "exclusion":
					{
						$blendShader = new ExclusionShader();
						break;
					}
					case "hue":
					{
						$blendShader = new HueShader();
						break;
					}
					case "luminosity":
					{
						$blendShader = new LuminosityShader();
						break;
					}
					case "saturation":
					{
						$blendShader = new SaturationShader();
						break;
					}
					case "softlight":
					{
						$blendShader = new SoftLightShader();
						break;
					}
				}
			}
		}

		parentChangedFlag = false;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods: Measurement
	//
	//--------------------------------------------------------------------------

	public function validateSize(recursive:Boolean = false):void
	{
		if (recursive)
		{
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				if (child is ILayoutManagerClient)
				{
					ILayoutManagerClient(child).validateSize(true);
				}
			}
		}

		if (invalidateSizeFlag)
		{
			if (includeInLayout && measureSizes())
			{
				// TODO (egeorgie): we don't need this invalidateDisplayList() here
				// because we'll call it if the parent sets new actual size?
				invalidateDisplayList();
				invalidateParentSizeAndDisplayList();
			}
		}
	}

	/**
	 *  Determines if the call to the <code>measure()</code> method can be skipped.
	 *
	 *  @return Returns <code>true</code> when the <code>measureSizes()</code> method can skip the call to
	 *  the <code>measure()</code> method. For example this is usually <code>true</code> when both <code>explicitWidth</code> and
	 *  <code>explicitHeight</code> are set. For paths, this is <code>true</code> when the bounds of the path
	 *  have not changed.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	protected function canSkipMeasurement():Boolean
	{
		// We can skip the measure function if the object's width and height
		// have been explicitly specified (e.g.: the object's MXML tag has
		// attributes like width="50" and height="100").
		//
		// If an object's width and height have been explicitly specified,
		// then the explicitWidth and explicitHeight properties contain
		// Numbers (as opposed to NaN)
		return !isNaN(_layoutMetrics.width) && !isNaN(_layoutMetrics.height);
	}

	/**
	 *  @private
	 */
	private function measureSizes():Boolean
	{
		var changed:Boolean = false;

		if (!invalidateSizeFlag)
		{
			return changed;
		}

		var newValue:Number;

		if (canSkipMeasurement())
		{
			invalidateSizeFlag = false;
			// develar — закомментировано — если мы установили ширину явно, то почему мы должны сбрасывать _measuredMinWidth/_measuredMinHeight — см. WindowResizer
//			_measuredMinWidth = 0;
//			_measuredMinHeight = 0;
		}
		else
		{
			measure();

			invalidateSizeFlag = false;

			if (!isNaN(explicitMinWidth) && measuredWidth < explicitMinWidth)
			{
				measuredWidth = explicitMinWidth;
			}

			if (!isNaN(explicitMaxWidth) && measuredWidth > explicitMaxWidth)
			{
				measuredWidth = explicitMaxWidth;
			}

			if (!isNaN(explicitMinHeight) && measuredHeight < explicitMinHeight)
			{
				measuredHeight = explicitMinHeight;
			}

			if (!isNaN(explicitMaxHeight) && measuredHeight > explicitMaxHeight)
			{
				measuredHeight = explicitMaxHeight;
			}
		}

		if (isNaN(oldMinWidth))
		{
			// This branch does the same thing as the else branch,
			// but it is optimized for the first time that
			// measureSizes() is called on this object.
			oldMinWidth = !isNaN(explicitMinWidth) ? explicitMinWidth : measuredMinWidth;

			oldMinHeight = !isNaN(explicitMinHeight) ? explicitMinHeight : measuredMinHeight;

			oldExplicitWidth = !isNaN(_layoutMetrics.width) ? _layoutMetrics.width : measuredWidth;

			oldExplicitHeight = !isNaN(_layoutMetrics.height) ? explicitHeight : measuredHeight;

			changed = true;
		}
		else
		{
			newValue = !isNaN(explicitMinWidth) ? explicitMinWidth : measuredMinWidth;
			if (newValue != oldMinWidth)
			{
				oldMinWidth = newValue;
				changed = true;
			}

			newValue = !isNaN(explicitMinHeight) ? explicitMinHeight : measuredMinHeight;
			if (newValue != oldMinHeight)
			{
				oldMinHeight = newValue;
				changed = true;
			}

			newValue = !isNaN(_layoutMetrics.width) ? _layoutMetrics.width : measuredWidth;
			if (newValue != oldExplicitWidth)
			{
				oldExplicitWidth = newValue;
				changed = true;
			}

			newValue = !isNaN(explicitHeight) ? explicitHeight : measuredHeight;
			if (newValue != oldExplicitHeight)
			{
				oldExplicitHeight = newValue;
				changed = true;
			}

		}

		return changed;
	}

	/**
	 *  Calculates the default size, and optionally the default minimum size,
	 *  of the component. This is an advanced method that you might override when
	 *  creating a subclass of UIComponent.
	 *
	 *  <p>You do not call this method directly. Flex calls the
	 *  <code>measure()</code> method when the component is added to a container
	 *  using the <code>addChild()</code> method, and when the component's
	 *  <code>invalidateSize()</code> method is called. </p>
	 *
	 *  <p>When you set a specific height and width of a component,
	 *  Flex does not call the <code>measure()</code> method,
	 *  even if you explicitly call the <code>invalidateSize()</code> method.
	 *  That is, Flex only calls the <code>measure()</code> method if
	 *  the <code>explicitWidth</code> property or the <code>explicitHeight</code>
	 *  property of the component is NaN. </p>
	 *
	 *  <p>In your override of this method, you must set the
	 *  <code>measuredWidth</code> and <code>measuredHeight</code> properties
	 *  to define the default size.
	 *  You can optionally set the <code>measuredMinWidth</code> and
	 *  <code>measuredMinHeight</code> properties to define the default
	 *  minimum size.</p>
	 *
	 *  <p>Most components calculate these values based on the content they are
	 *  displaying, and from the properties that affect content display.
	 *  A few components simply have hard-coded default values. </p>
	 *
	 *  <p>The conceptual point of <code>measure()</code> is for the component to provide
	 *  its own natural or intrinsic size as a default. Therefore, the
	 *  <code>measuredWidth</code> and <code>measuredHeight</code> properties
	 *  should be determined by factors such as:</p>
	 *  <ul>
	 *	 <li>The amount of text the component needs to display.</li>
	 *	 <li>The styles, such as <code>fontSize</code>, for that text.</li>
	 *	 <li>The size of a JPEG image that the component displays.</li>
	 *	 <li>The measured or explicit sizes of the component's children.</li>
	 *	 <li>Any borders, margins, and gaps.</li>
	 *  </ul>
	 *
	 *  <p>In some cases, there is no intrinsic way to determine default values.
	 *  For example, a simple GreenCircle component might simply set
	 *  measuredWidth = 100 and measuredHeight = 100 in its <code>measure()</code> method to
	 *  provide a reasonable default size. In other cases, such as a TextArea,
	 *  an appropriate computation (such as finding the right width and height
	 *  that would just display all the text and have the aspect ratio of a Golden Rectangle)
	 *  might be too time-consuming to be worthwhile.</p>
	 *
	 *  <p>The default implementation of <code>measure()</code>
	 *  sets <code>measuredWidth</code>, <code>measuredHeight</code>,
	 *  <code>measuredMinWidth</code>, and <code>measuredMinHeight</code>
	 *  to <code>0</code>.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	protected function measure():void
	{
		measuredMinWidth = 0;
		measuredMinHeight = 0;
		measuredWidth = 0;
		measuredHeight = 0;
	}

	/**
	 *  A convenience method for determining whether to use the
	 *  explicit or measured width
	 *
	 *  @return A Number which is explicitWidth if defined
	 *  or measuredWidth if not.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function getExplicitOrMeasuredWidth():Number
	{
		return !isNaN(_layoutMetrics.width) ? _layoutMetrics.width : measuredWidth;
	}

	/**
	 *  A convenience method for determining whether to use the
	 *  explicit or measured height
	 *
	 *  @return A Number which is explicitHeight if defined
	 *  or measuredHeight if not.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function getExplicitOrMeasuredHeight():Number
	{
		return !isNaN(_layoutMetrics.height) ? _layoutMetrics.height : measuredHeight;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods: Drawing and Child Layout
	//
	//--------------------------------------------------------------------------

	protected function validateMatrix():void
	{
		if (_layoutFeatures != null && _layoutFeatures.updatePending)
		{
			applyComputedMatrix();
		}

		if (_maintainProjectionCenter)
		{
			var pmatrix:PerspectiveProjection = super.transform.perspectiveProjection;
			if (pmatrix != null)
			{
				pmatrix.projectionCenter = new Point(width / 2, height / 2);
			}
		}
	}

	public function validateDisplayList():void
	{
		oldLayoutDirection = layoutDirection;

		if (invalidateDisplayListFlag)
		{
			// Check if our parent is the top level system manager
			var sm:ISystemManager = parent as ISystemManager;
			if (sm)
			{
				if (sm.isProxy || (sm == systemManager.topLevelSystemManager && sm.document != this))
				{
					// Size ourself to the new measured width/height   This can
					// cause the _layoutFeatures computed matrix to become invalid
					setActualSize(getExplicitOrMeasuredWidth(), getExplicitOrMeasuredHeight());
				}
			}

			// Don't validate transform.matrix until after setting actual size
			validateMatrix();
			updateDisplayList(width, height);

			invalidateDisplayListFlag = false;

			// LAYOUT_DEBUG
			// LayoutManager.debugHelper.addElement(ILayoutElement(this));
		}
		else
		{
			validateMatrix();
		}
	}

	/**
	 *  Draws the object and/or sizes and positions its children.
	 *  This is an advanced method that you might override
	 *  when creating a subclass of UIComponent.
	 *
	 *  <p>You do not call this method directly. Flex calls the
	 *  <code>updateDisplayList()</code> method when the component is added to a container
	 *  using the <code>addChild()</code> method, and when the component's
	 *  <code>invalidateDisplayList()</code> method is called. </p>
	 *
	 *  <p>If the component has no children, this method
	 *  is where you would do programmatic drawing
	 *  using methods on the component's Graphics object
	 *  such as <code>graphics.drawRect()</code>.</p>
	 *
	 *  <p>If the component has children, this method is where
	 *  you would call the <code>move()</code> and <code>setActualSize()</code>
	 *  methods on its children.</p>
	 *
	 *  <p>Components can do programmatic drawing even if
	 *  they have children. In doing either, use the
	 *  component's <code>unscaledWidth</code> and <code>unscaledHeight</code>
	 *  as its bounds.</p>
	 *
	 *  <p>It is important to use <code>unscaledWidth</code> and
	 *  <code>unscaledHeight</code> instead of the <code>width</code>
	 *  and <code>height</code> properties.</p>
	 *
	 *  @param w Specifies the width of the component, in pixels,
	 *  in the component's coordinates, regardless of the value of the
	 *  <code>scaleX</code> property of the component.
	 *
	 *  @param h Specifies the height of the component, in pixels,
	 *  in the component's coordinates, regardless of the value of the
	 *  <code>scaleY</code> property of the component.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	protected function updateDisplayList(w:Number, h:Number):void
	{
	}

	public function get left():Object
	{
		return _layoutMetrics.left;
	}

	public function set left(value:Object):void
	{
		_layoutMetrics.left = Number(value);
	}

	public function get right():Object
	{
		return _layoutMetrics.right;
	}

	public function set right(value:Object):void
	{
		if (_layoutMetrics == EMPTY_LAYOUT_METRICS)
		{
			_layoutMetrics = new LayoutMetrics();
		}
		else if (_layoutMetrics.right == value)
		{
			return;
		}

		_layoutMetrics.right = Number(value);
		invalidateSize();
		invalidateParentSizeAndDisplayList();
		invalidateDisplayList();
	}

	public function get top():Object
	{
		return _layoutMetrics.top;
	}

	public function set top(value:Object):void
	{
		if (_layoutMetrics == EMPTY_LAYOUT_METRICS)
		{
			_layoutMetrics = new LayoutMetrics();
		}
		_layoutMetrics.top = Number(value);
	}

	public function get bottom():Object
	{
		return _layoutMetrics.bottom;
	}

	public function set bottom(value:Object):void
	{
		if (_layoutMetrics == EMPTY_LAYOUT_METRICS)
		{
			_layoutMetrics = new LayoutMetrics();
		}
		_layoutMetrics.bottom = Number(value);
	}

	public function get horizontalCenter():Object
	{
		return _layoutMetrics.horizontalCenter;
	}

	public function set horizontalCenter(value:Object):void
	{
		if (_layoutMetrics == EMPTY_LAYOUT_METRICS)
		{
			_layoutMetrics = new LayoutMetrics();
		}
		_layoutMetrics.horizontalCenter = Number(value);
	}

	public function get verticalCenter():Object
	{
		return _layoutMetrics.verticalCenter;
	}

	public function set verticalCenter(value:Object):void
	{
		if (_layoutMetrics == EMPTY_LAYOUT_METRICS)
		{
			_layoutMetrics = new LayoutMetrics();
		}
		_layoutMetrics.verticalCenter = Number(value);
	}

	public function get baseline():Object
	{
		return _layoutMetrics.baseline;
	}

	public function set baseline(value:Object):void
	{
		if (_layoutMetrics == EMPTY_LAYOUT_METRICS)
		{
			_layoutMetrics = new LayoutMetrics();
		}
		_layoutMetrics.baseline = Number(value);
	}

	//--------------------------------------------------------------------------
	//
	//  Methods: Moving and sizing
	//
	//--------------------------------------------------------------------------

	/**
	 *  Moves the component to a specified position within its parent.
	 *  Calling this method is exactly the same as
	 *  setting the component's <code>x</code> and <code>y</code> properties.
	 *
	 *  <p>If you are overriding the <code>updateDisplayList()</code> method
	 *  in a custom component, call the <code>move()</code> method
	 *  rather than setting the <code>x</code> and <code>y</code> properties.
	 *  The difference is that the <code>move()</code> method changes the location
	 *  of the component and then dispatches a <code>move</code> event when you
	 *  call the method, while setting the <code>x</code> and <code>y</code>
	 *  properties changes the location of the component and dispatches
	 *  the event on the next screen refresh.</p>
	 *
	 *  @param x Left position of the component within its parent.
	 *
	 *  @param y Top position of the component within its parent.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function move(x:Number, y:Number):void
	{
		var changed:Boolean = false;

		if (x != this.x)
		{
			if (_layoutFeatures == null)
			{
				super.x = x;
			}
			else
			{
				_layoutFeatures.layoutX = x;
			}

			if (hasEventListener("xChanged"))
			{
				dispatchEvent(new Event("xChanged"));
			}
			changed = true;
		}

		if (y != this.y)
		{
			if (_layoutFeatures == null)
			{
				super.y = y;
			}
			else
			{
				_layoutFeatures.layoutY = y;
			}

			if (hasEventListener("yChanged"))
			{
				dispatchEvent(new Event("yChanged"));
			}
			changed = true;
		}

		if (changed)
		{
			invalidateTransform();
			if (hasEventListener(MoveEvent.MOVE))
			{
				dispatchEvent(new MoveEvent(MoveEvent.MOVE));
			}
		}
	}

	/**
	 *  Sizes the object.
	 *  Unlike directly setting the <code>width</code> and <code>height</code>
	 *  properties, calling the <code>setActualSize()</code> method
	 *  does not set the <code>explictWidth</code> and
	 *  <code>explicitHeight</code> properties, so a future layout
	 *  calculation can result in the object returning to its previous size.
	 *  This method is used primarily by component developers implementing
	 *  the <code>updateDisplayList()</code> method, by Effects,
	 *  and by the LayoutManager.
	 *
	 *  @param w Width of the object.
	 *
	 *  @param h Height of the object.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function setActualSize(w:Number, h:Number):void
	{
		// trace("setActualSize: " + this + " width = " + w + " height = " + h);

		var changed:Boolean = false;

		if (_width != w)
		{
			_width = w;
			if (_layoutFeatures)
			{
				_layoutFeatures.layoutWidth = w;  // for the mirror transform
				invalidateTransform();
			}
//			if (hasEventListener("widthChanged"))
//			{
//				dispatchEvent(new Event("widthChanged"));
//			}
			changed = true;
		}

		if (_height != h)
		{
			_height = h;
//			if (hasEventListener("heightChanged"))
//			{
//				dispatchEvent(new Event("heightChanged"));
//			}
			changed = true;
		}

		if (changed)
		{
			invalidateDisplayList();
			dispatchResizeEvent();
		}

		setActualSizeCalled = true;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods: Focus
	//
	//--------------------------------------------------------------------------

	/**
	 *  Gets the object that currently has focus.
	 *  It might not be this object.
	 *  Note that this method does not necessarily return the component
	 *  that has focus.
	 *  It can return the internal subcomponent of the component
	 *  that has focus.
	 *  To get the component that has focus, use the
	 *  <code>focusManager.focus</code> property.
	 *
	 *  @return Object that has focus.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function getFocus():InteractiveObject
	{
		var sm:ISystemManager = systemManager;
		if (!sm)
		{
			return null;
		}

		if (UIComponentGlobals.nextFocusObject)
		{
			return UIComponentGlobals.nextFocusObject;
		}

		if (sm.stage)
		{
			return sm.stage.focus;
		}

		return null;
	}

	/**
	 *  Sets the focus to this component.
	 *  The component can in turn pass focus to a subcomponent.
	 *
	 *  <p><b>Note:</b> Only the TextInput and TextArea controls show a highlight
	 *  when this method sets the focus.
	 *  All controls show a highlight when the user tabs to the control.</p>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function setFocus():void
	{
		var sm:ISystemManager = systemManager;
		if (sm && (sm.stage || usingBridge))
		{
			if (UIComponentGlobals.callLaterDispatcherCount == 0)
			{
				sm.stage.focus = this;
				UIComponentGlobals.nextFocusObject = null;
			}
			else
			{
				UIComponentGlobals.nextFocusObject = this;
				sm.addEventListener(FlexEvent.ENTER_FRAME, setFocusLater);
			}
		}
		else
		{
			UIComponentGlobals.nextFocusObject = this;
			callLater(setFocusLater);
		}
	}

	/**
	 *  @private
	 *  Returns the focus object
	 */
	mx_internal function getFocusObject():DisplayObject
	{
		var fm:IFocusManager = focusManager;

		if (!fm || !fm.focusPane)
		{
			return null;
		}

		return fm.focusPane.numChildren == 0 ? null : fm.focusPane.getChildAt(0);
	}

	//--------------------------------------------------------------------------
	//
	//  Methods: Events
	//
	//--------------------------------------------------------------------------

	/**
	 *  Helper method for dispatching a PropertyChangeEvent
	 *  when a property is updated.
	 *
	 *  @param prop Name of the property that changed.
	 *
	 *  @param oldValue Old value of the property.
	 *
	 *  @param value New value of the property.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	protected function dispatchPropertyChangeEvent(prop:String, oldValue:*, value:*):void
	{
		if (hasEventListener("propertyChange"))
		{
			dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, prop, oldValue, value));
		}
	}

	/**
	 *  @private
	 */
	private function dispatchResizeEvent():void
	{
		if (hasEventListener(ResizeEvent.RESIZE))
		{
			var resizeEvent:ResizeEvent = new ResizeEvent(ResizeEvent.RESIZE);
			resizeEvent.oldWidth = oldWidth;
			resizeEvent.oldHeight = oldHeight;
			dispatchEvent(resizeEvent);
		}

		oldWidth = width;
		oldHeight = height;
	}

	/**
	 *  @private
	 *  Called when the child transform changes (currently x and y on UIComponent),
	 *  so that the Group has a chance to invalidate the layout.
	 */
	mx_internal function childXYChanged():void
	{
	}

	/**
	 *  @private
	 *  Typically, Keyboard.LEFT means go left, regardless of the
	 *  layoutDirection, and similiarly for Keyboard.RIGHT.  When
	 *  layoutDirection="rtl", rather than duplicating lots of code in the
	 *  switch statement of the keyDownHandler, map Keyboard.LEFT to
	 *  Keyboard.RIGHT, and similiarly for Keyboard.RIGHT.
	 *
	 *  Optionally, Keyboard.UP can be tied with Keyboard.LEFT and
	 *  Keyboard.DOWN can be tied with Keyboard.RIGHT since some components
	 *  do this.
	 *
	 *  @return keyCode to use for the layoutDirection if always using ltr
	 *  actions
	 */
	mx_internal function mapKeycodeForLayoutDirection(event:KeyboardEvent, mapUpDown:Boolean = false):uint
	{
		var keyCode:uint = event.keyCode;

		// If rtl layout, left still means left and right still means right so
		// swap the keys to get the correct action.
		switch (keyCode)
		{
			case Keyboard.DOWN:
			{
				// typically, if ltr, the same as RIGHT
				if (mapUpDown && layoutDirection == LayoutDirection.RTL)
				{
					keyCode = Keyboard.LEFT;
				}
				break;
			}
			case Keyboard.RIGHT:
			{
				if (layoutDirection == LayoutDirection.RTL)
				{
					keyCode = Keyboard.LEFT;
				}
				break;
			}
			case Keyboard.UP:
			{
				// typically, if ltr, the same as LEFT
				if (mapUpDown && layoutDirection == LayoutDirection.RTL)
				{
					keyCode = Keyboard.RIGHT;
				}
				break;
			}
			case Keyboard.LEFT:
			{
				if (layoutDirection == LayoutDirection.RTL)
				{
					keyCode = Keyboard.RIGHT;
				}
				break;
			}
		}

		return keyCode;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods: Effects
	//
	//--------------------------------------------------------------------------

	/**
	 *  For each effect event, registers the EffectManager
	 *  as one of the event listeners.
	 *  You typically never need to call this method.
	 *
	 *  @param effects The names of the effect events.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function registerEffects(effects:Array /* of String */):void
	{
		var n:int = effects.length;
		for (var i:int = 0; i < n; i++)
		{
			// Ask the EffectManager for the event associated with this effectTrigger
			var event:String = EffectManager.getEventForEffectTrigger(effects[i]);

			if (event != null && event != "")
			{
				addEventListener(event, EffectManager.eventHandler, false, EventPriority.EFFECT);
			}
		}
	}

	/**
	 *  @private
	 */
	mx_internal var _effectsStarted:Array = [];

	/**
	 *  @private
	 */
	mx_internal var _affectedProperties:Object = {};

	/**
	 *  Contains <code>true</code> if an effect is currently playing on the component.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	private var _isEffectStarted:Boolean = false;
	mx_internal function get isEffectStarted():Boolean
	{
		return _isEffectStarted;
	}

	mx_internal function set isEffectStarted(value:Boolean):void
	{
		_isEffectStarted = value;
	}

	private var preventDrawFocus:Boolean = false;

	/**
	 *  Called by the effect instance when it starts playing on the component.
	 *  You can use this method to perform a modification to the component as part
	 *  of an effect. You can use the <code>effectFinished()</code> method
	 *  to restore the modification when the effect ends.
	 *
	 *  @param effectInst The effect instance object playing on the component.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function effectStarted(effectInst:IEffectInstance):void
	{
		// Check that the instance isn't already in our list
		_effectsStarted.push(effectInst);

		var aProps:Array = effectInst.effect.getAffectedProperties();
		for (var j:int = 0; j < aProps.length; j++)
		{
			var propName:String = aProps[j];
			if (_affectedProperties[propName] == undefined)
			{
				_affectedProperties[propName] = [];
			}

			_affectedProperties[propName].push(effectInst);
		}

		isEffectStarted = true;
		// Hide the focus ring if the target already has one drawn
		if (effectInst.hideFocusRing)
		{
			preventDrawFocus = true;
//			drawFocus(false);
		}
	}


	private var _endingEffectInstances:Array = [];

	/**
	 *  Called by the effect instance when it stops playing on the component.
	 *  You can use this method to restore a modification to the component made
	 *  by the <code>effectStarted()</code> method when the effect started,
	 *  or perform some other action when the effect ends.
	 *
	 *  @param effectInst The effect instance object playing on the component.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function effectFinished(effectInst:IEffectInstance):void
	{
		_endingEffectInstances.push(effectInst);
		invalidateProperties();

		// weak reference
		UIComponentGlobals.layoutManager.addEventListener(FlexEvent.UPDATE_COMPLETE, updateCompleteHandler, false, 0, true);
	}

	/**
	 *  Ends all currently playing effects on the component.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function endEffectsStarted():void
	{
		var len:int = _effectsStarted.length;
		for (var i:int = 0; i < len; i++)
		{
			_effectsStarted[i].end();
		}
	}

	/**
	 *  @private
	 */
	private function updateCompleteHandler(event:FlexEvent):void
	{
		UIComponentGlobals.layoutManager.removeEventListener(FlexEvent.UPDATE_COMPLETE, updateCompleteHandler);
		processEffectFinished(_endingEffectInstances);
		_endingEffectInstances = [];
	}

	/**
	 *  @private
	 */
	private function processEffectFinished(effectInsts:Array):void
	{
		// Find the instance in our list.
		for (var i:int = _effectsStarted.length - 1; i >= 0; i--)
		{
			for (var j:int = 0; j < effectInsts.length; j++)
			{
				var effectInst:IEffectInstance = effectInsts[j];
				if (effectInst == _effectsStarted[i])
				{
					// Remove the effect from our array.
					var removedInst:IEffectInstance = _effectsStarted[i];
					_effectsStarted.splice(i, 1);

					// Remove the affected properties from our internal object
					var aProps:Array = removedInst.effect.getAffectedProperties();
					for (var k:int = 0; k < aProps.length; k++)
					{
						var propName:String = aProps[k];
						if (_affectedProperties[propName] != undefined)
						{
							for (var l:int = 0; l < _affectedProperties[propName].length; l++)
							{
								if (_affectedProperties[propName][l] == effectInst)
								{
									_affectedProperties[propName].splice(l, 1);
									break;
								}
							}

							if (_affectedProperties[propName].length == 0)
							{
								delete _affectedProperties[propName];
							}
						}
					}
					break;
				}
			}
		}

		isEffectStarted = _effectsStarted.length > 0;
		if (effectInst && effectInst.hideFocusRing)
		{
			preventDrawFocus = false;
		}
	}

	/**
	 *  @private
	 */
	mx_internal function getEffectsForProperty(propertyName:String):Array
	{
		return _affectedProperties[propertyName] != undefined ? _affectedProperties[propertyName] : [];
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers: Invalidation
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Callback that then calls queued functions.
	 */
	private function callLaterDispatcher(event:Event):void
	{
		// trace(">>calllaterdispatcher " + this);
		UIComponentGlobals.callLaterDispatcherCount++;

		// At run-time, callLaterDispatcher2() is called
		// without a surrounding try-catch.
		if (!UIComponentGlobals.catchCallLaterExceptions)
		{
			callLaterDispatcher2(event);
		}

		// At design-time, callLaterDispatcher2() is called
		// with a surrounding try-catch.
		else
		{
			try
			{
				callLaterDispatcher2(event);
			}
			catch(e:Error)
			{
				// Dispatch a callLaterError dynamic event for Design View.
				var callLaterErrorEvent:DynamicEvent = new DynamicEvent("callLaterError");
				callLaterErrorEvent.error = e;
				callLaterErrorEvent.source = this;
				systemManager.dispatchEvent(callLaterErrorEvent);
			}
		}
		// trace("<<calllaterdispatcher");
		UIComponentGlobals.callLaterDispatcherCount--;
	}

	/**
	 *  @private
	 *  Callback that then calls queued functions.
	 */
	private function callLaterDispatcher2(event:Event):void
	{
		if (UIComponentGlobals.callLaterSuspendCount > 0)
		{
			return;
		}

		// trace("  >>calllaterdispatcher2");
		var sm:ISystemManager = systemManager;

		// Stage can be null when an untrusted application is loaded by an application
		// that isn't on stage yet.
		if (sm && (sm.stage || usingBridge) && listeningForRender)
		{
			// trace("  removed");
			sm.removeEventListener(FlexEvent.RENDER, callLaterDispatcher);
			sm.removeEventListener(FlexEvent.ENTER_FRAME, callLaterDispatcher);
			listeningForRender = false;
		}

		// Move the method queue off to the side, so that subsequent
		// calls to callLater get added to a new queue that'll get handled
		// next time.
		var queue:Vector.<MethodQueueElement> = methodQueue;
		methodQueue = new <MethodQueueElement>[];

		// Call each method currently in the method queue.
		// These methods can call callLater(), causing additional
		// methods to be queued, but these will get called the next
		// time around.
		var n:int = queue.length;
		//  trace("  queue length " + n);
		for (var i:int = 0; i < n; i++)
		{
			var mqe:MethodQueueElement = MethodQueueElement(queue[i]);

			mqe.method.apply(null, mqe.args);
		}

		// trace("  <<calllaterdispatcher2 " + this);
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers: Keyboard
	//
	//--------------------------------------------------------------------------

	/**
	 *  Typically overridden by components containing UITextField objects,
	 *  where the UITextField object gets focus.
	 *
	 *  @param target A UIComponent object containing a UITextField object
	 *  that can receive focus.
	 *
	 *  @return Returns <code>true</code> if the UITextField object has focus.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	protected function isOurFocus(target:DisplayObject):Boolean
	{
		return target == this;
	}

	/**
	 *  The event handler called when a UIComponent object gets focus.
	 *  If you override this method, make sure to call the base class version.
	 *
	 *  @param event The event object.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	protected function focusInHandler(event:FocusEvent):void
	{
		if (isOurFocus(DisplayObject(event.target)))
		{
			var fm:IFocusManager = focusManager;
			if (fm && fm.showFocusIndicator)
			{
//				drawFocus(true);
			}
		}
	}

	/**
	 *  The event handler called when a UIComponent object loses focus.
	 *  If you override this method, make sure to call the base class version.
	 *
	 *  @param event The event object.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	protected function focusOutHandler(event:FocusEvent):void
	{
		// We don't need to remove our event listeners here because we
		// won't receive keyboard events.
		if (isOurFocus(DisplayObject(event.target)))
		{
//			drawFocus(false);
		}
	}

	private function removedHandler(event:Event):void
	{
		if (event.eventPhase == EventPhase.AT_TARGET)
		{
			invalidateSystemManager();
		}
	}

	/**
	 *  @private
	 *  There is a bug (139390) where setting focus from within callLaterDispatcher
	 *  screws up the ActiveX player.  We defer focus until enterframe.
	 */
	private function setFocusLater(event:Event = null):void
	{
		var sm:ISystemManager = systemManager;
		if (sm && sm.stage)
		{
			sm.stage.removeEventListener(Event.ENTER_FRAME, setFocusLater);
			if (UIComponentGlobals.nextFocusObject)
			{
				sm.stage.focus = UIComponentGlobals.nextFocusObject;
			}
			UIComponentGlobals.nextFocusObject = null;
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers: Filters
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private function filterChangeHandler(event:Event):void
	{
		filters = _filters;
	}

	//--------------------------------------------------------------------------
	//
	//  IUIComponent
	//
	//--------------------------------------------------------------------------

	/**
	 *  Returns <code>true</code> if the chain of <code>owner</code> properties
	 *  points from <code>child</code> to this UIComponent.
	 *
	 *  @param child A UIComponent.
	 *
	 *  @return <code>true</code> if the child is parented or owned by this UIComponent.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function owns(child:DisplayObject):Boolean
	{
		if (contains(child))
		{
			return true;
		}

		try
		{
			while (child && child != this)
			{
				// do a parent walk
				if (child is IUIComponent)
				{
					child = IUIComponent(child).owner;
				}
				else
				{
					child = child.parent;
				}
			}
		}
		catch (e:SecurityError)
		{
			// You can't own what you don't have access to.
			return false;
		}

		return child == this;
	}

	/**
	 *  Creates the object using a given moduleFactory.
	 *  If the moduleFactory is null or the object
	 *  cannot be created using the module factory,
	 *  then fall back to creating the object using a systemManager.
	 *
	 *  @param moduleFactory The moduleFactory to create the class in;
	 *  can be null.
	 *
	 *  @param className The name of the class to create.
	 *
	 *  @return The object created in the context of the moduleFactory.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	protected function createInModuleContext(moduleFactory:IFlexModuleFactory, className:String):Object
	{
		var newObject:Object = null;

		if (moduleFactory)
		{
			newObject = moduleFactory.create(className);
		}

		return newObject;
	}

	public function createAutomationIDPart(child:IAutomationObject):Object
	{
		if (automationDelegate)
		{
			return automationDelegate.createAutomationIDPart(child);
		}
		return null;
	}

	public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
	{
		if (automationDelegate)
		{
			return automationDelegate.createAutomationIDPartWithRequiredProperties(child, properties);
		}
		return null;
	}

	public function resolveAutomationIDPart(criteria:Object):Array
	{
		if (automationDelegate)
		{
			return automationDelegate.resolveAutomationIDPart(criteria);
		}
		return [];
	}

	public function getAutomationChildAt(index:int):IAutomationObject
	{
		if (automationDelegate)
		{
			return automationDelegate.getAutomationChildAt(index);
		}
		return null;
	}

	public function getAutomationChildren():Array
	{
		if (automationDelegate)
		{
			return automationDelegate.getAutomationChildren();
		}
		return null;
	}

	public function get numAutomationChildren():int
	{
		if (automationDelegate)
		{
			return automationDelegate.numAutomationChildren;
		}
		return 0;
	}

	public function get automationTabularData():Object
	{
		if (automationDelegate)
		{
			return automationDelegate.automationTabularData;
		}
		return null;
	}

	public function get automationOwner():DisplayObjectContainer
	{
		return owner;
	}

	public function get automationParent():DisplayObjectContainer
	{
		return parent;
	}

	public function get automationEnabled():Boolean
	{
		return enabled;
	}

	public function get automationVisible():Boolean
	{
		return visible;
	}

	public function replayAutomatableEvent(event:Event):Boolean
	{
		if (automationDelegate)
		{
			return automationDelegate.replayAutomatableEvent(event);
		}
		return false;
	}

	//--------------------------------------------------------------------------
	//
	//  Diagnostics
	//
	//--------------------------------------------------------------------------

	private static const fakeMouseX:QName = new QName(mx_internal, "_mouseX");
	private static const fakeMouseY:QName = new QName(mx_internal, "_mouseY");

	/**
	 *  @private
	 */
	override public function get mouseX():Number
	{
		if (!root || root is Stage || root[fakeMouseX] === undefined)
		{
			return super.mouseX;
		}
		return globalToLocal(new Point(root[fakeMouseX], 0)).x;
	}

	/**
	 *  @private
	 */
	override public function get mouseY():Number
	{
		if (!root || root is Stage || root[fakeMouseY] === undefined)
		{
			return super.mouseY;
		}
		return globalToLocal(new Point(0, root[fakeMouseY])).y;
	}


	/**
	 *  Initializes the implementation and storage of some of the less frequently
	 *  used advanced layout features of a component.
	 *
	 *  Call this function before attempting to use any of the features implemented
	 *  by the AdvancedLayoutFeatures object.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	protected function initAdvancedLayoutFeatures():void
	{
		var features:AdvancedLayoutFeatures = new AdvancedLayoutFeatures();

		_hasComplexLayoutMatrix = true;

		features.layoutScaleX = scaleX;
		features.layoutScaleY = scaleY;
		features.layoutScaleZ = scaleZ;
		features.layoutRotationX = rotationX;
		features.layoutRotationY = rotationY;
		features.layoutRotationZ = rotation;
		features.layoutX = x;
		features.layoutY = y;
		features.layoutZ = z;
		features.layoutWidth = width;  // for the mirror transform
		_layoutFeatures = features;
		invalidateTransform();
	}

	/**
	 *  @private
	 *  Helper function to update the storage vairable _transform.
	 *  Also updates the <code>target</code> property of the new and the old
	 *  values.
	 */
	private function setTransform(value:flash.geom.Transform):void
	{
		// Clean up the old transform
		var oldTransform:mx.geom.Transform = _transform as mx.geom.Transform;
		if (oldTransform)
		{
			oldTransform.target = null;
		}

		var newTransform:mx.geom.Transform = value as mx.geom.Transform;

		if (newTransform)
		{
			newTransform.target = this;
		}

		_transform = value;
	}

	mx_internal function get $transform():flash.geom.Transform
	{
		return super.transform;
	}

	/**
	 *  @private
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override public function get transform():flash.geom.Transform
	{
		if (_transform == null)
		{
			setTransform(new mx.geom.Transform(this));
		}
		return _transform;
	}

	/**
	 *  @private
	 */
	override public function set transform(value:flash.geom.Transform):void
	{
		var m:Matrix = value.matrix;
		var m3:Matrix3D = value.matrix3D;
		var ct:ColorTransform = value.colorTransform;
		var pp:PerspectiveProjection = value.perspectiveProjection;

		// validateMatrix when switching between 2D/3D, works around player bug
		// see sdk-23421
		var was3D:Boolean = is3D;

		var mxTransform:mx.geom.Transform = value as mx.geom.Transform;
		if (mxTransform)
		{
			if (!mxTransform.applyMatrix)
			{
				m = null;
			}

			if (!mxTransform.applyMatrix3D)
			{
				m3 = null;
			}
		}

		setTransform(value);

		if (m != null)
		{
			setLayoutMatrix(m.clone(), true /*triggerLayoutPass*/);
		}
		else
		{
			if (m3 != null)
			{
				setLayoutMatrix3D(m3.clone(), true /*triggerLayoutPass*/);
			}
		}

		super.transform.colorTransform = ct;
		super.transform.perspectiveProjection = pp;
		if (maintainProjectionCenter)
		{
			invalidateDisplayList();
		}
		if (was3D != is3D)
		{
			validateMatrix();
		}
	}

	public function get postLayoutTransformOffsets():TransformOffsets
	{
		return (_layoutFeatures != null) ? _layoutFeatures.postLayoutTransformOffsets : null;
	}

	/**
	 * @private
	 */
	public function set postLayoutTransformOffsets(value:TransformOffsets):void
	{
		// validateMatrix when switching between 2D/3D, works around player bug see sdk-23421
		var was3D:Boolean = is3D;

		if (_layoutFeatures == null)
		{
			initAdvancedLayoutFeatures();
		}

		if (_layoutFeatures.postLayoutTransformOffsets != null)
		{
			_layoutFeatures.postLayoutTransformOffsets.removeEventListener(Event.CHANGE, transformOffsetsChangedHandler);
		}
		_layoutFeatures.postLayoutTransformOffsets = value;
		if (_layoutFeatures.postLayoutTransformOffsets != null)
		{
			_layoutFeatures.postLayoutTransformOffsets.addEventListener(Event.CHANGE, transformOffsetsChangedHandler);
		}
		if (was3D != is3D)
		{
			validateMatrix();
		}
	}

	private var _maintainProjectionCenter:Boolean = false;
	/**
	 *  When true, the component keeps its projection matrix centered on the
	 *  middle of its bounding box.  If no projection matrix is defined on the
	 *  component, one is added automatically.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function set maintainProjectionCenter(value:Boolean):void
	{
		_maintainProjectionCenter = value;
		if (value && super.transform.perspectiveProjection == null)
		{
			super.transform.perspectiveProjection = new PerspectiveProjection();
		}
		invalidateDisplayList();
	}

	/**
	 * @private
	 */
	public function get maintainProjectionCenter():Boolean
	{
		return _maintainProjectionCenter;
	}

	public function setLayoutMatrix(value:Matrix, invalidateLayout:Boolean):void
	{
		var previousMatrix:Matrix = _layoutFeatures ? _layoutFeatures.layoutMatrix : super.transform.matrix;

		// validateMatrix when switching between 2D/3D, works around player bug
		// see sdk-23421
		var was3D:Boolean = is3D;
		_hasComplexLayoutMatrix = true;

		if (_layoutFeatures == null)
		{
			// flash will make a copy of this on assignment.
			super.transform.matrix = value;
		}
		else
		{
			// layout features will internally make a copy of this matrix rather than
			// holding onto a reference to it.
			_layoutFeatures.layoutMatrix = value;
			invalidateTransform();
		}

		// Early exit if possible. We don't want to invalidate unnecessarily.
		// We need to do the check here, after our new value has been applied
		// because our matrix components are rounded upon being applied to a
		// DisplayObject.
		if (MatrixUtil.isEqual(previousMatrix, _layoutFeatures ? _layoutFeatures.layoutMatrix : super.transform.matrix))
		{
			return;
		}

		invalidateProperties();

		if (invalidateLayout)
		{
			invalidateParentSizeAndDisplayList();
		}

		if (was3D != is3D)
		{
			validateMatrix();
		}
	}

	public function setLayoutMatrix3D(value:Matrix3D, invalidateLayout:Boolean):void
	{
		// Early exit if possible. We don't want to invalidate unnecessarily.
		if (_layoutFeatures && MatrixUtil.isEqual3D(_layoutFeatures.layoutMatrix3D, value))
		{
			return;
		}

		// validateMatrix when switching between 2D/3D, works around player bug
		// see sdk-23421
		var was3D:Boolean = is3D;

		if (_layoutFeatures == null)
		{
			initAdvancedLayoutFeatures();
		}
		// layout features will internally make a copy of this matrix rather than
		// holding onto a reference to it.
		_layoutFeatures.layoutMatrix3D = value;
		invalidateTransform();

		invalidateProperties();

		if (invalidateLayout)
		{
			invalidateParentSizeAndDisplayList();
		}

		if (was3D != is3D)
		{
			validateMatrix();
		}
	}

	private static var xformPt:Point;

	public function transformAround(transformCenter:Vector3D, scale:Vector3D = null, rotation:Vector3D = null, translation:Vector3D = null, postLayoutScale:Vector3D = null, postLayoutRotation:Vector3D = null, postLayoutTranslation:Vector3D = null, invalidateLayout:Boolean = true):void
	{
		// Make sure that no transform setters will trigger parent invalidation.
		// Reset the flag at the end of the method.
		var oldIncludeInLayout:Boolean;
		if (!invalidateLayout)
		{
			oldIncludeInLayout = _includeInLayout;
			_includeInLayout = false;
		}

		// TODO (chaase): Would be nice to put this function in a central place
		// to be used by UIComponent, SpriteVisualElement, UIMovieClip, and
		// GraphicElement, since they all have similar or identical functions
		if (_layoutFeatures == null)
		{
			// TODO (chaase): should provide a way to return to having no
			// layoutFeatures if we call this later with a more trivial
			// situation
			var needAdvancedLayout:Boolean = (scale != null && ((!isNaN(scale.x) && scale.x != 1) || (!isNaN(scale.y) && scale.y != 1) || (!isNaN(scale.z) && scale.z != 1))) || (rotation != null && ((!isNaN(rotation.x) && rotation.x != 0) || (!isNaN(rotation.y) && rotation.y != 0) || (!isNaN(rotation.z) && rotation.z != 0))) || (translation != null && translation.z != 0 && !isNaN(translation.z)) || postLayoutScale != null || postLayoutRotation != null || (postLayoutTranslation != null && (translation == null || postLayoutTranslation.x != translation.x || postLayoutTranslation.y != translation.y || postLayoutTranslation.z != translation.z));
			if (needAdvancedLayout)
			{
				initAdvancedLayoutFeatures();
			}
		}
		if (_layoutFeatures != null)
		{
			var prevX:Number = _layoutFeatures.layoutX;
			var prevY:Number = _layoutFeatures.layoutY;
			var prevZ:Number = _layoutFeatures.layoutZ;
			_layoutFeatures.transformAround(transformCenter, scale, rotation, translation, postLayoutScale, postLayoutRotation, postLayoutTranslation);
			invalidateTransform();

			// Will not invalidate parent if we have set _includeInLayout to false
			// in the beginning of the method
			invalidateParentSizeAndDisplayList();

			if (prevX != _layoutFeatures.layoutX)
			{
				dispatchEvent(new Event("xChanged"));
			}
			if (prevY != _layoutFeatures.layoutY)
			{
				dispatchEvent(new Event("yChanged"));
			}
			if (prevZ != _layoutFeatures.layoutZ)
			{
				dispatchEvent(new Event("zChanged"));
			}
		}
		else
		{
			if (translation == null && transformCenter != null)
			{
				if (xformPt == null)
				{
					xformPt = new Point();
				}
				xformPt.x = transformCenter.x;
				xformPt.y = transformCenter.y;
				var xformedPt:Point = transform.matrix.transformPoint(xformPt);
			}
			if (rotation != null && !isNaN(rotation.z))
			{
				this.rotation = rotation.z;
			}
			if (scale != null)
			{
				scaleX = scale.x;
				scaleY = scale.y;
			}
			if (transformCenter == null)
			{
				if (translation != null)
				{
					x = translation.x;
					y = translation.y;
				}
			}
			else
			{
				if (xformPt == null)
				{
					xformPt = new Point();
				}
				xformPt.x = transformCenter.x;
				xformPt.y = transformCenter.y;
				var postXFormPoint:Point = transform.matrix.transformPoint(xformPt);
				if (translation != null)
				{
					x += translation.x - postXFormPoint.x;
					y += translation.y - postXFormPoint.y;
				}
				else
				{
					x += xformedPt.x - postXFormPoint.x;
					y += xformedPt.y - postXFormPoint.y;
				}
			}
		}

		if (!invalidateLayout)
		{
			_includeInLayout = oldIncludeInLayout;
		}
	}

	/**
	 * A utility method to transform a point specified in the local
	 * coordinates of this object to its location in the object's parent's
	 * coordinates. The pre-layout and post-layout result is set on
	 * the <code>position</code> and <code>postLayoutPosition</code>
	 * parameters, if they are non-null.
	 *
	 * @param localPosition The point to be transformed, specified in the
	 * local coordinates of the object.
	 * @position A Vector3D point that holds the pre-layout
	 * result. If null, the parameter is ignored.
	 * @postLayoutPosition A Vector3D point that holds the post-layout
	 * result. If null, the parameter is ignored.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function transformPointToParent(localPosition:Vector3D, position:Vector3D, postLayoutPosition:Vector3D):void
	{
		if (_layoutFeatures != null)
		{
			_layoutFeatures.transformPointToParent(true, localPosition, position, postLayoutPosition);
		}
		else
		{
			if (xformPt == null)
			{
				xformPt = new Point();
			}
			if (localPosition)
			{
				xformPt.x = localPosition.x;
				xformPt.y = localPosition.y;
			}
			else
			{
				xformPt.x = 0;
				xformPt.y = 0;
			}
			var tmp:Point = (transform.matrix != null) ? transform.matrix.transformPoint(xformPt) : xformPt;
			if (position != null)
			{
				position.x = tmp.x;
				position.y = tmp.y;
				position.z = 0;
			}
			if (postLayoutPosition != null)
			{
				postLayoutPosition.x = tmp.x;
				postLayoutPosition.y = tmp.y;
				postLayoutPosition.z = 0;
			}
		}
	}

	/**
	 *  The transform matrix that is used to calculate a component's layout
	 *  relative to its siblings. This matrix is defined by the component's
	 *  3D properties (which include the 2D properties such as <code>x</code>,
	 *  <code>y</code>, <code>rotation</code>, <code>scaleX</code>,
	 *  <code>scaleY</code>, <code>transformX</code>, and
	 *  <code>transformY</code>, as well as <code>rotationX</code>,
	 *  <code>rotationY</code>, <code>scaleZ</code>, <code>z</code>, and
	 *  <code>transformZ</code>.
	 *
	 *  <p>Most components do not have any 3D transform properties set on them.</p>
	 *
	 *  <p>This layout matrix is combined with the values of the
	 *  <code>postLayoutTransformOffsets</code> property to determine the
	 *  component's final, computed matrix.</p>
	 *
	 *  @see #postLayoutTransformOffsets
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function set layoutMatrix3D(value:Matrix3D):void
	{
		setLayoutMatrix3D(value, true /*invalidateLayout*/);
	}

	public function get depth():Number
	{
		return (_layoutFeatures == null) ? 0 : _layoutFeatures.depth;
	}

	public function set depth(value:Number):void
	{
		if (value == depth)
		{
			return;
		}
		if (_layoutFeatures == null)
		{
			initAdvancedLayoutFeatures();
		}

		_layoutFeatures.depth = value;
		if (parent is UIComponent)
		{
			UIComponent(parent).invalidateLayering();
		}
	}

	/**
	 *  Commits the computed matrix built from the combination of the layout
	 *  matrix and the transform offsets to the flash displayObject's transform.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	protected function applyComputedMatrix():void
	{
		_layoutFeatures.updatePending = false;
		if (_layoutFeatures.is3D)
		{
			super.transform.matrix3D = _layoutFeatures.computedMatrix3D;
		}
		else
		{
			super.transform.matrix = _layoutFeatures.computedMatrix;
		}
	}

	/**
	 *  Specifies a transform stretch factor in the horizontal and vertical direction.
	 *  The stretch factor is applied to the computed matrix before any other transformation.
	 *  @param stretchX The horizontal component of the stretch factor.
	 *  @param stretchY The vertical component of the stretch factor.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	protected function setStretchXY(stretchX:Number, stretchY:Number):void
	{
		if (_layoutFeatures == null)
		{
			initAdvancedLayoutFeatures();
		}
		if (stretchX != _layoutFeatures.stretchX || stretchY != _layoutFeatures.stretchY)
		{
			_layoutFeatures.stretchX = stretchX;
			_layoutFeatures.stretchY = stretchY;
			invalidateTransform();
		}
	}

	//--------------------------------------------------------------------------
	//
	//  ILayoutElement
	//
	//--------------------------------------------------------------------------

	public function getPreferredBoundsWidth(postLayoutTransform:Boolean = true):Number
	{
		return LayoutElementUIComponentUtils.getPreferredBoundsWidth(this, postLayoutTransform ? nonDeltaLayoutMatrix() : null);
	}

	public function getPreferredBoundsHeight(postLayoutTransform:Boolean = true):Number
	{
		return LayoutElementUIComponentUtils.getPreferredBoundsHeight(this, postLayoutTransform ? nonDeltaLayoutMatrix() : null);
	}

	public function getMinBoundsWidth(postLayoutTransform:Boolean = true):Number
	{
		return LayoutElementUIComponentUtils.getMinBoundsWidth(this, postLayoutTransform ? nonDeltaLayoutMatrix() : null);
	}

	public function getMinBoundsHeight(postLayoutTransform:Boolean = true):Number
	{
		return LayoutElementUIComponentUtils.getMinBoundsHeight(this, postLayoutTransform ? nonDeltaLayoutMatrix() : null);
	}

	public function getMaxBoundsWidth(postLayoutTransform:Boolean = true):Number
	{
		return LayoutElementUIComponentUtils.getMaxBoundsWidth(this, postLayoutTransform ? nonDeltaLayoutMatrix() : null);
	}

	public function getMaxBoundsHeight(postLayoutTransform:Boolean = true):Number
	{
		return LayoutElementUIComponentUtils.getMaxBoundsHeight(this, postLayoutTransform ? nonDeltaLayoutMatrix() : null);
	}

	public function getBoundsXAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
	{
		return LayoutElementUIComponentUtils.getBoundsXAtSize(this, width, height, postLayoutTransform ? nonDeltaLayoutMatrix() : null);
	}

	public function getBoundsYAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
	{
		return LayoutElementUIComponentUtils.getBoundsYAtSize(this, width, height, postLayoutTransform ? nonDeltaLayoutMatrix() : null);
	}

	public function getLayoutBoundsWidth(postLayoutTransform:Boolean = true):Number
	{
		return LayoutElementUIComponentUtils.getLayoutBoundsWidth(this, postLayoutTransform ? nonDeltaLayoutMatrix() : null);
	}

	public function getLayoutBoundsHeight(postLayoutTransform:Boolean = true):Number
	{
		return LayoutElementUIComponentUtils.getLayoutBoundsHeight(this, postLayoutTransform ? nonDeltaLayoutMatrix() : null);
	}

	public function getLayoutBoundsX(postLayoutTransform:Boolean = true):Number
	{
		return LayoutElementUIComponentUtils.getLayoutBoundsX(this, postLayoutTransform ? nonDeltaLayoutMatrix() : null);
	}

	public function getLayoutBoundsY(postLayoutTransform:Boolean = true):Number
	{
		return LayoutElementUIComponentUtils.getLayoutBoundsY(this, postLayoutTransform ? nonDeltaLayoutMatrix() : null);
	}

	public function setLayoutBoundsPosition(x:Number, y:Number, postLayoutTransform:Boolean = true):void
	{
		LayoutElementUIComponentUtils.setLayoutBoundsPosition(this, x, y, postLayoutTransform ? nonDeltaLayoutMatrix() : null);
	}

	public function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean = true):void
	{
		LayoutElementUIComponentUtils.setLayoutBoundsSize(this, width, height, postLayoutTransform ? nonDeltaLayoutMatrix() : null);
	}

	public function getLayoutMatrix():Matrix
	{
		if (_layoutFeatures != null || super.transform.matrix == null)
		{
			// TODO: this is a workaround for a situation in which the
			// object is in 2D, but used to be in 3D and the player has not
			// yet cleaned up the matrices. So the matrix property is null, but
			// the matrix3D property is non-null. layoutFeatures can deal with
			// that situation, so we allocate it here and let it handle it for
			// us. The downside is that we have now allocated layoutFeatures
			// forever and will continue to use it for future situations that
			// might not have required it. Eventually, we should recognize
			// situations when we can de-allocate layoutFeatures and back off
			// to letting the player handle transforms for us.
			if (_layoutFeatures == null)
			{
				initAdvancedLayoutFeatures();
			}

			// esg: _layoutFeatures keeps a single internal copy of the layoutMatrix.
			// since this is an internal class, we don't need to worry about developers
			// accidentally messing with this matrix, _unless_ we hand it out. Instead,
			// we hand out a clone.
			return _layoutFeatures.layoutMatrix.clone();
		}
		else
		{
			// flash also returns copies.
			return super.transform.matrix;
		}
	}

	public function get hasLayoutMatrix3D():Boolean
	{
		return _layoutFeatures ? _layoutFeatures.layoutIs3D : false;
	}

	public function get is3D():Boolean
	{
		return _layoutFeatures ? _layoutFeatures.is3D : false;
	}

	public function getLayoutMatrix3D():Matrix3D
	{
		if (_layoutFeatures == null)
		{
			initAdvancedLayoutFeatures();
		}
		// esg: _layoutFeatures keeps a single internal copy of the layoutMatrix.
		// since this is an internal class, we don't need to worry about developers
		// accidentally messing with this matrix, _unless_ we hand it out. Instead,
		// we hand out a clone.
		return _layoutFeatures.layoutMatrix3D.clone();
	}

	/**
	 *  @private
	 */
	protected function nonDeltaLayoutMatrix():Matrix
	{
		if (!hasComplexLayoutMatrix)
		{
			return null;
		}
		if (_layoutFeatures != null)
		{
			return _layoutFeatures.layoutMatrix;
		}
		else
		{
			return super.transform.matrix;
		}
	}
}
}

class MethodQueueElement
{
	public function MethodQueueElement(method:Function, args:Array /* of Object */ = null)
	{
		super();

		this.method = method;
		this.args = args;
	}

	/**
	 *  A reference to the method to be called.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var method:Function;

	/**
	 *  The arguments to be passed to the method.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var args:Array /* of Object */;
}