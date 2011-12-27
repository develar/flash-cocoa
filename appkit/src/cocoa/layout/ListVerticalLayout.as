package cocoa.layout {
import cocoa.LayoutState;

public class ListVerticalLayout extends ListLayout implements CollectionLayout {
  public function ListVerticalLayout() {
    super();

    flags |= VERTICAL;
  }

  override public function getPreferredWidth(hHint:int = -1):int {
    return (flags & EXPLICIT_DIMENSION) == 0 ? getMaximumWidth() : contentWidth;
  }

  override public function getPreferredHeight(wHint:int = -1):int {
    if ((flags & LayoutState.DISPLAY_INVALID) != 0) {
      initialDrawItems(10000, (flags & EXPLICIT_DIMENSION) == 0 ? wHint == -1 ? 10000 : wHint : contentWidth);
    }
    else {
      processPending();
    }

    return contentHeight;
  }

  override protected function drawItems(startPosition:int, endPosition:int, startItemIndex:int, endItemIndex:int, effectiveDimension:int, head:Boolean):int {
    endPosition -= _insets.bottom;

    const x:Number = _insets.left;
    var y:Number = startPosition == 0 ? _insets.top : startPosition;
    _rendererManager.preLayout(head);
    var itemIndex:int = startItemIndex;
    while (y < endPosition && itemIndex < endItemIndex) {
      _rendererManager.createAndLayoutRenderer(itemIndex++, x, y, effectiveDimension, -1);
      y += _rendererManager.lastCreatedRendererDimension + _gap;
    }
    _rendererManager.postLayout();

    return y - _gap;
  }
}
}