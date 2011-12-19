package cocoa.layout {
import cocoa.LayoutState;
import cocoa.LayoutState;

public class ListHorizontalLayout extends ListLayout implements CollectionLayout {
  override public function getPreferredWidth(hHint:int):int {
    if ((flags & LayoutState.DISPLAY_INVALID) != 0) {
      _preferredWidth = initialDrawItems(10000, _dimension == -1 ? hHint == -1 ? 10000 : hHint : _dimension);
    }

    return _preferredWidth;
  }

  override public function getPreferredHeight(wHint:int):int {
    return _dimension;
  }

  override protected function drawItems(startPosition:int, endPosition:int, startItemIndex:int, endItemIndex:int, effectiveDimension:int, head:Boolean):int {
    endPosition -= _insets.right;

    var x:Number = startPosition == 0 ? _insets.left : startPosition;
    const y:Number = _insets.top;
    _rendererManager.preLayout(head);
    var itemIndex:int = startItemIndex;
    while (x < endPosition && itemIndex < endItemIndex) {
      _rendererManager.createAndLayoutRenderer(itemIndex++, x, y, -1, effectiveDimension);
      x += _rendererManager.lastCreatedRendererDimension + _gap;
    }
    _rendererManager.postLayout();

    return x - _gap;
  }
}
}