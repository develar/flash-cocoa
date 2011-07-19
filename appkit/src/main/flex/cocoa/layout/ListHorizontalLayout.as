package cocoa.layout {
public class ListHorizontalLayout extends ListLayout implements CollectionLayout {
  private var endX:Number;

  override public function measure():void {
    if (pendingAddedIndices != null && pendingAddedIndices.length > 0) {
      assert(pendingAddedIndices.length == 1);
      _container.measuredWidth = drawItems(endX, pendingAddedIndices[0], pendingAddedIndices[0] + 1, false, 10000);
      visibleItemCount++;
      pendingAddedIndices.length = 0;
    }
    else {
      if (visibleItemCount > 0) {
        trace("skip, who called us?" + _container.measuredWidth);
        return;
      }
      _container.measuredWidth = initialDrawItems(100000);
    }

    _container.measuredHeight = _dimension;
  }

  override public function updateDisplayList(w:Number, h:Number):void {
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

  override protected function drawItems(startX:Number, startItemIndex:int, endItemIndex:int, head:Boolean, w:Number):Number {
    var x:Number = startX;
    var y:Number = 0;
    _rendererManager.preLayout(head);
    var itemIndex:int = startItemIndex;
    while (itemIndex < endItemIndex) {
      _rendererManager.createAndLayoutRenderer(itemIndex++, x, y, NaN, _dimension);
      x += _rendererManager.lastCreatedRendererDimension + _gap;
    }
    _rendererManager.postLayout();

    endX = x;
    return x - _gap;
  }
}
}