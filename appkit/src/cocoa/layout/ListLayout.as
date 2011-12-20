package cocoa.layout {
import cocoa.Insets;
import cocoa.LayoutState;
import cocoa.ListViewDataSource;
import cocoa.ListViewMutableDataSource;
import cocoa.SegmentedControl;
import cocoa.renderer.InteractiveRendererManager;
import cocoa.renderer.RendererManager;
import cocoa.util.Vectors;

[Abstract]
internal class ListLayout implements CollectionLayout {
  protected static const VERTICAL:uint = 1 << 0;
  
  protected var flags:uint;

  private var pendingAddedIndices:Vector.<int>;
  private var pendingRemovedIndices:Vector.<int>;

  protected var preferredWidth:int;
  protected var preferredHeight:int;

  private function get isVertical():Boolean {
    return (flags & VERTICAL) != 0;
  }

  public final function getMinimumWidth(hHint:int):int {
    return isVertical && _dimension != -1 ? _dimension + _insets.width : _insets.width;
  }

  public final function getMinimumHeight(wHint:int):int {
    return !isVertical && _dimension != -1 ? _dimension + _insets.height : _insets.height;
  }

  public final function getMaximumWidth(hHint:int):int {
    return isVertical && _dimension != -1 ? _dimension + _insets.width : 32767;
  }

  public final function getMaximumHeight(wHint:int):int {
    return !isVertical && _dimension != -1 ? _dimension + _insets.height : 32767;
  }

  protected var _container:SegmentedControl;
  public function set container(value:SegmentedControl):void {
    _container = value;
  }

  protected var _insets:Insets = Insets.EMPTY;
  public function set insets(value:Insets):void {
    _insets = value;
  }

  protected var _dimension:int = -1;
  public function set dimension(value:int):void {
    _dimension = value;
  }

  protected var _rendererManager:RendererManager;
  public function set rendererManager(value:RendererManager):void {
    _rendererManager = value;
    if (_rendererManager is InteractiveRendererManager) {
      InteractiveRendererManager(_rendererManager).fixedRendererDimension = _dimension;
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

    _rendererManager.removeRenderer(index, index == 0 ? _insets.left : NaN, _insets.top, isVertical ? _dimension : -1, isVertical ? -1 : _dimension);
    preferredWidth -= _rendererManager.lastCreatedRendererDimension;

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

  public function getPreferredWidth(hHint:int):int {
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

  protected function initialDrawItems(endPosition:int, effectiveDimension:int):int {
    flags &= ~LayoutState.DISPLAY_INVALID;

    const startItemIndex:int = 0;
    const endItemIndex:int = _dataSource.itemCount;
    const newVisibleItemCount:int = endItemIndex - startItemIndex;
    if (_rendererManager.renderedItemCount > 0) {
      _rendererManager.reuse(-_rendererManager.renderedItemCount, newVisibleItemCount == 0);
    }
    return newVisibleItemCount == 0 ? 0 : drawItems(0, endPosition, startItemIndex, endItemIndex, effectiveDimension, true);
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
          _rendererManager.createAndLayoutRendererAt(itemIndex, NaN, _insets.top, _dimension, -1, _insets.top, _gap);
          preferredHeight += _rendererManager.lastCreatedRendererDimension;
        }
        else {
          _rendererManager.createAndLayoutRendererAt(itemIndex, NaN, _insets.top, -1, _dimension, _insets.left, _gap);
          preferredWidth += _rendererManager.lastCreatedRendererDimension;
        }
      }

      pendingAddedIndices.length = 0;
      has = true;
    }

    return has;
  }

  public function draw(w:int, h:int):void {
    if (processPending() || (flags & LayoutState.DISPLAY_INVALID) == 0) {
      return;
    }

    if (isVertical) {
      preferredHeight = initialDrawItems(h, w);
    }
    else {
      preferredWidth = initialDrawItems(w, h);
    }
  }

  public function getPreferredHeight(wHint:int):int {
    return 0;
  }
}
}
