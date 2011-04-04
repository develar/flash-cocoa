package cocoa.layout {
import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;

/**
 * воспринимает left, right и horizontal center как указание центровки – то есть кнопка с left=0 будет у левого края (но не будет наезжать на другие кнопки у этого края)
 * значение constraint имеет смысл при > 0 — добавляется gap * constraintValue
 */
public class BarLayout extends LayoutBase {
  private var _gap:Number = 0;
  public function set gap(value:Number):void {
    _gap = value;
  }

  private var _padding:Number = 0;
  public function set padding(value:Number):void {
    _padding = value;
  }

  override public function updateDisplayList(w:Number, h:Number):void {
    var layoutTarget:GroupBase = target;

    var left:Number = _padding;
    var right:Number = w - _padding;
    var x:Number;

    // toolbar должен иметь возможность получить ширину source list view и от нее начинать — в cocoa это решено путем flexible space toolbar item, у нас же пока нет времени сделать это полностью, и вот такой хак
    if (_gap == 10) {
      left += 121;
    }

    var layoutElement:ILayoutElement;
    var n:int = layoutTarget.numElements;

    var r:Object;
    for (var i:int = 0; i < n; i++) {
      layoutElement = layoutTarget.getElementAt(i);
      if (!layoutElement.includeInLayout) {
        continue;
      }

      r = layoutElement.right;
      if (r === null || r != r) {
        layoutElement.setLayoutBoundsSize(NaN, NaN);

        var leftConstraint:Number = Number(layoutElement.left);
        if (!isNaN(leftConstraint) && leftConstraint > 0) {
          left += leftConstraint * _gap;
        }

        x = left;
        left += layoutElement.getPreferredBoundsWidth() + _gap;

        layoutElement.setLayoutBoundsPosition(x, Math.round((h - layoutElement.getPreferredBoundsHeight()) / 2));
      }
    }

    for (i = n - 1; i >= 0; i--) {
      layoutElement = layoutTarget.getElementAt(i);
      if (!layoutElement.includeInLayout) {
        continue;
      }
      
      r = layoutElement.right;
      if (r !== null && r == r) {
        layoutElement.setLayoutBoundsSize(NaN, NaN);
        x = right - layoutElement.getPreferredBoundsWidth();
        right = x - _gap;

        layoutElement.setLayoutBoundsPosition(x, Math.round((h - layoutElement.getPreferredBoundsHeight()) / 2));
      }
    }
  }
}
}