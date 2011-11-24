package cocoa.layout {
import cocoa.util.Vectors;

public class ListHorizontalLayout extends ListLayout implements CollectionLayout {
  override public function measure():void {
    var itemIndex:int;
    var isInitialDrawItems:Boolean = true;
    const dimension:Number = _dimension.value;
    if (pendingRemovedIndices != null && pendingRemovedIndices.length > 0) {
      for each (itemIndex in pendingRemovedIndices.sort(Vectors.sortDecreasing)) {
        _rendererManager.removeRenderer(itemIndex, itemIndex == 0 ? _insets.left : NaN, _insets.top, NaN, dimension);
        _container.measuredWidth -= _rendererManager.lastCreatedRendererDimension;
      }

      pendingRemovedIndices.length = 0;
      isInitialDrawItems = false;
    }

    if (pendingAddedIndices != null && pendingAddedIndices.length > 0) {
      for each (itemIndex in pendingAddedIndices.sort(Vectors.sortAscending)) {
        _rendererManager.createAndLayoutRendererAt(itemIndex, NaN, _insets.top, NaN, dimension, 0, 0);
        _container.measuredWidth += _rendererManager.lastCreatedRendererDimension;
      }

      pendingAddedIndices.length = 0;
      isInitialDrawItems = false;
    }

    if (isInitialDrawItems) {
      _container.measuredWidth = initialDrawItems(100000, dimension);
    }

    _container.measuredHeight = dimension;
  }

  override public function layout(w:Number, h:Number):void {
    if (_container.measuredWidth == w) {
      return;
    }

    doLayout(w, h);
  }

  override protected function drawItems(startPosition:Number, endPosition:Number, startItemIndex:int, endItemIndex:int,
                                        effectiveDimension:Number, head:Boolean):Number {
    endPosition -= _insets.right;

    var x:Number = startPosition == 0 ? _insets.left : startPosition;
    const y:Number = _insets.top;
    _rendererManager.preLayout(head);
    var itemIndex:int = startItemIndex;
    while (x < endPosition && itemIndex < endItemIndex) {
      _rendererManager.createAndLayoutRenderer(itemIndex++, x, y, NaN, effectiveDimension);
      x += _rendererManager.lastCreatedRendererDimension + _gap;
    }
    _rendererManager.postLayout();

    return x - _gap;
  }
}
}