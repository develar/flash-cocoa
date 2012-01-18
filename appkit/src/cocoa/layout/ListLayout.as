package cocoa.layout {
import cocoa.Insets;
import cocoa.LayoutState;
import cocoa.ListViewDataSource;
import cocoa.ListViewMutableDataSource;
import cocoa.SegmentedControl;
import cocoa.Viewport;
import cocoa.renderer.InteractiveRendererManager;
import cocoa.renderer.RendererManager;
import cocoa.util.Vectors;

[Abstract]
internal class ListLayout implements CollectionLayout {
  protected static const VERTICAL:uint = 1 << 0;
  protected static const EXPLICIT_DIMENSION:uint = 1 << 1;

  protected var flags:uint;

  private var pendingAddedIndices:Vector.<int>;
  private var pendingRemovedIndices:Vector.<int>;

  protected var contentWidth:int = -1;
  protected var contentHeight:int = -1;
  
  protected var actualDimension:int;

  private function get isVertical():Boolean {
    return (flags & VERTICAL) != 0;
  }

  public final function getMinimumWidth(hHint:int = -1):int {
    return isVertical && (flags & EXPLICIT_DIMENSION) != 0 ? contentWidth + _insets.width : _insets.width;
  }

  public final function getMinimumHeight(wHint:int = -1):int {
    return !isVertical && (flags & EXPLICIT_DIMENSION) != 0 ? contentHeight + _insets.height : _insets.height;
  }

  public function getPreferredHeight(wHint:int = -1):int {
    return contentHeight;
  }

  public final function getMaximumWidth(hHint:int = -1):int {
    return isVertical && (flags & EXPLICIT_DIMENSION) != 0 ? contentWidth + _insets.width : 32767;
  }

  public final function getMaximumHeight(wHint:int = -1):int {
    return !isVertical && (flags & EXPLICIT_DIMENSION) != 0 ? contentHeight + _insets.height : 32767;
  }

  protected var _container:SegmentedControl;
  public function set container(value:SegmentedControl):void {
    _container = value;
  }

  protected var _insets:Insets = Insets.EMPTY;
  public function set insets(value:Insets):void {
    _insets = value;
  }

  public function set dimension(value:int):void {
    if (isVertical) {
      contentWidth = value;
    }
    else {
      contentHeight = value;
    }

    flags |= EXPLICIT_DIMENSION;
  }

  protected var _rendererManager:RendererManager;
  public function set rendererManager(value:RendererManager):void {
    _rendererManager = value;
    if (_rendererManager is InteractiveRendererManager && (flags & EXPLICIT_DIMENSION) != 0) {
      InteractiveRendererManager(_rendererManager).fixedRendererDimension = isVertical ? contentWidth : contentHeight;
    }

    if (_dataSource != null) {
      _rendererManager.dataSource = _dataSource;
    }
  }

  protected var _dataSource:ListViewDataSource;
  public function set dataSource(value:ListViewDataSource):void {
    if (_dataSource == value) {
      return;
    }

    var modifiableDataSource:ListViewMutableDataSource;
    if (_dataSource != null) {
      _dataSource.reset.remove(dataSourceReset);

      modifiableDataSource = _dataSource as ListViewMutableDataSource;
      if (modifiableDataSource != null) {
        modifiableDataSource.itemAdded.remove(itemAdded);
        modifiableDataSource.itemRemoved.remove(itemRemoved);
      }
    }

    _dataSource = value;
    if (_rendererManager != null) {
      _rendererManager.dataSource = _dataSource;
    }

    if (_dataSource != null) {
      _dataSource.reset.add(dataSourceReset);
      modifiableDataSource = _dataSource as ListViewMutableDataSource;
      if (modifiableDataSource != null) {
        modifiableDataSource.itemAdded.add(itemAdded);
        modifiableDataSource.itemRemoved.add(itemRemoved);
      }

      invalidateDisplay();
    }
  }

  private function invalidateDisplay():void {
    flags |= LayoutState.DISPLAY_INVALID;

    if (!Vectors.isEmpty(pendingAddedIndices)) {
      pendingAddedIndices.length = 0;
    }
  }

  private function itemRemoved(item:Object, index:int):void {
    if ((flags & LayoutState.DISPLAY_INVALID) != 0) {
      return;
    }

    _rendererManager.removeRenderer(index, index == 0 ? _insets.left : NaN, _insets.top, isVertical ? contentWidth : -1, isVertical ? -1 : contentHeight);
    contentWidth -= _rendererManager.lastCreatedRendererDimension;

    _container.invalidateSize();
  }

  private function itemAdded(item:Object, index:int):void {
    if ((flags & LayoutState.DISPLAY_INVALID) != 0) {
      return;
    }

    if (pendingAddedIndices == null) {
      pendingAddedIndices = new Vector.<int>();
    }
    pendingAddedIndices[pendingAddedIndices.length] = index;

    _container.invalidateSize();
  }

  protected var _gap:int;
  public function set gap(value:int):void {
    _gap = value;
  }

  public function getPreferredWidth(hHint:int = -1):int {
    return 0;
  }

  public function setSelected(itemIndex:int, relatedIndex:int, value:Boolean):void {
    if (itemIndex < _rendererManager.renderedItemCount) {
      InteractiveRendererManager(_rendererManager).setSelected(itemIndex, relatedIndex, value);
    }
  }

  private function dataSourceReset():void {
    invalidateDisplay();

    _container.invalidateSize();
  }

  protected function initialDrawItems(endPosition:int, effectiveDimension:int):void {
    flags &= ~LayoutState.DISPLAY_INVALID;

    const startItemIndex:int = 0;
    const endItemIndex:int = _dataSource.itemCount;
    const newVisibleItemCount:int = endItemIndex - startItemIndex;
    if (_rendererManager.renderedItemCount > 0) {
      _rendererManager.reuse(-_rendererManager.renderedItemCount, newVisibleItemCount == 0);
    }
    if (newVisibleItemCount == 0) {
      if (isVertical) {
        if ((flags & EXPLICIT_DIMENSION) == 0) {
          contentWidth = 0;
        }
        contentHeight = 0;
      }
      else {
        contentWidth = 0;
        if ((flags & EXPLICIT_DIMENSION) == 0) {
          contentHeight = 0;
        }
      }
    }
    else {
      const contentDimension:int = drawItems(0, endPosition, startItemIndex, endItemIndex, effectiveDimension, true);
      if (isVertical) {
        contentHeight = contentDimension;
      }
      else {
        contentWidth = contentDimension;
      }
    }
  }

  // startPosition and endPosition include insets, i.e. drawItems must respect insets —
  // as example, if startPosition == 0, ListHorizontalLayout must use startX = insets.left
  protected function drawItems(startPosition:int, endPosition:int, startItemIndex:int, endItemIndex:int, effectiveDimension:int,
                               head:Boolean):int {
    throw new Error();
  }

  protected final function processPending():Boolean {
    var has:Boolean;
    if (!Vectors.isEmpty(pendingAddedIndices)) {
      for each (var itemIndex:int in pendingAddedIndices.sort(Vectors.sortAscending)) {
        if (isVertical) {
          _rendererManager.createAndLayoutRendererAt(itemIndex, NaN, _insets.top, contentWidth, -1, _insets.top, _gap);
          contentHeight += _rendererManager.lastCreatedRendererDimension;
        }
        else {
          _rendererManager.createAndLayoutRendererAt(itemIndex, NaN, _insets.top, -1, contentHeight, _insets.left, _gap);
          contentWidth += _rendererManager.lastCreatedRendererDimension;
        }
      }

      pendingAddedIndices.length = 0;
      has = true;
    }

    return has;
  }

  public function draw(w:int, h:int):void {
    if (processPending() || (flags & LayoutState.DISPLAY_INVALID) == 0) {
      if ((flags & EXPLICIT_DIMENSION) == 0) {
        const newActualDimension:int = isVertical ? w : h;
        if (actualDimension == newActualDimension) {
          if (canSkipIfDimNotChanged) {
            return;
          }
        }
        else {
          actualDimension = newActualDimension;
        }
      }
      else if (canSkipIfDimNotChanged) {
        return;
      }
    }

    if (isVertical) {
      initialDrawItems(h, actualDimension);
    }
    else {
      initialDrawItems(w, actualDimension);
    }
  }

  private function get canSkipIfDimNotChanged():Boolean {
    var viewport:Viewport = _container as Viewport;
    return viewport == null || !viewport.clipAndEnableScrolling;
  }
}
}
