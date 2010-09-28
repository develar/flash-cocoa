package cocoa {
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelUtil;

import flash.display.DisplayObject;
import flash.geom.Point;

import mx.core.IUIComponent;
import mx.events.PropertyChangeEvent;
import mx.managers.IFocusManagerComponent;
import mx.utils.MatrixUtil;

import spark.components.supportClasses.GroupBase;
import spark.components.supportClasses.ScrollBarBase;
import spark.core.IViewport;

/**
 * http://developer.apple.com/mac/library/documentation/cocoa/reference/ApplicationKit/Classes/NSScrollView_Class/Reference/Reference.html
 * http://developer.apple.com/mac/library/documentation/cocoa/Conceptual/NSScrollViewGuide/Articles/Basics.html
 *
 * Терминология частей полосы прокрутки как во Flex/Swing, а не как в Cocoa
 *
 * При скиновании может потребоваться чтобы thumb гулял не на всем track — как в Cocoa для вертикальной полосы прокрутки отступ сверху 7px —
 * для этого установите у track border соответствующий contentInsets.
 */
[DefaultProperty("documentView")]
public class ScrollView extends AbstractView implements IFocusManagerComponent {
  private var _horizontalScrollBar:HScrollBar;
  private var _verticalScrollBar:VScrollBar;

  public function get horizontalScrollBar():HScrollBar {
    return _horizontalScrollBar;
  }

  /**
   * SDT - ScrollBar Display Threshold.  If the content size exceeds the viewport's size by SDT, then we show a scrollbar.
   * For example, if the contentWidth >= viewport width + SDT, show the horizontal scrollbar.
   */
  private static const SDT:Number = 1.0;

  public function ScrollView() {
    super();
    hasFocusableChildren = true;
    focusEnabled = false;
  }

  private var documentViewChanged:Boolean;
  private var _documentView:IViewport;
  public function set documentView(value:IViewport):void {
    if (value != _documentView) {
      documentViewChanged = true;
      _documentView = value;
      invalidateProperties();
    }
  }

  private var _verticalScrollPolicy:int = ScrollPolicy.AUTO;
  public function set verticalScrollPolicy(value:uint):void {
    _verticalScrollPolicy = value;

    if (_verticalScrollBar != null) {
      _verticalScrollBar.visible = _verticalScrollPolicy != ScrollPolicy.OFF;
    }
  }

  private var _horizontalScrollPolicy:int = ScrollPolicy.AUTO;
  public function set horizontalScrollPolicy(value:uint):void {
    _horizontalScrollPolicy = value;

    if (_horizontalScrollBar != null) {
      _horizontalScrollBar.visible = _horizontalScrollPolicy != ScrollPolicy.OFF;
    }
  }

  public function drawFocus(isFocused:Boolean):void {
  }

  override protected function createChildren():void {
    var laf:LookAndFeel = LookAndFeelUtil.find(parent);

    if (_verticalScrollPolicy != ScrollPolicy.OFF) {
      _verticalScrollBar = new VScrollBar();
      _verticalScrollBar.attach(laf);
      addChild(_verticalScrollBar);
    }

    if (_horizontalScrollPolicy != ScrollPolicy.OFF) {
      _horizontalScrollBar = new HScrollBar();
      _horizontalScrollBar.attach(laf);
      addChild(_horizontalScrollBar);
    }
  }

  override protected function commitProperties():void {
    super.commitProperties();

    if (documentViewChanged) {
      documentViewChanged = false;

      var oldDocumentView:IViewport = numChildren == 0 ? null : (getChildAt(0) as IViewport);
      if (oldDocumentView != null) {
        removeChildAt(0);
        oldDocumentView.clipAndEnableScrolling = false;
        oldDocumentView.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, documentViewPropertyChangeHandler);
      }

      if (_documentView != null) {
        _documentView.clipAndEnableScrolling = true;
        addChildAt(DisplayObject(_documentView), 0);
        _documentView.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, documentViewPropertyChangeHandler);
      }

      if (_verticalScrollBar != null) {
        _verticalScrollBar.viewport = _documentView;
      }
      if (_horizontalScrollBar != null) {
        _horizontalScrollBar.viewport = _documentView;
      }
    }
  }

  private function documentViewPropertyChangeHandler(event:PropertyChangeEvent):void {
    switch (event.property) {
      case "contentWidth":
      case "contentHeight":
        invalidateSize();
        invalidateDisplayList();
        break;
    }
  }

  private function get hsbVisible():Boolean {
    return _horizontalScrollBar != null && _horizontalScrollBar.visible;
  }

  private function hsbRequiredHeight():Number {
    return Math.max(minViewportInset, _horizontalScrollBar.getPreferredBoundsHeight());
  }

  private function get vsbVisible():Boolean {
    return _verticalScrollBar != null && _verticalScrollBar.visible;
  }

  private function vsbRequiredWidth():Number {
    return Math.max(minViewportInset, _verticalScrollBar.getPreferredBoundsWidth());
  }

  private var minViewportInset:Number = 0;

  private static const sharedPoint:Point = new Point(0, 0);
  private function getLayoutContentSize():Point {
    var cw:Number = _documentView.contentWidth;
    var ch:Number = _documentView.contentHeight;
    if ((cw == 0 && ch == 0) || (isNaN(cw) || isNaN(ch))) {
      return sharedPoint;
    }
    else {
      return MatrixUtil.transformSize(cw, ch, _documentView.getLayoutMatrix());
    }
  }

  override protected function measure():void {
    var hsb:ScrollBarBase = _horizontalScrollBar;
    var showHSB:Boolean = false;
    var hAuto:Boolean = false;
    switch (_horizontalScrollPolicy) {
      case ScrollPolicy.ON:
        if (hsb != null) {
          showHSB = true;
        }
        break;

      case ScrollPolicy.AUTO:
        if (hsb != null) {
          showHSB = hsb.visible;
        }
        hAuto = true;
        break;
    }

    var vsb:ScrollBarBase = _verticalScrollBar;
    var showVSB:Boolean = false;
    var vAuto:Boolean = false;
    switch (_verticalScrollPolicy) {
      case ScrollPolicy.ON:
        if (vsb != null) {
          showVSB = true;
        }
        break;

      case ScrollPolicy.AUTO:
        if (vsb != null) {
          showVSB = vsb.visible;
        }
        vAuto = true;
        break;
    }

    var measuredW:Number = showHSB ? hsbRequiredHeight() : minViewportInset;
    var measuredH:Number = showVSB ? vsbRequiredWidth() : minViewportInset;

    // The measured size of the viewport is just its preferredBounds, except:
    // don't give up space if doing so would make an auto scrollbar visible.
    // In other words, if an auto scrollbar isn't already showing, and using
    // the preferred size would force it to show, and the current size would not,
    // then use its current size as the measured size. Note that a scrollbar
    // is only shown if the content size is greater than the viewport size by at least SDT.

    var contentSize:Point = getLayoutContentSize();

    var viewportPreferredW:Number = _documentView.getPreferredBoundsWidth();
    var viewportContentW:Number = contentSize.x;
    var viewportW:Number = _documentView.getLayoutBoundsWidth();  // "current" size
    var currentSizeNoHSB:Boolean = !isNaN(viewportW) && ((viewportW + SDT) > viewportContentW);
    if (hAuto && !showHSB && ((viewportPreferredW + SDT) <= viewportContentW) && currentSizeNoHSB) {
      measuredW += viewportW;
    }
    else {
      measuredW += Math.max(viewportPreferredW, (showHSB) ? hsb.getMinBoundsWidth() : 0);
    }

    var viewportPreferredH:Number = _documentView.getPreferredBoundsHeight();
    var viewportContentH:Number = contentSize.y;
    var viewportH:Number = _documentView.getLayoutBoundsHeight();  // "current" size
    var currentSizeNoVSB:Boolean = !isNaN(viewportH) && ((viewportH + SDT) > viewportContentH);
    if (vAuto && !showVSB && ((viewportPreferredH + SDT) <= viewportContentH) && currentSizeNoVSB) {
      measuredH += viewportH;
    }
    else {
      measuredH += Math.max(viewportPreferredH, (showVSB) ? vsb.getMinBoundsHeight() : 0);
    }

    var minW:Number = minViewportInset * 2;
    var minH:Number = minViewportInset * 2;
    // If the viewport's explicit size is set, then include that in the scroller's minimum size
    if (_documentView is IUIComponent) {
      var viewportUIC:IUIComponent = IUIComponent(_documentView);
      if (!isNaN(viewportUIC.explicitWidth)) {
        minW += viewportUIC.explicitWidth;
      }

      if (!isNaN(viewportUIC.explicitHeight)) {
        minH += viewportUIC.explicitHeight;
      }
    }

    measuredWidth = Math.ceil(measuredW);
    measuredHeight = Math.ceil(measuredH);
    measuredMinWidth = Math.ceil(minW);
    measuredMinHeight = Math.ceil(minH);
  }

  private function set hsbVisible(value:Boolean):void {
    if (_horizontalScrollBar != null) {
      _horizontalScrollBar.visible = value;
    }
  }

  private function set vsbVisible(value:Boolean):void {
    if (_verticalScrollBar != null) {
      _verticalScrollBar.visible = value;
    }
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    var hsb:ScrollBarBase = _horizontalScrollBar;
    var vsb:ScrollBarBase = _verticalScrollBar;
    var contentSize:Point = getLayoutContentSize();
    var contentW:Number = contentSize.x;
    var contentH:Number = contentSize.y;

    // If the viewport's size has been explicitly set (not typical) then use it
    // The initial values for viewportW,H are only used to decide if auto scrollbars should be shown.
    var viewportUIC:IUIComponent = _documentView as IUIComponent;
    var explicitViewportW:Number = viewportUIC ? viewportUIC.explicitWidth : NaN;
    var explicitViewportH:Number = viewportUIC ? viewportUIC.explicitHeight : NaN;

    var viewportW:Number = isNaN(explicitViewportW) ? (w - (minViewportInset * 2)) : explicitViewportW;
    var viewportH:Number = isNaN(explicitViewportH) ? (h - (minViewportInset * 2)) : explicitViewportH;

    // Decide which scrollbars will be visible based on the viewport's content size
    // and the scroller's scroll policies. A scrollbar is shown if the content size
    // greater than the viewport's size by at least SDT.
    const oldShowHSB:Boolean = hsbVisible;
    const oldShowVSB:Boolean = vsbVisible;

    const hAuto:Boolean = _horizontalScrollPolicy == ScrollPolicy.AUTO;
    if (hAuto) {
      _horizontalScrollBar.visible = contentW >= (viewportW + SDT);
    }

    const vAuto:Boolean = _verticalScrollPolicy == ScrollPolicy.AUTO;
    if (vAuto) {
      _verticalScrollBar.visible = contentH >= (viewportH + SDT);
    }

    // Reset the viewport's width,height to account for the visible scrollbars, unless
    // the viewport's size was explicitly set, then we just use that.
    if (isNaN(explicitViewportW)) {
      viewportW = w - (vsbVisible ? (minViewportInset + vsbRequiredWidth()) : (minViewportInset * 2));
    }
    if (isNaN(explicitViewportH)) {
      viewportH = h - (hsbVisible ? (minViewportInset + hsbRequiredHeight()) : (minViewportInset * 2));
    }

    // If the scrollBarPolicy is auto, and we're only showing one scrollbar,
    // the viewport may have shrunk enough to require showing the other one.
    if (vsbVisible && !hsbVisible && hAuto && (contentW >= (viewportW + SDT))) {
      hsbVisible = true;
    }
    else if (!vsbVisible && hsbVisible && vAuto && (contentH >= (viewportH + SDT))) {
      vsbVisible = true;
    }

    if (isNaN(explicitViewportW)) {
      viewportW = w - (vsbVisible ? (minViewportInset + vsbRequiredWidth()) : (minViewportInset * 2));
    }
    if (isNaN(explicitViewportH)) {
      viewportH = h - (hsbVisible ? (minViewportInset + hsbRequiredHeight()) : (minViewportInset * 2));
    }

    // Layout the viewport and scrollbars.
    _documentView.setLayoutBoundsSize(viewportW, viewportH);
    _documentView.setLayoutBoundsPosition(minViewportInset, minViewportInset);

    if (hsbVisible) {
      var hsbH:Number = hsb.getExplicitOrMeasuredHeight();
      hsb.setActualSize(vsbVisible ? w - vsb.getExplicitOrMeasuredWidth() : w, hsbH);
      hsb.y = h - hsbH;
    }

    if (vsbVisible) {
      var vsbW:Number = vsb.getExplicitOrMeasuredWidth();
      vsb.setActualSize(vsbW, hsbVisible ? h - hsb.getExplicitOrMeasuredHeight() : h);
      vsb.x = w - vsbW;
    }

    if ((vAuto && vsbVisible != oldShowVSB) || (hAuto && hsbVisible != oldShowHSB)) {
      invalidateSize();
      // If the viewport's layout is virtual, it's possible that its measured size changed as a consequence of laying it out,
      // so we invalidate its size as well.
      var viewportGroup:GroupBase = _documentView as GroupBase;
      if (viewportGroup != null && viewportGroup.layout.useVirtualLayout) {
        viewportGroup.invalidateSize();
      }
    }

    // setContentSize(w, h);
  }

  //	private var _contentWidth:Number = 0;
  //	private var _contentHeight:Number = 0;
}
}