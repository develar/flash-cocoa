package cocoa {
import cocoa.layout.VirtualVerticalDataGroupLayout;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.geom.PerspectiveProjection;
import flash.geom.Rectangle;

import mx.collections.IList;
import mx.core.IDataRenderer;
import mx.core.IFactory;
import mx.core.IInvalidating;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.PropertyChangeEvent;
import mx.utils.MatrixUtil;

import spark.components.IItemRenderer;
import spark.components.IItemRendererOwner;
import spark.components.supportClasses.GroupBase;
import spark.events.RendererExistenceEvent;
import spark.layouts.HorizontalAlign;
import spark.layouts.VerticalLayout;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

/**
 * Support virtual layout for itemRendererFunction
 * Doesn't support layering (depth) and typical item
 */
public class FlexDataGroup extends GroupBase implements IItemRendererOwner, View, LookAndFeelProvider {
  // disable unwanted legacy
  include "../../legacyConstraints.as";
  include "../../unwantedLegacy.as";

  /**
   * Maps from renderer index (same as dataProvider index) to the item renderer itself.
   */
  private var indexToRenderer:Vector.<IVisualElement> = new Vector.<IVisualElement>();

  /**
   * The set of layout element indices requested with getVirtualElementAt()
   * during updateDisplayList(), and the set of "old" indices that were requested
   * in the previous pass.  These vectors are used by finishVirtualLayout()
   * to distinguish IRs that can be recycled or discarded. The virtualRendererIndices
   * vector is used in various places to iterate over all of the virtual renderers.
   */
  private var virtualRendererIndices:Vector.<int>;
  private var oldVirtualRendererIndices:Vector.<int>;

  /**
   * During a virtual layout, virtualLayoutUnderway is true. This flag is used
   * to defeat calls to invalidateSize(), which occur when IRs are lazily validated.
   * See invalidateSize() and updateDisplayList().
   */
  private var virtualLayoutUnderway:Boolean = false;

  /**
   * freeRenderers - IRs that were created by getLayoutElementAt() but are no longer in view.
   * They'll be reused by getLayoutElementAt(). The list is updated by finishVirtualLayout().
   */
  private const freeRenderers:Vector.<IVisualElement> = new Vector.<IVisualElement>();

  /**
   *  True if we are updating a renderer currently.
   *  We keep track of this so we can ignore any dataProvider collectionChange
   *  UPDATE events while we are updating a renderer just in case we try to update
   *  the rendererInfo of the same renderer twice.  This can happen if setting the
   *  data in an item renderer causes the data to mutate and issue a propertyChange
   *  event, which causes an collectionChange.UPDATE event in the dataProvider.  This
   *  can happen for components which are being treated as data because the first time
   *  they get set on the renderer, they get added to the display list, which may
   *  cause a propertyChange event (if there's a child with an ID in it, that causes
   *  a propertyChange event) or the data to morph in some way.
   */
  private var renderersBeingUpdated:Boolean = false;

  public function FlexDataGroup() {
    _rendererUpdateDelegate = this;
  }

  protected var _laf:LookAndFeel;
  public function get laf():LookAndFeel {
    return _laf;
  }

  public function set laf(value:LookAndFeel):void {
    _laf = value;
  }

  override protected function createChildren():void {
    if (layout == null) {
      layout = new VirtualVerticalDataGroupLayout();
    }

    super.childrenCreated();
  }

  override public function parentChanged(p:DisplayObjectContainer):void {
    super.parentChanged(p);

    if (p != null) {
      _parent = p; // так как наше AbstractView не есть ни IStyleClient, ни ISystemManager
    }
  }

  public final function addDisplayObject(displayObject:DisplayObject, index:int = -1):void {
    $addChildAt(displayObject, index == -1 ? numChildren : index);
  }

  public final function removeDisplayObject(displayObject:DisplayObject):void {
    $removeChild(displayObject);
  }

  override public function get baselinePosition():Number {
    if (!validateBaselinePosition()) {
      return NaN;
    }

    if (numElements == 0) {
      return super.baselinePosition;
    }

    return getElementAt(0).baselinePosition + getElementAt(0).y;
  }

  private var useVirtualLayoutChanged:Boolean = false;

  override public function set layout(value:LayoutBase):void {
    var oldLayout:LayoutBase = layout;
    if (value == oldLayout) {
      return;
    }

    if (oldLayout) {
      oldLayout.typicalLayoutElement = null;
      oldLayout.removeEventListener("useVirtualLayoutChanged", layout_useVirtualLayoutChangedHandler);
    }
    // Changing the layout may implicitly change layout.useVirtualLayout
    if (oldLayout && value && (oldLayout.useVirtualLayout != value.useVirtualLayout)) {
      changeUseVirtualLayout();
    }

    super.layout = value;

    if (value) {
      value.addEventListener("useVirtualLayoutChanged", layout_useVirtualLayoutChangedHandler);
    }
  }

  /**
   * If layout.useVirtualLayout changes, recreate the ItemRenderers.  This can happen
   * if the layout's useVirtualLayout property is changed directly, or if the DataGroup's layout is changed.
   */
  private function changeUseVirtualLayout():void {
    removeDataProviderListener();
    removeAllItemRenderers();
    useVirtualLayoutChanged = true;
    invalidateProperties();
  }

  private function layout_useVirtualLayoutChangedHandler(event:Event):void {
    changeUseVirtualLayout();
  }

  private var _itemRenderer:IFactory;
  private var itemRendererChanged:Boolean;

  [Inspectable(category="Data")]

  /**
   *  The item renderer to use for data items.
   *  The class must implement the IDataRenderer interface.
   *  If defined, the <code>itemRendererFunction</code> property
   *  takes precedence over this property.
   *
   *  @default null
   *
   *  @langversion 3.0
   *  @playerversion Flash 10
   *  @playerversion AIR 1.5
   *  @productversion Flex 4
   */
  public function get itemRenderer():IFactory {
    return _itemRenderer;
  }

  public function set itemRenderer(value:IFactory):void {
    _itemRenderer = value;

    removeDataProviderListener();
    removeAllItemRenderers();
    invalidateProperties();

    itemRendererChanged = true;
  }

  private var _itemRendererFunction:Function;

  [Inspectable(category="Data")]

  /**
   *  Function that returns an item renderer IFactory for a
   *  specific item.  You should define an item renderer function
   *  similar to this sample function:
   *
   *  <pre>
   *    function myItemRendererFunction(item:Object):IFactory</pre>
   */
  public function get itemRendererFunction():Function {
    return _itemRendererFunction;
  }

  public function set itemRendererFunction(value:Function):void {
    _itemRendererFunction = value;

    removeDataProviderListener();
    removeAllItemRenderers();
    invalidateProperties();

    itemRendererChanged = true;
  }

  private var _rendererUpdateDelegate:IItemRendererOwner;

  /**
   *  The rendererUpdateDelgate is used to delegate item renderer
   *  updates to another component, usually the owner of the
   *  DataGroup within the context of data centric component such
   *  as List.
   *
   *  The registered delegate must implement the IItemRendererOwner interface.
   */
  mx_internal function get rendererUpdateDelegate():IItemRendererOwner {
    return _rendererUpdateDelegate;
  }

  mx_internal function set rendererUpdateDelegate(value:IItemRendererOwner):void {
    _rendererUpdateDelegate = value;
  }

  private var _dataProvider:IList;
  private var dataProviderChanged:Boolean;

  [Bindable("dataProviderChanged")]
  /**
   *  The data provider for this DataGroup.
   *  It must be an IList.
   *
   *  <p>There are several IList implementations included in the
   *  Flex framework, including ArrayCollection, ArrayList, and
   *  XMLListCollection.</p>
   *
   *  @default null
   *
   *  @see #itemRenderer
   *  @see #itemRendererFunction
   *  @see mx.collections.IList
   *  @see mx.collections.ArrayCollection
   *  @see mx.collections.ArrayList
   *  @see mx.collections.XMLListCollection
   */
  public function get dataProvider():IList {
    return _dataProvider;
  }

  public function set dataProvider(value:IList):void {
    if (_dataProvider == value) {
      return;
    }

    removeDataProviderListener();
    _dataProvider = value;  // listener will be added by commitProperties()
    dataProviderChanged = true;
    invalidateProperties();
    dispatchEvent(new Event("dataProviderChanged"));
  }

  /**
   * Used below for sorting the virtualRendererIndices Vector.
   */
  private static function sortDecreasing(x:int, y:int):Number {
    return y - x;
  }

  /**
   *  Apply itemRemoved() to the renderer and dataProvider item at index.
   */
  private function removeRendererAt(index:int):void {
    // TODO (rfrishbe): we can't key off of the oldDataProvider for 
    // the item because it might not be there anymore (for instance, 
    // in a dataProvider reset where the new data is loaded into 
    // the dataProvider--the dataProvider doesn't actually change, 
    // but we still need to clean up).
    // Because of this, we are assuming the item is either:
    //   1.  The data property if the item implements IDataRenderer 
    //       and there is an itemRenderer or itemRendererFunction
    //   2.  The item itself

    // Probably could fix above by also storing indexToData[], but that doesn't 
    // seem worth it.  Sending in the wrong item here doesn't result in a big error...
    // just the event with have the wrong item associated with it

    const renderer:IVisualElement = indexToRenderer[index] as IVisualElement;
    itemRemoved(renderer is IDataRenderer && (itemRenderer != null || itemRendererFunction != null) ? IDataRenderer(renderer).data : renderer, index);
  }

  /**
   *  Remove all of the item renderers, clear the indexToRenderer table, clear
   *  any cached virtual layout data.  Note that
   *  this method does not depend on the dataProvider itself, see removeRendererAt().
   */
  private function removeAllItemRenderers():void {
    if (indexToRenderer.length == 0) {
      return;
    }

    if (virtualRendererIndices != null && virtualRendererIndices.length > 0) {
      for each (var index:int in virtualRendererIndices.concat().sort(sortDecreasing)) {
        removeRendererAt(index);
      }

      virtualRendererIndices.length = 0;
      oldVirtualRendererIndices.length = 0;

      for (var i:int = freeRenderers.length - 1; i >= 0; i--) {
        super.removeChild(freeRenderers[i] as DisplayObject);
      }

      freeRenderers.length = 0;
    }
    else {
      for (index = indexToRenderer.length - 1; index >= 0; index--) {
        removeRendererAt(index);
      }
    }

    indexToRenderer.length = 0;

    if (layout != null) {
      layout.clearVirtualLayoutCache();
    }
  }

  /**
   *  @inheritDoc
   *
   *  Given a data item, return the toString() representation of the data item for an item renderer to display.
   *  Null data items return the empty string.
   */
  public function itemToLabel(item:Object):String {
    if (item !== null) {
      return item.toString();
    }
    return " ";
  }

  //noinspection JSUnusedGlobalSymbols
  /**
   *  Return the indices of the item renderers visible within this DataGroup.
   *
   *  <p>If clipAndEnableScrolling=true, return the indices of the visible=true
   *  ItemRenderers that overlap this DataGroup's scrollRect, i.e. the ItemRenders
   *  that are at least partially visible relative to this DataGroup.  If
   *  clipAndEnableScrolling=false, return a list of integers from
   *  0 to dataProvider.length - 1.  Note that if this DataGroup's owner is a
   *  Scroller, then clipAndEnableScrolling has been set to true.</p>
   *
   *  <p>The corresponding item renderer for each returned index can be
   *  retrieved with getElementAt(), even if the layout is virtual</p>
   *
   *  <p>The order of the items in the returned Vector is not guaranteed.</p>
   *
   *  <p>Note that the VerticalLayout and HorizontalLayout classes provide bindable
   *  firstIndexInView and lastIndexInView properties which convey the same information
   *  as this method.</p>
   *
   *  @return The indices of the visible item renderers.
   */
  public function getItemIndicesInView():Vector.<int> {
    if (layout && layout.useVirtualLayout) {
      return (virtualRendererIndices) ? virtualRendererIndices.concat() : new Vector.<int>(0);
    }

    if (!dataProvider) {
      return new Vector.<int>(0);
    }

    const scrollR:Rectangle = scrollRect;
    const dataProviderLength:int = dataProvider.length;

    if (scrollR) {
      const visibleIndices:Vector.<int> = new Vector.<int>();
      const eltR:Rectangle = new Rectangle();
      const perspectiveProjection:PerspectiveProjection = transform.perspectiveProjection;

      for (var index:int = 0; index < dataProviderLength; index++) {
        var elt:IVisualElement = getElementAt(index);
        if (!elt || !elt.visible)
          continue;

        // TODO (egeorgie): provide a generic getElementBounds() utility function
        if (elt.hasLayoutMatrix3D && perspectiveProjection) {
          eltR.x = 0;
          eltR.y = 0;
          eltR.width = elt.getLayoutBoundsWidth(false);
          eltR.height = elt.getLayoutBoundsHeight(false);
          MatrixUtil.projectBounds(eltR, elt.getLayoutMatrix3D(), perspectiveProjection);
        }
        else {
          eltR.x = elt.getLayoutBoundsX();
          eltR.y = elt.getLayoutBoundsY();
          eltR.width = elt.getLayoutBoundsWidth();
          eltR.height = elt.getLayoutBoundsHeight();
        }

        if (scrollR.intersects(eltR))
          visibleIndices.push(index);
      }

      return visibleIndices;
    }
    else {
      const allIndices:Vector.<int> = new Vector.<int>(dataProviderLength);
      for (index = 0; index < dataProviderLength; index++)
        allIndices[index] = index;
      return allIndices;
    }
  }

  /**
   * Create the item renderer for the item, if needed.
   *
   *  <p>The rules to create a visual item are:</p>
   *  <ol><li>if itemRendererFunction is defined, call
   *  it to get the renderer factory and instantiate it</li>
   *  <li>if itemRenderer is defined, instantiate one</li>
   *  <li>if item is an IVisualElement and a DisplayObject, use it directly</li></ol>
   *
   *  @param item The data element.
   *  @return The renderer that represents the data element.
   */
  private function createRendererForItem(item:Object, failRTE:Boolean = true):IVisualElement {
    // Rules for lookup:
    // 1. if itemRendererFunction is defined, call it to get the renderer factory and instantiate it
    // 2. if itemRenderer is defined, instantiate one
    // 3. if item is an IVisualElement and a DisplayObject, use it directly

    // 1. if itemRendererFunction is defined, call it to get the renderer factory and instantiate it    
    if (itemRendererFunction != null) {
      var rendererFactory:IFactory = itemRendererFunction(item);
      // if the function returned a factory, use that. otherwise, if it returned null, try using the item directly
      if (rendererFactory != null) {
        return rendererFactory.newInstance();
      }
      else if (item is IVisualElement && item is DisplayObject) {
        return IVisualElement(item);
      }
    }

    // 2. if itemRenderer is defined, instantiate one
    if (itemRenderer != null) {
      return itemRenderer.newInstance();
    }

    // 3. if item is an IVisualElement and a DisplayObject, use it directly
    if (item is IVisualElement && item is DisplayObject) {
      return IVisualElement(item);
    }

    // Couldn't find item renderer.  Throw an RTE.
    if (failRTE) {
      throw new Error(item is IVisualElement || item is DisplayObject ? "cannotDisplayVisualElement" : "unableToCreateRenderer");
    }

    return null;
  }

  /**
   * If layout.useVirtualLayout=false, then ensure that there's one item
   * renderer for every dataProvider item. This method is only intended to be called by commitProperties().
   *
   *  Reuse as many of the IItemRenderer renderers in indexToRenders as possible.
   *  Note that if itemRendererFunction was specified, we can reuse any of them.
   */
  private function createItemRenderers():void {
    if (!dataProvider) {
      removeAllItemRenderers();
      return;
    }

    if (layout != null && layout.useVirtualLayout) {
      // Add any existing renderers to the free list. A side-effect of
      // this is that their layoutBoundsSize will be zero'ed so they will remeasure the new data correctly.
      if (virtualRendererIndices != null && virtualRendererIndices.length > 0) {
        startVirtualLayout();
        finishVirtualLayout();
      }

      // The item renderers will be created lazily, at updateDisplayList() time
      invalidateSize();
      invalidateDisplayList();
      return;
    }

    const dataProviderLength:int = dataProvider.length;
    // Remove the renderers we're not going to need
    for (var index:int = indexToRenderer.length - 1; index >= dataProviderLength; index--) {
      removeRendererAt(index);
    }

    // Reset the existing renderers
    for (index = 0; index < indexToRenderer.length; index++) {
      var item:Object = dataProvider.getItemAt(index);
      var renderer:IVisualElement = indexToRenderer[index];
      if (renderer != null) {
        setUpItemRenderer(renderer, index, item);
      }
      // can't reuse this renderer
      else {
        removeRendererAt(index);
        itemAdded(item, index);
      }
    }

    // Create new renderers
    for (index = indexToRenderer.length; index < dataProviderLength; index++) {
      itemAdded(dataProvider.getItemAt(index), index);
    }
  }

  override protected function commitProperties():void {
    // If the itemRenderer, itemRendererFunction, or useVirtualLayout properties changed,
    // then recreate the item renderers from scratch.  If just the dataProvider changed,
    // and layout.useVirtualLayout=false, then reuse as many item renderers as possible,
    // remove the extra ones, or create more as needed.

    if (itemRendererChanged || useVirtualLayoutChanged || dataProviderChanged) {
      itemRendererChanged = false;
      useVirtualLayoutChanged = false;

      // item renderers and the dataProvider listener have already been removed
      createItemRenderers();
      addDataProviderListener();

      // Don't reset the scroll positions until the new ItemRenderers have been
      // created, see bug https://bugs.adobe.com/jira/browse/SDK-23175
      if (dataProviderChanged) {
        dataProviderChanged = false;
        verticalScrollPosition = horizontalScrollPosition = 0;
      }

      maskChanged = true;
    }

    // Need to create item renderers before calling super.commitProperties()
    // GroupBase's commitProperties reattaches the mask
    super.commitProperties();
  }

  /**
   *  Sets the renderer's data, owner and label properties.
   *  It does this by calling rendererUpdateDelegate.updateRenderer().
   *  By default, rendererUpdateDelegate points to ourselves, but if the "true owner" of the item renderer is a List, then the
   *  rendererUpdateDelegate points to that object. The rendererUpdateDelegate.updateRenderer() call is in charge of
   *  setting all the properties on the renderer, like owner, itemIndex,
   *  data, selected, etc... Note that data should be the last property set in this lifecycle.
   */
  private function setUpItemRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void {
    if (renderer == null) {
      return;
    }

    // keep track of whether we are actively updating an renderers 
    // so we can ignore any collectionChange.UPDATE events
    renderersBeingUpdated = true;

    // Defer to the rendererUpdateDelegate
    // to update the renderer.  By default, the delegate is DataGroup
    _rendererUpdateDelegate.updateRenderer(renderer, itemIndex, data);

    // technically if this got called "recursively", this renderersBeingUpdated flag
    // would be prematurely set to false, but in most cases, this check should be 
    // good enough.
    renderersBeingUpdated = false;
  }

  public function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void {
    renderer.owner = this;

    if (renderer is IItemRenderer) {
      IItemRenderer(renderer).itemIndex = itemIndex;
      IItemRenderer(renderer).label = itemToLabel(data);
    }

    if (renderer is LookAndFeelProvider && _laf != null) {
      LookAndFeelProvider(renderer).laf = _laf;
    }

    // always set the data last
    if (renderer is IDataRenderer && renderer !== data) {
      IDataRenderer(renderer).data = data;
    }
  }

  override public function get numElements():int {
    return dataProvider != null ? dataProvider.length : 0;
  }

  private function startVirtualLayout():void {
    // lazily create the virtualRendererIndices vectors
    if (virtualRendererIndices == null) {
      virtualRendererIndices = new Vector.<int>();
      oldVirtualRendererIndices = new Vector.<int>();
    }
    else {
      var temp:Vector.<int> = virtualRendererIndices;
      virtualRendererIndices = oldVirtualRendererIndices;
      virtualRendererIndices.length = 0;

      oldVirtualRendererIndices = temp;
    }
  }

  /**
   *  Called after super.updateDisplayList() finishes.  Also called by
   *  createItemRenderers to recycle existing renderers that were added
   *  to oldVirtualRendererIndices by the preceeding call to
   *  startVirtualLayout.
   *
   *  Discard the ItemRenderers that aren't needed anymore, i.e. the ones
   *  not explicitly requested with getVirtualElementAt() during the most
   *  recent super.updateDisplayList().
   *
   *  Discarded IRs may be added to the freeRenderers list per the rules
   *  defined in getVirtualElementAt().  If any visible renderer has a non-zero
   *  depth we resort all of them with manageDisplayObjectLayers().
   */
  private function finishVirtualLayout():void {
    if (oldVirtualRendererIndices.length == 0) {
      return;
    }

    for each (var virtualIndex:int in oldVirtualRendererIndices) {
      // Skip renderers that are still in view.
      if (virtualRendererIndices.indexOf(virtualIndex) != -1) {
        continue;
      }

      // Remove previously "in view" IR from the item=>IR table
      var renderer:IVisualElement = indexToRenderer[virtualIndex];
      indexToRenderer[virtualIndex] = null;

      // Free or remove the IR.
      var item:Object = dataProvider.length > virtualIndex ? dataProvider.getItemAt(virtualIndex) : null;
      if (item != renderer && renderer is IDataRenderer) {
        // IDataRenderer(elt).data = null;  see https://bugs.adobe.com/jira/browse/SDK-20962
        renderer.includeInLayout = false;
        renderer.visible = false;

        // If the width isn't constrained, reset the size back to (0,0), otherwise when the element is reused
        // it will be validated at its last layout size which causes problems with text reflow.
        if (!(layout is VerticalLayout && VerticalLayout(layout).horizontalAlign == HorizontalAlign.JUSTIFY) && !(layout is VirtualVerticalDataGroupLayout)) {
          renderer.setLayoutBoundsSize(0, 0, false);
        }

        freeRenderers.push(renderer);
      }
      else if (renderer != null) {
        if (hasEventListener(RendererExistenceEvent.RENDERER_REMOVE)) {
          dispatchEvent(new RendererExistenceEvent(RendererExistenceEvent.RENDERER_REMOVE, false, false, renderer, virtualIndex, item));
        }
        super.removeChild(DisplayObject(renderer));
      }
    }
  }

 /**
   *  During virtual layout getLayoutElementAt() eagerly validates lazily
   *  created (or recycled) IRs.   We don't want changes to those IRs to
   *  invalidate the size of this UIComponent.
   */
  override public function invalidateSize():void {
    if (!virtualLayoutUnderway) {
      super.invalidateSize();
    }
  }

  /**
   *  Manages the state required by virtual layout.
   */
  override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
    drawBackground();

    if (layout != null && layout.useVirtualLayout) {
      virtualLayoutUnderway = true;
      startVirtualLayout();
    }

    super.updateDisplayList(unscaledWidth, unscaledHeight);

    if (virtualLayoutUnderway) {
      finishVirtualLayout();
      virtualLayoutUnderway = false;
    }
  }

  /**
   *  Returns the ItemRenderer being used for the data provider item at the specified index.
   *  Note that if the layout is virtual, ItemRenderers that are scrolled
   *  out of view may be reused.
   *
   *  @param index The index of the data provider item.
   *
   *  @return The ItemRenderer being used for the data provider item
   *  If the index is invalid, or if a data provider was not specified, then
   *  return <code>null</code>.
   *  If the layout is virtual and the specified item is not in view, then
   *  return <code>null</code>.
   *
   *  @langversion 3.0
   *  @playerversion Flash 10
   *  @playerversion AIR 1.5
   *  @productversion Flex 4
   */
  override public function getElementAt(index:int):IVisualElement {
    return index < 0 || index >= indexToRenderer.length ? null : indexToRenderer[index];
  }

  /**
   *  Currently, item renderers ("IRs") can only be recycled if they're all of the same type, they implement IDataRenderer, and they're all
   *  produced - by the itemRenderer factory - with the same initial configuration. We can't ever really guarantee this however the case
   *  for which we're assuming that it's true is when just the itemRenderer is specified. Even in this case, for recycling to work the
   *  itemRenderer (factory) must be essentially stateless, the IRs appearance must be based exclusively on its data. For this reason
   *  we're also defeating recycling of IRs that don't implement IDataRenderer, see endVirtualLayout(). Although one could recycle
   *  these IRs, doing so would imply that either all of the IRs were the same, or that some did implement IDataRenderer and others
   *  did not. We can't handle the latter, and a DataGroup where all items are the same wouldn't be worth the trouble.
   */
  override public function getVirtualElementAt(index:int, rendererWidth:Number = NaN, rendererHeight:Number = NaN):IVisualElement {
    if (index < 0 || dataProvider == null || index >= dataProvider.length) {
      return null;
    }

    var renderer:IVisualElement = index < indexToRenderer.length ? indexToRenderer[index] : null;
    if (virtualLayoutUnderway) {
      if (virtualRendererIndices.indexOf(index) == -1) {
        virtualRendererIndices.push(index);
      }

      var createdIR:Boolean = false;
      const item:Object = dataProvider.getItemAt(index);
      if (renderer == null) {
        if (freeRenderers.length > 0) {
          renderer = itemRendererFunction == null ? freeRenderers.pop() : findSutableFreeRenderer(item);
        }

        if (renderer == null) {
          renderer = createRendererForItem(item);
          createdIR = true;
        }
        else {
          renderer.visible = true;
          renderer.includeInLayout = true;
        }

        indexToRenderer[index] = renderer;

        addItemRendererToDisplayList(DisplayObject(renderer));
        setUpItemRenderer(renderer, index, item);
      }
      else {
        // No need to set the data and label in the IR again.
        // The collectionChangeHandler will handle updates to data.
        addItemRendererToDisplayList(DisplayObject(renderer));
      }

      if (!isNaN(rendererWidth) || !isNaN(rendererHeight)) {
        // If we're going to set the width or height of this layout element, first force it to initialize its measuredWidth,Height.    
        if (renderer is IInvalidating) {
          IInvalidating(renderer).validateNow();
        }
        renderer.setLayoutBoundsSize(rendererWidth, rendererHeight);
      }

      if (renderer is IInvalidating) {
        IInvalidating(renderer).validateNow();
      }

      if (createdIR && hasEventListener(RendererExistenceEvent.RENDERER_ADD)) {
        dispatchEvent(new RendererExistenceEvent(RendererExistenceEvent.RENDERER_ADD, false, false, renderer, index, item));
      }
    }

    return renderer;
  }

  private function findSutableFreeRenderer(item:Object):IVisualElement {
    var factory:IFactory = itemRendererFunction(item);
    var renderer:IVisualElement;
    for (var i:int = freeRenderers.length - 1; i > -1; i--) {
      renderer = freeRenderers[i];
      if (renderer != null && itemRendererFunction(IDataRenderer(renderer).data) == factory) {
        freeRenderers[i] = null;
        if (i == (freeRenderers.length - 1)) {
          freeRenderers.length = i;
        }
        return renderer;
      }
    }

    return null;
  }

  /**
   *  Returns the index of the data provider item
   *  that the specified item renderer
   *  is being used for, or -1 if there is no such item.
   *  Note that if the layout is virtual, ItemRenderers that are scrolled
   *  out of view may be reused.
   *
   *  @param element The item renderer.
   *
   *  @return The index of the data provider item.
   *  If <code>renderer</code> is <code>null</code>, or if the <code>dataProvider</code>
   *  property was not specified, then return -1.
   */
  override public function getElementIndex(element:IVisualElement):int {
    return dataProvider == null || element == null ? -1 : indexToRenderer.indexOf(element);
  }

  override public function invalidateLayering():void {
    throw new IllegalOperationError("no support");
  }

  /**
   *  Set the itemIndex of the IItemRenderer at index to index. See resetRenderersIndices.
   */
  private function resetRendererItemIndex(index:int):void {
    var renderer:IItemRenderer = indexToRenderer[index] as IItemRenderer;
    if (renderer != null) {
      renderer.itemIndex = index;
    }
  }

  /**
   *  Recomputes every renderer's index.
   *  This is useful when an item gets added that may change the renderer's
   *  index.  In turn, this index may cuase the renderer to change appearance,
   *  like when alternatingItemColors is used.
   */
  private function resetRenderersIndices():void {
    if (indexToRenderer.length == 0) {
      return;
    }

    if (layout != null && layout.useVirtualLayout) {
      for each (var index:int in virtualRendererIndices) {
        resetRendererItemIndex(index);
      }
    }
    else {
      const indexToRendererLength:int = indexToRenderer.length;
      for (index = 0; index < indexToRendererLength; index++) {
        resetRendererItemIndex(index);
      }
      // TODO (rfrishbe): could make this more optimal by only re-computing a subset of the visible
      // item renderers, but it's probably not worth it
    }
  }

  /**
   *  Adds the itemRenderer for the specified dataProvider item to this DataGroup.
   *
   *  This method is called as needed by the DataGroup implementation,
   *  it should not be called directly.
   *
   *  @param item The item that was added, the value of dataProvider[index].
   *  @param index The index where the dataProvider item was added.
   *
   *  @langversion 3.0
   *  @playerversion Flash 10
   *  @playerversion AIR 1.5
   *  @productversion Flex 4
   */
  mx_internal function itemAdded(item:Object, index:int):void {
    if (layout != null) {
      layout.elementAdded(index);

      if (layout.useVirtualLayout) {
        // Increment all of the indices in virtualRendererIndices that are >= index.

        if (virtualRendererIndices) {
          const virtualRendererIndicesLength:int = virtualRendererIndices.length;
          for (var i:int = 0; i < virtualRendererIndicesLength; i++) {
            const vrIndex:int = virtualRendererIndices[i];
            if (vrIndex >= index) {
              virtualRendererIndices[i] = vrIndex + 1;
            }
          }

          indexToRenderer.splice(index, 0, null); // shift items >= index to the right
          // virtual ItemRenderer itself will be added lazily, by updateDisplayList()
        }

        invalidateSize();
        invalidateDisplayList();
        return;
      }
    }

    var myItemRenderer:IVisualElement = createRendererForItem(item);
    indexToRenderer.splice(index, 0, myItemRenderer);
    addItemRendererToDisplayList(myItemRenderer as DisplayObject, index);
    setUpItemRenderer(myItemRenderer, index, item);
    if (hasEventListener(RendererExistenceEvent.RENDERER_ADD)) {
      dispatchEvent(new RendererExistenceEvent(RendererExistenceEvent.RENDERER_ADD, false, false, myItemRenderer, index, item));
    }

    invalidateSize();
    invalidateDisplayList();
  }

  /**
   *  Removes the itemRenderer for the specified dataProvider item from this DataGroup.
   *
   *  This method is called as needed by the DataGroup implementation,
   *  it should not be called directly.
   *
   *  @param item The item that is being removed.
   *
   *  @param index The index of the item that is being removed.
   *
   *  @langversion 3.0
   *  @playerversion Flash 10
   *  @playerversion AIR 1.5
   *  @productversion Flex 4
   */
  mx_internal function itemRemoved(item:Object, index:int):void {
    if (layout != null) {
      layout.elementRemoved(index);
    }

    // Decrement all of the indices in virtualRendererIndices that are > index
    // Remove the one (at vrItemIndex) that equals index
    if (virtualRendererIndices && (virtualRendererIndices.length > 0)) {
      var vrItemIndex:int = -1;  // location of index in virtualRendererIndices 
      const virtualRendererIndicesLength:int = virtualRendererIndices.length;
      for (var i:int = 0; i < virtualRendererIndicesLength; i++) {
        const vrIndex:int = virtualRendererIndices[i];
        if (vrIndex == index) {
          vrItemIndex = i;
        }
        else if (vrIndex > index) {
          virtualRendererIndices[i] = vrIndex - 1;
        }
      }
      if (vrItemIndex != -1) {
        virtualRendererIndices.splice(vrItemIndex, 1);
      }
    }

    // Remove the old renderer at index from indexToRenderer[], from the 
    // DataGroup, and clear its data property (if any).
    var oldRenderer:IVisualElement;
    if (index < indexToRenderer.length) {
      oldRenderer = indexToRenderer[index];
      indexToRenderer.splice(index, 1);
    }

    if (hasEventListener(RendererExistenceEvent.RENDERER_REMOVE)) {
      dispatchEvent(new RendererExistenceEvent(RendererExistenceEvent.RENDERER_REMOVE, false, false, oldRenderer, index, item));
    }

    if (oldRenderer is IDataRenderer && oldRenderer !== item) {
      IDataRenderer(oldRenderer).data = null;
    }

    var child:DisplayObject = oldRenderer as DisplayObject;
    if (child != null) {
      super.removeChild(child);
    }

    invalidateSize();
    invalidateDisplayList();
  }

  private function addItemRendererToDisplayList(child:DisplayObject, index:int = -1):void {
    const childParent:Object = child.parent;
    const overlayCount:int = _overlay ? _overlay.numDisplayObjects : 0;
    const childIndex:int = (index != -1) ? index : super.numChildren - overlayCount;

    if (childParent == this) {
      super.setChildIndex(child, childIndex - 1);
      return;
    }

    if (childParent is FlexDataGroup) {
      FlexDataGroup(childParent)._removeChild(child);
    }

    super.addChildAt(child, childIndex);
  }

  private function addDataProviderListener():void {
    if (_dataProvider) {
      _dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler, false, 0, true);
    }
  }

  private function removeDataProviderListener():void {
    if (_dataProvider) {
      _dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler);
    }
  }

  /**
   * Called when contents within the dataProvider changes.  We will catch certain events and update our children based on that.
   */
  mx_internal function dataProvider_collectionChangeHandler(event:CollectionEvent):void {
    switch (event.kind) {
      case CollectionEventKind.ADD:
      {
        // items are added
        // figure out what items were added and where
        // for virtualization also figure out if items are now in view
        adjustAfterAdd(event.items, event.location);
        break;
      }

      case CollectionEventKind.REPLACE:
      {
        // items are replaced
        adjustAfterReplace(event.items, event.location);
        break;
      }

      case CollectionEventKind.REMOVE:
      {
        // items are added
        // figure out what items were removed
        // for virtualization also figure out what items are now in view
        adjustAfterRemove(event.items, event.location);
        break;
      }

      case CollectionEventKind.MOVE:
      {
        // one item is moved
        adjustAfterMove(event.items[0], event.location, event.oldLocation);
        break;
      }

      case CollectionEventKind.REFRESH:
      case CollectionEventKind.RESET:
      {
        // reset everything
        removeDataProviderListener();
        dataProviderChanged = true;
        invalidateProperties();
        break;
      }

      case CollectionEventKind.UPDATE:
      {
        // if a renderer is currently being updated, let's 
        // just ignore any UPDATE events.
        if (renderersBeingUpdated) {
          break;
        }

        //update the renderer's data and data-dependant
        //properties. 
        for (var i:int = 0; i < event.items.length; i++) {
          var pe:PropertyChangeEvent = event.items[i];
          if (pe != null) {
            var index:int = dataProvider.getItemIndex(pe.source);
            setUpItemRenderer(indexToRenderer[index], index, pe.source);
          }
        }
        break;
      }
    }
  }

  private function adjustAfterAdd(items:Array, location:int):void {
    var length:int = items.length;
    for (var i:int = 0; i < length; i++) {
      itemAdded(items[i], location + i);
    }

    // the order might have changed, so we might need to redraw the other 
    // renderers that are order-dependent (for instance alternatingItemColor)
    resetRenderersIndices();
  }

  private function adjustAfterRemove(items:Array, location:int):void {
    var length:int = items.length;
    for (var i:int = length - 1; i >= 0; i--) {
      itemRemoved(items[i], location + i);
    }

    // the order might have changed, so we might need to redraw the other 
    // renderers that are order-dependent (for instance alternatingItemColor)
    resetRenderersIndices();
  }

  private function adjustAfterMove(item:Object, location:int, oldLocation:int):void {
    itemRemoved(item, oldLocation);
    itemAdded(item, location);
    resetRenderersIndices();
  }

  private function adjustAfterReplace(items:Array, location:int):void {
    var length:int = items.length;
    for (var i:int = length - 1; i >= 0; i--) {
      itemRemoved(items[i].oldValue, location + i);
    }

    for (i = length - 1; i >= 0; i--) {
      itemAdded(items[i].newValue, location);
    }
  }

  /**
   *  This method allows access to the base class's implementation
   *  of removeChild() (UIComponent's version), which can be useful since components
   *  can override removeChild() and thereby hide the native implementation.  For
   *  instance, we override removeChild() here to throw an RTE to discourage people
   *  from using this method.  We need this method so we can remove children
   *  that were previously attached to another DataGroup (see addItemToDisplayList).
   */
  private function _removeChild(child:DisplayObject):DisplayObject {
    return super.removeChild(child);
  }

  override public function addChild(child:DisplayObject):DisplayObject {
    throw(new Error("addChildDataGroupError"));
  }

  override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
    throw(new Error("addChildAtDataGroupError"));
  }

  override public function removeChild(child:DisplayObject):DisplayObject {
    throw(new Error("removeChildDataGroupError"));
  }

  override public function removeChildAt(index:int):DisplayObject {
    throw(new Error("removeChildAtDataGroupError"));
  }

  override public function setChildIndex(child:DisplayObject, index:int):void {
    throw(new Error("setChildIndexDataGroupError"));
  }

  override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void {
    throw(new Error("swapChildrenDataGroupError"));
  }

  override public function swapChildrenAt(index1:int, index2:int):void {
    throw(new Error("swapChildrenAtDataGroupError"));
  }
}
}