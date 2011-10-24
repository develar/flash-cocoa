package cocoa.layout {
import flash.errors.IllegalOperationError;

public class ListHorizontalLayout extends ListLayout implements CollectionLayout {
  private var endX:Number;

  override public function measure():void {
    if (pendingAddedIndices != null && pendingAddedIndices.length > 0) {
      assert(pendingAddedIndices.length == 1);
      _container.measuredWidth = drawItems(endX, 10000, pendingAddedIndices[0], pendingAddedIndices[0] + 1, false);
      visibleItemCount++;
      pendingAddedIndices.length = 0;
    }
    else {
      if (visibleItemCount > 0) {
        throw new IllegalOperationError("skip, who called us?" + _container.measuredWidth);
      }

      _container.measuredWidth = initialDrawItems(100000);
    }

    _container.measuredHeight = _dimension;
  }

  override public function layout(w:Number, h:Number):void {
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

  override protected function drawItems(startPosition:Number, endPosition:Number, startItemIndex:int, endItemIndex:int, head:Boolean):Number {
    endPosition -= _insets.right;

    var x:Number = startPosition == 0 ? _insets.left : startPosition;
    const y:Number = _insets.top;
    _rendererManager.preLayout(head);
    var itemIndex:int = startItemIndex;
    while (x < endPosition && itemIndex < endItemIndex) {
      _rendererManager.createAndLayoutRenderer(itemIndex++, x, y, NaN, _dimension);
      x += _rendererManager.lastCreatedRendererDimension + _gap;
    }
    _rendererManager.postLayout();

    endX = x;
    return x - _gap;
  }
}
}