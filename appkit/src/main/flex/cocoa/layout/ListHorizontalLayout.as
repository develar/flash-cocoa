package cocoa.layout {
import cocoa.AbstractView;

public class ListHorizontalLayout extends ListLayout implements CollectionLayout {
  private var endX:Number;

  private var _height:Number;
  public function get height():Number {
    return _height;
  }

  public function set height(value:Number):void {
    _height = value;
  }

  public function measure(target:AbstractView):void {
    target.measuredWidth = 0;
    target.measuredHeight = _height;
  }

  public function updateDisplayList(w:Number, h:Number):void {
    if (visibleItemCount > -1) {

    }
    else if (_dataSource != null) {
      endX = 0;
      initialDrawCells(w == 0 ? 100000 : w);
    }
  }

  override protected function itemAdded(item:Object, index:int):void {
    drawCells(endX, index, index + 1, false, 10000);
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

  private function drawCells(startX:Number, startItemIndex:int, endItemIndex:int, head:Boolean, w:Number):void {
    endItemIndex = Math.min(endItemIndex, _dataSource.itemCount);

    var x:Number = startX;
    var y:Number = 0;
    _rendererManager.preLayout(head);
    var itemIndex:int = startItemIndex;
    while (x < w && itemIndex < endItemIndex) {
      _rendererManager.createAndLayoutRenderer(itemIndex++, x, y, NaN, _height);
      x += _rendererManager.lastCreatedRendererWidth + _gap;
    }
    _rendererManager.postLayout(true);

    endX = x;

    _container.measuredWidth = x - _gap;
  }
}
}