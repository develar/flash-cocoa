package cocoa {
import cocoa.layout.AdvancedLayout;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;
import spark.primitives.supportClasses.GraphicElement;

public class GraphicElement extends spark.primitives.supportClasses.GraphicElement {
  override protected function canSkipMeasurement():Boolean {
    var parentLayout:LayoutBase = GroupBase(parent).layout;
    if (parentLayout is AdvancedLayout) {
      return AdvancedLayout(parentLayout).childCanSkipMeasurement(this);
    }
    else {
      return super.canSkipMeasurement();
    }
  }
}
}