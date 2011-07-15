package cocoa.layout {
public class ListVerticalLayout extends ListLayout implements CollectionLayout {
  private var _width:Number;
  public function get width():Number {
    return _width;
  }

  public function set width(value:Number):void {
    _width = value;
  }

  public function measure():void {
    _container.measuredWidth = _width;
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
      _rendererManager.createAndLayoutRenderer(itemIndex++, x, y, _width, NaN);
      y += _rendererManager.lastCreatedRendererHeigth + _gap;
    }
    _rendererManager.postLayout();

    return y - _gap;
  }
}
}