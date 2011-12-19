package cocoa.layout {
public class ListVerticalLayout extends ListLayout implements CollectionLayout {
  public function ListVerticalLayout() {
    super();

    flags |= VERTICAL;
  }

  override public function getPreferredWidth(hHint:int):int {
    return _dimension == -1 ? 0 : _dimension;
  }

  override public function getPreferredHeight(wHint:int):int {
    _preferredHeight = initialDrawItems(10000, _dimension < 1 ? 10000 : _dimension);
    return _preferredHeight;
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