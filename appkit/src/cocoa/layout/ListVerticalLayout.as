package cocoa.layout {
public class ListVerticalLayout extends ListLayout implements CollectionLayout {
  override public function measure():void {
    _container.measuredWidth = _dimension.value;
    _container.measuredHeight = initialDrawItems(10000, _dimension.value);
  }

  override public function layout(w:Number, h:Number):void {
    if (_container.measuredHeight == h && _container.measuredWidth == w) {
      return;
    }

    doLayout(h, w);
  }

  override protected function drawItems(startPosition:Number, endPosition:Number, startItemIndex:int, endItemIndex:int,
                                        effectiveDimension:Number, head:Boolean):Number {
    endPosition -= _insets.bottom;

    const x:Number = _insets.left;
    var y:Number = startPosition == 0 ? _insets.top : startPosition;
    _rendererManager.preLayout(head);
    var itemIndex:int = startItemIndex;
    while (y < endPosition && itemIndex < endItemIndex) {
      _rendererManager.createAndLayoutRenderer(itemIndex++, x, y, effectiveDimension, NaN);
      y += _rendererManager.lastCreatedRendererDimension + _gap;
    }
    _rendererManager.postLayout();

    return y - _gap;
  }
}
}