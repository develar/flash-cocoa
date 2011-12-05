package cocoa.layout {
import cocoa.FlexDataGroup;

import flash.errors.IllegalOperationError;
import flash.geom.Rectangle;

import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;
import spark.layouts.supportClasses.LinearLayoutVector;

public class VirtualVerticalDataGroupLayout extends LayoutBase implements VirtualLayout {
  private const llv:LinearLayoutVector = new LinearLayoutVector();

  private var _firstIndexInView:int = -1;
  public function get firstIndexInView():int {
    return _firstIndexInView;
  }

  private var _lastIndexInView:int = -1;
  public function get lastIndexInView():int {
    return _lastIndexInView;
  }

  private function setIndexInView(firstIndex:int, lastIndex:int):void {
    _firstIndexInView = firstIndex;
    _lastIndexInView = lastIndex;
  }

  override public function clearVirtualLayoutCache():void {
    llv.clear();
  }

  override public function getElementBounds(index:int):Rectangle {
    var g:GroupBase = GroupBase(target);
    if (!g || (index < 0) || (index >= g.numElements)) {
      return null;
    }

    return llv.getBounds(index);
  }

  /**
   *  Returns 1.0 if the specified index is completely in view, 0.0 if
   *  it's not, or a value between 0.0 and 1.0 that represents the percentage
   *  of the if the index that is partially in view.
   *
   *  <p>An index is "in view" if the corresponding non-null layout element is
   *  within the vertical limits of the container's <code>scrollRect</code>
   *  and included in the layout.</p>
   *
   *  <p>If the specified index is partially within the view, the
   *  returned value is the percentage of the corresponding
   *  layout element that's visible.</p>
   *
   *  @param index The index of the row.
   *
   *  @return The percentage of the specified element that's in view.
   *  Returns 0.0 if the specified index is invalid or if it corresponds to
   *  null element, or a ILayoutElement for which
   *  the <code>includeInLayout</code> property is <code>false</code>.
   */
  private function fractionOfElementInView(index:int):Number {
    var g:GroupBase = GroupBase(target);
    if (index < 0 || (index >= g.numElements)) {
      return 0.0;
    }

    // outside the visible index range
    if (_firstIndexInView == -1 || _lastIndexInView == -1 || index < _firstIndexInView || index > _lastIndexInView) {
      return 0.0;
    }

    // within the visible index range, but not first or last
    if (index > _firstIndexInView && index < _lastIndexInView) {
      return 1.0;
    }

    // get the layout element's Y and Height
    var eltY:Number = llv.start(index);
    // So, index is either the first or last row in the scrollRect and potentially partially visible.
    //   y0,y1 - scrollRect top,bottom edges
    //   iy0, iy1 - layout element top,bottom edges
    var y0:Number = g.verticalScrollPosition;
    var y1:Number = y0 + g.height;
    var iy1:Number = eltY + llv.getMajorSize(index);
    if (eltY >= iy1 || (eltY >= y0 && iy1 <= y1)) {
      return 1.0;
    }
    else {
      return (Math.min(y1, iy1) - Math.max(y0, eltY)) / (iy1 - eltY);
    }
  }

  /**
   *  Binary search for the first layout element that contains y.
   *
   *  This function considers both the element's actual bounds and
   *  the gap that follows it to be part of the element.  The search
   *  covers index i0 through i1 (inclusive).
   *
   *  This function is intended for variable height elements.
   *
   *  Returns the index of the element that contains y, or -1.
   */
  private static function findIndexAt(y:Number, gap:int, g:GroupBase, i0:int, i1:int):int {
    var index:int = (i0 + i1) / 2;
    var element:ILayoutElement = g.getElementAt(index);
    var elementY:Number = element.getLayoutBoundsY();
    var elementHeight:Number = element.getLayoutBoundsHeight();
    // TBD: deal with null element, includeInLayout false.
    if ((y >= elementY) && (y < elementY + elementHeight + gap)) {
      return index;
    }
    else {
      if (i0 == i1) {
        return -1;
      }
      else {
        if (y < elementY) {
          return findIndexAt(y, gap, g, i0, Math.max(i0, index - 1));
        }
        else {
          return findIndexAt(y, gap, g, Math.min(index + 1, i1), i1);
        }
      }
    }
  }

  /**
   *  Returns the index of the first non-null includeInLayout element,
   *  beginning with the element at index i.
   *
   *  Returns -1 if no such element can be found.
   */
  private static function findLayoutElementIndex(g:GroupBase, i:int, dir:int):int {
    var n:int = g.numElements;
    while ((i >= 0) && (i < n)) {
      var element:ILayoutElement = g.getElementAt(i);
      if (element && element.includeInLayout) {
        return i;
      }
      i += dir;
    }
    return -1;
  }

  /**
   *  Updates the first,lastIndexInView properties per the new
   *  scroll position.
   *
   *  @see setIndexInView
   */
  override protected function scrollPositionChanged():void {
    super.scrollPositionChanged();

    var g:GroupBase = target;
    if (!g) {
      return;
    }

    var n:int = g.numElements - 1;
    if (n < 0) {
      setIndexInView(-1, -1);
      return;
    }

    var scrollR:Rectangle = getScrollRect();
    if (scrollR == null) {
      setIndexInView(0, n);
      return;
    }

    // We're going to use findIndexAt to find the index of
    // the elements that overlap the top and bottom edges of the scrollRect.
    // Values that are exactly equal to scrollRect.bottom aren't actually
    // rendered, since the top,bottom interval is only half open.
    // To account for that we back away from the bottom edge by a
    // hopefully infinitesimal amount.

    var y0:Number = scrollR.top;
    var y1:Number = scrollR.bottom - .0001;
    if (y1 <= y0) {
      setIndexInView(-1, -1);
      return;
    }

    var i0:int;
    var i1:int;
    if (useVirtualLayout) {
      i0 = llv.indexOf(y0);
      i1 = llv.indexOf(y1);
    }
    else {
      i0 = findIndexAt(y0, 0, g, 0, n);
      i1 = findIndexAt(y1, 0, g, 0, n);
    }

    // Special case: no element overlaps y0, is index 0 visible?
    if (i0 == -1) {
      var index0:int = findLayoutElementIndex(g, 0, +1);
      if (index0 != -1) {
        var element0:ILayoutElement = g.getElementAt(index0);
        var element0Y:Number = element0.getLayoutBoundsY();
        var elementHeight:Number = element0.getLayoutBoundsHeight();
        if ((element0Y < y1) && ((element0Y + elementHeight) > y0)) {
          i0 = index0;
        }
      }
    }

    // Special case: no element overlaps y1, is index n visible?
    if (i1 == -1) {
      var index1:int = findLayoutElementIndex(g, n, -1);
      if (index1 != -1) {
        var element1:ILayoutElement = g.getElementAt(index1);
        var element1Y:Number = element1.getLayoutBoundsY();
        var element1Height:Number = element1.getLayoutBoundsHeight();
        if ((element1Y < y1) && ((element1Y + element1Height) > y0)) {
          i1 = index1;
        }
      }
    }

    if (useVirtualLayout) {
      g.invalidateDisplayList();
    }

    setIndexInView(i0, i1);
  }

  private static const sharedRect:Rectangle = new Rectangle();
  /**
   *  Returns the actual position/size Rectangle of the first partially
   *  visible or not-visible, non-null includeInLayout element, beginning
   *  with the element at index i, searching in direction dir (dir must
   *  be +1 or -1).   The last argument is the GroupBase scrollRect, it's
   *  guaranteed to be non-null.
   *
   *  Returns null if no such element can be found.
   */
  private function findLayoutElementBounds(g:GroupBase, i:int, dir:int, r:Rectangle):Rectangle {
    var n:int = g.numElements;

    if (fractionOfElementInView(i) >= 1) {
      // Special case: if we hit the first/last element,
      // then return the area of the padding so that we
      // can scroll all the way to the start/end.
      i += dir;
      if (i < 0) {
        return new Rectangle(0, 0, 0, 0);
      }
      if (i >= n) {

        return new Rectangle(0, llv.getBounds(n - 1, sharedRect).bottom, 0, 0);
      }
    }

    while ((i >= 0) && (i < n)) {
      llv.getBounds(i, sharedRect);
      // Special case: if the scrollRect r _only_ contains
      // elementR, then if we're searching up (dir == -1),
      // and elementR's top edge is visible, then try again
      // with i-1.   Likewise for dir == +1.

        var overlapsTop:Boolean = (dir == -1) && (sharedRect.top == r.top) && (sharedRect.bottom >= r.bottom);
        var overlapsBottom:Boolean = (dir == +1) && (sharedRect.bottom == r.bottom) && (sharedRect.top <= r.top);
        if (!(overlapsTop || overlapsBottom)) {
          return sharedRect;
        }
      i += dir;
    }
    return null;
  }

  override protected function getElementBoundsAboveScrollRect(scrollRect:Rectangle):Rectangle {
    return findLayoutElementBounds(target, firstIndexInView, -1, scrollRect);
  }

  override protected function getElementBoundsBelowScrollRect(scrollRect:Rectangle):Rectangle {
    return findLayoutElementBounds(target, lastIndexInView, 1, scrollRect);
  }

  /**
   *  Syncs the LinearLayoutVector llv with typicalLayoutElement and
   *  the target's numElements.  Calling this function accounts
   *  for the possibility that the typicalLayoutElement has changed, or
   *  something that its preferred size depends on has changed.
   */
  private function updateLLV(layoutTarget:GroupBase):void {
    if (layoutTarget) {
      llv.length = layoutTarget.numElements;
    }
    llv.gap = 0;
    llv.majorAxisOffset = 0;
  }

  override public function elementAdded(index:int):void {
    if ((index >= 0) && useVirtualLayout) {
      llv.insert(index);
    }
  }

  override public function elementRemoved(index:int):void {
    if (index >= 0) {
      llv.remove(index);
    }
  }

  /**
   *  Compute potentially approximate values for measuredWidth,Height and
   *  measuredMinWidth,Height.
   *
   *  This method does not get layout elements from the target except
   *  as a side effect of calling typicalLayoutElement.
   *
   *  If variableRowHeight="false" then all dimensions are based on
   *  typicalLayoutElement and the sizes already cached in llv.  The
   *  llv's defaultMajorSize, minorSize, and minMinorSize
   *  are based on typicalLayoutElement.
   */
  private function measureVirtual(layoutTarget:GroupBase):void {
    var eltCount:int = layoutTarget.numElements;
    if (eltCount <= 0) {
      layoutTarget.measuredWidth = layoutTarget.measuredMinWidth = 0;
      layoutTarget.measuredHeight = layoutTarget.measuredMinHeight = 0;
      return;
    }

    updateLLV(layoutTarget);
    // Special case: fewer elements than requestedRowCount, so temporarily
    // make llv.length == requestedRowCount.
    var oldLength:int = -1;
    if (eltCount > llv.length) {
      oldLength = llv.length;
      llv.length = eltCount;
    }

    // paddingTop is already taken into account as the majorAxisOffset of the llv
    // Measured size according to the cached actual size:
    var measuredHeight:Number = llv.end(eltCount - 1);

    // For the live ItemRenderers use the preferred size instead of the cached actual size:
    var dataGroupTarget:FlexDataGroup = layoutTarget as FlexDataGroup;
    if (dataGroupTarget) {
      var indices:Vector.<int> = dataGroupTarget.getItemIndicesInView();
      for each (var i:int in indices) {
        var element:ILayoutElement = dataGroupTarget.getElementAt(i);
        if (element) {
          measuredHeight -= llv.getMajorSize(i);
          measuredHeight += element.getPreferredBoundsHeight();
        }
      }
    }

    layoutTarget.measuredHeight = measuredHeight;

    if (oldLength != -1) {
      llv.length = oldLength;
    }

    layoutTarget.measuredWidth = llv.minorSize;

    layoutTarget.measuredMinWidth = layoutTarget.measuredWidth;
    layoutTarget.measuredMinHeight = layoutTarget.measuredHeight;
  }

  /**
   *  @private
   *
   *  If requestedRowCount is specified then as many layout elements
   *  or "rows" are measured, starting with element 0, otherwise all of the
   *  layout elements are measured.
   *
   *  If requestedRowCount is specified and is greater than the
   *  number of layout elements, then the typicalLayoutElement is used
   *  in place of the missing layout elements.
   *
   *  If variableRowHeight="true", then the layoutTarget's measuredHeight
   *  is the sum of preferred heights of the layout elements, plus the sum of the
   *  gaps between elements, and its measuredWidth is the max of the elements'
   *  preferred widths.
   *
   *  If variableRowHeight="false", then the layoutTarget's measuredHeight
   *  is rowHeight multiplied by the number or layout elements, plus the
   *  sum of the gaps between elements.
   *
   *  The layoutTarget's measuredMinHeight is the sum of the minHeights of
   *  layout elements that have specified a value for the percentHeight
   *  property, and the preferredHeight of the elements that have not,
   *  plus the sum of the gaps between elements.
   *
   *  The difference reflects the fact that elements which specify
   *  percentHeight are considered to be "flexible" and updateDisplayList
   *  will give flexible components at least their minHeight.
   *
   *  Layout elements that aren't flexible always get their preferred height.
   *
   *  The layoutTarget's measuredMinWidth is the max of the minWidths for
   *  elements that have specified percentWidth (that are "flexible") and the
   *  preferredWidth of the elements that have not.
   *
   *  As before the difference is due to the fact that flexible items are only
   *  guaranteed their minWidth.
   */
  override public function measure():void {
    var layoutTarget:GroupBase = target;
    if (!layoutTarget) {
      return;
    }

    measureVirtual(layoutTarget);

    // Use Math.ceil() to make sure that if the content partially occupies
    // the last pixel, we'll count it as if the whole pixel is occupied.
    layoutTarget.measuredWidth = Math.ceil(layoutTarget.measuredWidth);
    layoutTarget.measuredHeight = Math.ceil(layoutTarget.measuredHeight);
  }

  /**
   *  Update the layout of the virtualized elements that overlap
   *  the scrollRect's vertical extent.
   *
   *  The height of each layout element will be its preferred height, and its
   *  y will be the bottom of the previous item, plus the gap.
   *
   *  No support for percentHeight, includeInLayout=false, or null layoutElements,
   *
   *  The width of each layout element will be set to its preferred width, unless
   *  one of the following is true:
   *
   *  - If percentWidth is specified for this element, then its width will be the
   *  specified percentage of the target's actual (unscaled) width, clipped
   *  the layout element's minimum and maximum width.
   *
   *  - If horizontalAlign is "justify", then the element's width will
   *  be set to the target's actual (unscaled) width.
   *
   *  - If horizontalAlign is "contentJustify", then the element's width
   *  will be set to the larger of the target's width and its content width.
   *
   *  The X coordinate of each layout element will be set to 0 unless one of the
   *  following is true:
   *
   *  - If horizontalAlign is "center" then x is set so that the element's preferred
   *  width is centered within the larger of the contentWidth, target width:
   *      x = (Math.max(contentWidth, target.width) - layoutElementWidth) * 0.5
   *
   *  - If horizontalAlign is "right" the x is set so that the element's right
   *  edge is aligned with the the right edge of the content:
   *      x = (Math.max(contentWidth, target.width) - layoutElementWidth)
   *
   *  Implementation note: unless horizontalAlign is either "justify" or
   *  "left", the layout elements' x or width depends on the contentWidth.
   *  The contentWidth is a maximum and although it may be updated to
   *  different value after all (viewable) elements have been laid out, it
   *  often does not change.  For that reason we use the current contentWidth
   *  for the initial layout and then, if it has changed, we loop through
   *  the layout items again and fix up the x/width values.
   */
  private function updateDisplayListVirtual():void {
    var layoutTarget:GroupBase = target;
    var targetWidth:Number = layoutTarget.width;
    var minVisibleY:Number = layoutTarget.verticalScrollPosition;
    var maxVisibleY:Number = minVisibleY + layoutTarget.height;

    updateLLV(layoutTarget);

    // Find the index of the first visible item. Since the item's bounds includes the gap
    // that follows it, we want to avoid looking at an item that has only a portion of
    // its gap intersecting with the visible region.
    // We have to also be careful, as gap could be negative and in that case, we should
    // simply start from minVisibleY - SDK-22497.
    var startIndex:int = llv.indexOf(Math.max(0, minVisibleY));
    if (startIndex == -1) {
      return;
    }

    var y:Number = llv.start(startIndex);
    var index:int = startIndex;
    for (var n:int = layoutTarget.numElements; (y < maxVisibleY) && (index < n); index++) {
      var elt:ILayoutElement = layoutTarget.getVirtualElementAt(index, targetWidth, NaN);
      elt.setLayoutBoundsSize(targetWidth, NaN);
      elt.setLayoutBoundsPosition(0, y);
      llv.cacheDimensions(index, elt);
      y += elt.getLayoutBoundsHeight();
    }

    setIndexInView(startIndex, index - 1);
    layoutTarget.setContentSize(targetWidth, Math.ceil(llv.end(llv.length - 1)));
  }

  override public function updateDisplayList(w:Number, h:Number):void {
    var layoutTarget:GroupBase = target;
    if (!layoutTarget) {
      return;
    }

    if ((layoutTarget.numElements == 0) || (w == 0) || (h == 0)) {
      setIndexInView(-1, -1);
      if (layoutTarget.numElements == 0) {
        layoutTarget.setContentSize(0, 0);
      }
      return;
    }

    updateDisplayListVirtual();
  }

  override public function get useVirtualLayout():Boolean {
    return true;
  }

  override public function set useVirtualLayout(value:Boolean):void {
    throw new IllegalOperationError();
  }
}
}
