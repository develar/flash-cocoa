package cocoa.layout {
public class ListHorizontalLayout extends ListLayout implements CollectionLayout {
  private var endX:Number;

  private var _height:Number;
  public function get height():Number {
    return _height;
  }

  public function set height(value:Number):void {
    _height = value;
  }

  public function measure():void {
    _container.measuredWidth = initialDrawItems(100000);
    _container.measuredHeight = _height;
  }

  public function updateDisplayList(w:Number, h:Number):void {
    if (_container.measuredWidth == w) {
      return;
    }
    
    if (visibleItemCount > -1) {

    }
    else if (_dataSource != null) {
      endX = 0;
      initialDrawItems(w);
    }
  }

  override protected function itemAdded(item:Object, index:int):void {
    drawItems(endX, index, index + 1, false, 10000);
    visibleItemCount++;
  }

  override protected function drawItems(startX:Number, startItemIndex:int, endItemIndex:int, head:Boolean, w:Number):Number {
    var x:Number = startX;
    var y:Number = 0;
    _rendererManager.preLayout(head);
    var itemIndex:int = startItemIndex;
    while (itemIndex < endItemIndex) {
      _rendererManager.createAndLayoutRenderer(itemIndex++, x, y, NaN, _height);
      x += _rendererManager.lastCreatedRendererWidth + _gap;
    }
    _rendererManager.postLayout();

    endX = x;
    return x - _gap;
  }
}
}