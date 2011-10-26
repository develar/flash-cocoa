package cocoa.layout {
import cocoa.AbstractView;
import cocoa.Insets;
import cocoa.ListViewDataSource;
import cocoa.ListViewModifiableDataSource;
import cocoa.renderer.InteractiveRendererManager;
import cocoa.renderer.RendererManager;

import flash.errors.IllegalOperationError;

[Abstract]
internal class ListLayout implements CollectionLayout {
  protected var pendingAddedIndices:Vector.<int>;
  protected var pendingRemovedIndices:Vector.<int>;

  protected var _container:AbstractView;
  public function set container(value:AbstractView):void {
    _container = value;
  }

  protected var _insets:Insets = Insets.EMPTY;
  public function set insets(value:Insets):void {
    _insets = value;
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

    if (_dataSource != null) {
      _rendererManager.dataSource = _dataSource;
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
    if (_rendererManager != null) {
      _rendererManager.dataSource = _dataSource;
    }

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
    if (_rendererManager.renderedItemCount > 0) {
      if (pendingRemovedIndices == null) {
        pendingRemovedIndices = new Vector.<int>();
      }

      pendingRemovedIndices.push(index);
    }

    _container.invalidateSize();
  }

  protected function itemAdded(item:Object, index:int):void {
    if (_rendererManager.renderedItemCount > 0) {
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
    if (itemIndex < _rendererManager.renderedItemCount) {
      InteractiveRendererManager(_rendererManager).setSelected(itemIndex, relatedIndex, value);
    }
  }

  private function dataSourceReset():void {
    if (pendingAddedIndices != null) {
      pendingAddedIndices.length = 0;
    }

    _container.invalidateSize();
  }

  protected function doLayout(endPosition:Number):void {
    if (_rendererManager.renderedItemCount > 0) {

    }
    else if (_dataSource != null) {
      initialDrawItems(endPosition);
    }
  }

  protected function initialDrawItems(endPosition:Number):Number {
    const startItemIndex:int = 0;
    const endItemIndex:int = _dataSource.itemCount;
    const newVisibleItemCount:int = endItemIndex - startItemIndex;
    if (_rendererManager.renderedItemCount > 0) {
      _rendererManager.reuse(-_rendererManager.renderedItemCount, newVisibleItemCount == 0);
    }
    return newVisibleItemCount == 0 ? 0 : drawItems(0, endPosition, startItemIndex, endItemIndex, true);
  }

  // startPosition and endPosition include insets, i.e. drawItems must respect insets —
  // as example, if startPosition == 0, ListHorizontalLayout must use startX = insets.left
  protected function drawItems(startPosition:Number, endPosition:Number, startItemIndex:int, endItemIndex:int, head:Boolean):Number {
    throw new Error();
  }

  public function measure():void {
    throw new IllegalOperationError("Burn in hell, Adobe");
  }

  public function layout(w:Number, h:Number):void {
    throw new IllegalOperationError("Burn in hell, Adobe");
  }
}
}
