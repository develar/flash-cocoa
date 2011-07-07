package cocoa.layout {
import cocoa.AbstractView;
import cocoa.ListViewDataSource;
import cocoa.renderer.RendererManager;

public class ListHorizontalLayout implements CollectionLayout {
  private var visibleItemCount:int = -1;

  private var _container:AbstractView;
  public function set container(value:AbstractView):void {
    _container = value;
  }

  private var _rendererManager:RendererManager;
  public function set rendererManager(value:RendererManager):void {
    _rendererManager = value;
  }

  private var _dataSource:ListViewDataSource;
  public function set dataSource(value:ListViewDataSource):void {
    if (_dataSource == value) {
      return;
    }

    if (_dataSource != null) {
      _dataSource.reset.remove(dataSourceResetHandler);
    }

    _dataSource = value;

    if (_dataSource != null) {
      _dataSource.reset.add(dataSourceResetHandler);
    }
  }

  private var _gap:Number = 0;
  public function set gap(value:Number):void {
    _gap = value;
  }

  private var _height:Number;
  public function get height():Number {
    return _height;
  }

  public function set height(value:Number):void {
    _height = value;
  }

  public function init(container:AbstractView):void {
    this._container = container;
  }

  private function dataSourceResetHandler():void {
    if (visibleItemCount != -1) {
      visibleItemCount = -visibleItemCount - 1;
    }

    _container.invalidateSize();
    _container.invalidateDisplayList();
  }
  
  public function measure(target:AbstractView):void {
    target.measuredHeight = _height;
    target.measuredWidth = 0;
  }

  public function updateDisplayList(w:Number, h:Number):void {
    if (visibleItemCount > -1) {

    }
    else {
      initialDrawCells(w);
    }
  }

  private function initialDrawCells(w:Number):void {
    const startItemIndex:int = 0;
    const endItemIndex:int = _dataSource.itemCount;
    var newVisibleItemCount:int = endItemIndex - startItemIndex;

    if (visibleItemCount != -1) {
      _rendererManager.reuse(visibleItemCount + 1, newVisibleItemCount == 0);
    }

    if (newVisibleItemCount != 0) {
      visibleItemCount = newVisibleItemCount;
      drawCells(0, startItemIndex, endItemIndex, true, w);
    }
    else {
      visibleItemCount = -1;
    }
  }

  private function drawCells(startX:Number, startItemIndex:int, endRowIndex:int, head:Boolean, w:Number):void {
    endRowIndex = Math.min(endRowIndex, _dataSource.itemCount);

    var x:Number = startX;
    var y:Number = 0;
    _rendererManager.preLayout(head);
    var itemIndex:int = startItemIndex;
    while (x < w && itemIndex < _dataSource.itemCount) {
      _rendererManager.createAndLayoutRenderer(itemIndex++, x, y, w - x, _height);
      x += _rendererManager.lastCreatedRendererWidth + _gap;
    }
    _rendererManager.postLayout(true);
  }
}
}