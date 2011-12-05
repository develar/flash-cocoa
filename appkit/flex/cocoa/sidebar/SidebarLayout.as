package cocoa.sidebar {
import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;

/**
 * SidebarLayout don't measure — sidebar size explicitly determined by skin
 */
public class SidebarLayout extends LayoutBase {
  private var _gap:Number = 0;
  public function set gap(value:Number):void {
    _gap = value;
  }

  override public function updateDisplayList(width:Number, height:Number):void {
    var layoutTarget:GroupBase = target;
    var numElements:int = layoutTarget.numElements;
    if (numElements == 0) {
      return;
    }

    var i:int;
    var numActiveElements:int = numElements;
    for (i = 0; i < numElements; i++) {
      if (!layoutTarget.getElementAt(i).includeInLayout) {
        numActiveElements--;
      }
    }

    const totalElementH:Number = height - (_gap * (numActiveElements - 1));
    const elementHeight:Number = Math.round(totalElementH / numActiveElements);
    var firstElementHeight:Number = elementHeight + (totalElementH - (elementHeight * numActiveElements));
    var efffectiveElementHeight:Number;
    var y:Number = 0;
    for (i = 0; i < numElements; i++) {
      var layoutElement:ILayoutElement = layoutTarget.getElementAt(i);
      if (!layoutElement.includeInLayout) {
        continue;
      }

      layoutElement.setLayoutBoundsPosition(0, y);
      if (firstElementHeight == firstElementHeight) {
        efffectiveElementHeight = firstElementHeight;
        firstElementHeight = NaN;
      }
      else {
        efffectiveElementHeight = elementHeight;
      }

      layoutElement.setLayoutBoundsSize(width, efffectiveElementHeight);
      y += efffectiveElementHeight + _gap;
    }
  }

  public function childCanSkipMeasurement(element:ILayoutElement):Boolean {
    return true;
  }
}
}