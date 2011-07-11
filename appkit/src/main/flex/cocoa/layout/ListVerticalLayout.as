package cocoa.layout {
import cocoa.AbstractView;

public class ListVerticalLayout extends ListLayout implements CollectionLayout {
  private var _width:Number;
  public function get width():Number {
    return _width;
  }

  public function set width(value:Number):void {
    _width = value;
  }

  public function measure(target:AbstractView):void {
    target.measuredWidth = _width;
    target.measuredHeight = 0;
  }

  public function updateDisplayList(w:Number, h:Number):void {
    if (visibleItemCount > -1) {

    }
    else {
      initialDrawCells(h);
    }
  }

  private function initialDrawCells(h:Number):void {
    const startItemIndex:int = 0;
    const endItemIndex:int = _dataSource.itemCount;
    var newVisibleItemCount:int = endItemIndex - startItemIndex;

    if (visibleItemCount != -1) {
      _rendererManager.reuse(visibleItemCount + 1, newVisibleItemCount == 0);
    }

    if (newVisibleItemCount != 0) {
      visibleItemCount = newVisibleItemCount;
      drawCells(0, startItemIndex, endItemIndex, true, h);
    }
    else {
      visibleItemCount = -1;
    }
  }

  private function drawCells(startY:Number, startItemIndex:int, endRowIndex:int, head:Boolean, h:Number):void {
    endRowIndex = Math.min(endRowIndex, _dataSource.itemCount);

    var x:Number = 0;
    var y:Number = startY;
    _rendererManager.preLayout(head);
    var itemIndex:int = startItemIndex;
    while (x < h && itemIndex < _dataSource.itemCount) {
      _rendererManager.createAndLayoutRenderer(itemIndex++, x, y, _width, NaN);
      y += _rendererManager.lastCreatedRendererHeigth + _gap;
    }
    _rendererManager.postLayout(true);
  }
}
}