package cocoa.plaf.basic {
import cocoa.AbstractView;
import cocoa.CollectionView;
import cocoa.layout.Layout;
import cocoa.tableView.RendererManager;

public class CollectionHorizontalLayout implements Layout {
  private var collectionView:CollectionView;
  private var visibleItemCount:int = -1;

  private var target:AbstractView;

  private var _rendererManager:RendererManager;
  public function set rendererManager(value:RendererManager):void {
    _rendererManager = value;
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

  public function init(collectionView:CollectionView, container:AbstractView):void {
    this.collectionView = collectionView;
    _rendererManager.container = container;
    _rendererManager.dataSource = collectionView.dataSource;
    collectionView.dataSource.reset.add(dataSourceResetHandler);
    target = container;
  }

  private function dataSourceResetHandler():void {
    if (visibleItemCount != -1) {
      visibleItemCount = -visibleItemCount - 1;
    }

    target.invalidateSize();
    target.invalidateDisplayList();
  }
  
  public function measure(target:AbstractView):void {
    target.measuredHeight = _height;
    target.measuredWidth = 0;
  }

  public function updateDisplayList(target:AbstractView, w:Number, h:Number):void {
    if (visibleItemCount > -1) {

    }
    else {
      initialDrawCells(w, collectionView);
    }
  }

  private function initialDrawCells(w:Number, collectionView:CollectionView):void {
    const startItemIndex:int = 0;
    const endItemIndex:int = collectionView.dataSource.itemCount;
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
    endRowIndex = Math.min(endRowIndex, collectionView.dataSource.itemCount);

    var x:Number = startX;
    var y:Number = 0;
    _rendererManager.preLayout(head);
    var itemIndex:int = startItemIndex;
    while (x < w && itemIndex < collectionView.dataSource.itemCount) {
      _rendererManager.createAndLayoutRenderer(itemIndex++, x, y, w - x, _height);
      x += _rendererManager.lastCreatedRendererWidth + _gap;
    }
    _rendererManager.postLayout(true);
  }
}
}