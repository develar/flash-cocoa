package cocoa.layout {
import mx.core.IFactory;

public final class ListLayoutFactory implements IFactory {
  private var horizontal:Boolean;
  private var gap:Number;
  private var dimension:Number;

  public function ListLayoutFactory(dimension:Number, gap:Number, horizontal:Boolean = true) {
    this.horizontal = horizontal;
    this.gap = gap;
    this.dimension = dimension;
  }

  public function newInstance():* {
    var l:ListLayout = horizontal ? new ListHorizontalLayout() : new ListVerticalLayout();
    l.dimension = new MyExplicitDimensionProvider(dimension);
    l.gap = gap;
    return l;
  }
}
}

import cocoa.layout.ExplicitDimensionProvider;

class MyExplicitDimensionProvider implements ExplicitDimensionProvider {
  private var _value:Number;

  public function MyExplicitDimensionProvider(value:Number) {
    _value = value;
  }

  public function get value():Number {
    return _value;
  }
}
