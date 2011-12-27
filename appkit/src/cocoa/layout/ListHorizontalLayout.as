package cocoa.layout {
import cocoa.LayoutState;

public class ListHorizontalLayout extends ListLayout implements CollectionLayout {
  override public function getPreferredWidth(hHint:int = -1):int {
    if ((flags & LayoutState.DISPLAY_INVALID) != 0) {
      initialDrawItems(10000, contentHeight == -1 ? hHint == -1 ? 10000 : hHint : contentHeight);
    }
    else {
      processPending();
    }

    return contentWidth;
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