package cocoa.layout {
public class ListVerticalLayout extends ListLayout implements CollectionLayout {
  public function measure():void {
    _container.measuredWidth = _dimension;
    _container.measuredHeight = 0;
  }

  public function updateDisplayList(w:Number, h:Number):void {
    if (visibleItemCount > -1) {

    }
    else {
      initialDrawItems(h);
    }
  }

  override protected function drawItems(startY:Number, startItemIndex:int, endRowIndex:int, head:Boolean, h:Number):Number {
    endRowIndex = Math.min(endRowIndex, _dataSource.itemCount);

    var x:Number = 0;
    var y:Number = startY;
    _rendererManager.preLayout(head);
    var itemIndex:int = startItemIndex;
    while (x < h && itemIndex < _dataSource.itemCount) {
      _rendererManager.createAndLayoutRenderer(itemIndex++, x, y, _dimension, NaN);
      y += _rendererManager.lastCreatedRendererDimension + _gap;
    }
    _rendererManager.postLayout();

    return y - _gap;
  }
}
}