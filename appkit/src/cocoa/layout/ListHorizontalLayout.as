package cocoa.layout {
import cocoa.util.Vectors;

public class ListHorizontalLayout extends ListLayout implements CollectionLayout {
  override public function getPreferredWidth(hHint:int):int {
    var itemIndex:int;
    var isInitialDrawItems:Boolean = true;
    const dimension:int = _dimension;

    if (pendingRemovedIndices != null && pendingRemovedIndices.length > 0) {
      for each (itemIndex in pendingRemovedIndices.sort(Vectors.sortDecreasing)) {
        _rendererManager.removeRenderer(itemIndex, itemIndex == 0 ? _insets.left : NaN, _insets.top, NaN, dimension);
        _preferredWidth -= _rendererManager.lastCreatedRendererDimension;
      }

      pendingRemovedIndices.length = 0;
      isInitialDrawItems = false;
    }

    if (pendingAddedIndices != null && pendingAddedIndices.length > 0) {
      for each (itemIndex in pendingAddedIndices.sort(Vectors.sortAscending)) {
        _rendererManager.createAndLayoutRendererAt(itemIndex, NaN, _insets.top, NaN, dimension, 0, 0);
        _preferredWidth += _rendererManager.lastCreatedRendererDimension;
      }

      pendingAddedIndices.length = 0;
      isInitialDrawItems = false;
    }

    if (isInitialDrawItems) {
      _preferredWidth = initialDrawItems(10000, dimension);
    }

    return _preferredWidth;
  }

  override public function getPreferredHeight(wHint:int):int {
    return _dimension;
  }

  override public function layout(w:int, h:int):void {
    doLayout(w, h);
  }

  override protected function drawItems(startPosition:int, endPosition:int, startItemIndex:int, endItemIndex:int, effectiveDimension:int, head:Boolean):int {
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