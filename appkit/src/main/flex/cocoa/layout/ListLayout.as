package cocoa.layout {
import cocoa.AbstractView;
import cocoa.ListViewDataSource;
import cocoa.ListViewModifiableDataSource;
import cocoa.renderer.InteractiveRendererManager;
import cocoa.renderer.RendererManager;

import flash.errors.IllegalOperationError;

[Abstract]
internal class ListLayout implements CollectionLayout {
  protected var visibleItemCount:int = -1;
  protected var pendingAddedIndices:Vector.<int>;

  protected var _container:AbstractView;
  public function set container(value:AbstractView):void {
    _container = value;
  }

  protected var _dimension:Number;
  public function get dimension():Number {
    return _dimension;
  }
  public function set dimension(value:Number):void {
    _dimension = value;
  }

  protected var _rendererManager:RendererManager;
  public function set rendererManager(value:RendererManager):void {
    _rendererManager = value;
    if (_rendererManager is InteractiveRendererManager) {
      InteractiveRendererManager(_rendererManager).fixedRendererDimension = _dimension;
    }
  }

  protected var _dataSource:ListViewDataSource;
  public function set dataSource(value:ListViewDataSource):void {
    if (_dataSource == value) {
      return;
    }

    var modifiableDataSource:ListViewModifiableDataSource;
    if (_dataSource != null) {
      _dataSource.reset.remove(dataSourceReset);

      modifiableDataSource = _dataSource as ListViewModifiableDataSource;
      if (modifiableDataSource != null) {
        modifiableDataSource.itemAdded.remove(itemAdded);
        modifiableDataSource.itemRemoved.remove(itemRemoved);
      }
    }

    _dataSource = value;

    if (_dataSource != null) {
      _dataSource.reset.add(dataSourceReset);
      modifiableDataSource = _dataSource as ListViewModifiableDataSource;
      if (modifiableDataSource != null) {
        modifiableDataSource.itemAdded.add(itemAdded);
        // currently, just reset
        modifiableDataSource.itemRemoved.add(itemRemoved);
      }
    }
  }

  protected function itemRemoved(item:Object, index:int):void {
    dataSourceReset();
  }

  protected function itemAdded(item:Object, index:int):void {
    // not yet drawn
    if (visibleItemCount > -1) {
      if (pendingAddedIndices == null) {
        pendingAddedIndices = new Vector.<int>();
      }

      pendingAddedIndices.push(index);
    }

    _container.invalidateSize();
  }

  protected var _gap:Number = 0;
  public function set gap(value:Number):void {
    _gap = value;
  }

  public function setSelected(itemIndex:int, relatedIndex:int, value:Boolean):void {
    if (visibleItemCount > 0 && itemIndex < visibleItemCount) {
      InteractiveRendererManager(_rendererManager).setSelected(itemIndex, relatedIndex, value);
    }
  }

  private function dataSourceReset():void {
    if (visibleItemCount > -1) {
      visibleItemCount = -visibleItemCount - 1;
    }

    if (pendingAddedIndices != null) {
      pendingAddedIndices.length = 0;
    }

    _container.invalidateSize();
  }

  protected function initialDrawItems(dimension:Number):Number {
    const startItemIndex:int = 0;
    const endItemIndex:int = _dataSource.itemCount;
    const newVisibleItemCount:int = endItemIndex - startItemIndex;

    if (visibleItemCount != -1) {
      _rendererManager.reuse(visibleItemCount + 1, newVisibleItemCount == 0);
    }

    if (newVisibleItemCount != 0) {
      visibleItemCount = newVisibleItemCount;
      return drawItems(0, startItemIndex, endItemIndex, true, dimension);
    }
    else {
      visibleItemCount = -1;
      return 0;
    }
  }

  protected function drawItems(startPosition:Number, startItemIndex:int, endItemIndex:int, head:Boolean, dimension:Number):Number {
    throw new Error();
  }

  public function measure():void {
    throw new IllegalOperationError("Burn in hell, Adobe");
  }

  public function updateDisplayList(w:Number, h:Number):void {
    throw new IllegalOperationError("Burn in hell, Adobe");
  }
}
}
