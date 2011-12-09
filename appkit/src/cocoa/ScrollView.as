package cocoa {
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObjectContainer;

import mx.core.IUIComponent;

import spark.components.supportClasses.GroupBase;

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
public class ScrollView extends ObjectBackedView {
  private var superview:ContentView;

  private var _horizontalScrollBar:ScrollBar;
  private var _verticalScrollBar:ScrollBar;

  /**
   * SDT - ScrollBar Display Threshold.  If the content size exceeds the viewport's size by SDT, then we show a scrollbar.
   * For example, if the contentWidth >= viewport width + SDT, show the horizontal scrollbar.
   */
  private static const SDT:Number = 1.0;

  private var _documentView:Viewport;
  public function set documentView(value:Viewport):void {
    if (value != _documentView) {
      _documentView = value;
      if (superview != null) {
        superview.invalidateSubview(false);
      }
    }
  }

  private var _verticalScrollPolicy:int = ScrollPolicy.AUTO;
  public function set verticalScrollPolicy(value:int):void {
    _verticalScrollPolicy = value;

    if (_verticalScrollBar != null) {
      _verticalScrollBar.visible = _verticalScrollPolicy != ScrollPolicy.OFF;
    }
  }

  private var _horizontalScrollPolicy:int = ScrollPolicy.AUTO;
  public function set horizontalScrollPolicy(value:int):void {
    _horizontalScrollPolicy = value;

    if (_horizontalScrollBar != null) {
      _horizontalScrollBar.visible = _horizontalScrollPolicy != ScrollPolicy.OFF;
    }
  }

  override public function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void {
    this.superview = superview;

    if (_verticalScrollPolicy != ScrollPolicy.OFF) {
      _verticalScrollBar = new ScrollBar(true);
      _verticalScrollBar.addToSuperview(displayObjectContainer, laf, superview);
    }

    if (_horizontalScrollPolicy != ScrollPolicy.OFF) {
      _horizontalScrollBar = new ScrollBar(false);
      _horizontalScrollBar.addToSuperview(displayObjectContainer, laf, superview);
    }

    _documentView.clipAndEnableScrolling = true;
    _documentView.addToSuperview(displayObjectContainer, laf, superview);
    _documentView.contentSizeChanged().add(documentViewPropertyChangeHandler);
  }

  private function documentViewPropertyChangeHandler():void {
    if (superview != null) {
      superview.invalidateSubview(false);
    }
  }

  private function get hsbVisible():Boolean {
    return _horizontalScrollBar != null && _horizontalScrollBar.visible;
  }

  private function get vsbVisible():Boolean {
    return _verticalScrollBar != null && _verticalScrollBar.visible;
  }

  private function measure():void {
    var hsb:ScrollBar = _horizontalScrollBar;
    var showHSB:Boolean = false;
    var hAuto:Boolean = false;
    switch (_horizontalScrollPolicy) {
      case ScrollPolicy.ON:
        showHSB = true;
        break;

      case ScrollPolicy.AUTO:
        if (hsb != null) {
          showHSB = hsb.visible;
        }
        hAuto = true;
        break;
    }

    var vsb:ScrollBar = _verticalScrollBar;
    var showVSB:Boolean = false;
    var vAuto:Boolean = false;
    switch (_verticalScrollPolicy) {
      case ScrollPolicy.ON:
        showVSB = true;
        break;

      case ScrollPolicy.AUTO:
        if (vsb != null) {
          showVSB = vsb.visible;
        }
        vAuto = true;
        break;
    }

    var measuredW:Number = showHSB ? _horizontalScrollBar.getPreferredHeight() : 0;
    var measuredH:Number = showVSB ? _verticalScrollBar.getPreferredWidth() : 0;
    // The measured size of the viewport is just its preferredBounds, except:
    // don't give up space if doing so would make an auto scrollbar visible.
    // In other words, if an auto scrollbar isn't already showing, and using
    // the preferred size would force it to show, and the current size would not,
    // then use its current size as the measured size. Note that a scrollbar
    // is only shown if the content size is greater than the viewport size by at least SDT.
    var viewportContentW:int = _documentView.contentWidth;
    var viewportW:int = _documentView.getPreferredWidth();
    var currentSizeNoHSB:Boolean = viewportW + SDT > viewportContentW;
    if (hAuto && !showHSB && ((viewportW + SDT) <= viewportContentW) && currentSizeNoHSB) {
      measuredW += viewportW;
    }
    else {
      measuredW += Math.max(viewportW, showHSB ? hsb.getMinimumWidth() : 0);
    }

    var viewportContentH:int = _documentView.contentHeight;
    var viewportH:Number = _documentView.getPreferredHeight();
    var currentSizeNoVSB:Boolean = !isNaN(viewportH) && ((viewportH + SDT) > viewportContentH);
    if (vAuto && !showVSB && ((viewportH + SDT) <= viewportContentH) && currentSizeNoVSB) {
      measuredH += viewportH;
    }
    else {
      measuredH += Math.max(viewportH, showVSB ? vsb.getMinimumHeight() : 0);
    }

    var minW:Number = 0;
    var minH:Number = 0;
    // If the viewport's explicit size is set, then include that in the scroller's minimum size
    if (_documentView is IUIComponent) {
      var viewportUIC:IUIComponent = IUIComponent(_documentView);
      if (!isNaN(viewportUIC.explicitWidth)) {
        minW += viewportUIC.explicitWidth;
      }
      else {
        minW += viewportUIC.minWidth;
      }

      if (!isNaN(viewportUIC.explicitHeight)) {
        minH += viewportUIC.explicitHeight;
      }
      else {
        minH += viewportUIC.minHeight;
      }
    }

    //measuredWidth = Math.ceil(measuredW);
    //measuredHeight = Math.ceil(measuredH);
    //measuredMinWidth = Math.ceil(minW);
    //measuredMinHeight = Math.ceil(minH);
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

   protected function draw(w:Number, h:Number):void {
    var hsb:ScrollBar = _horizontalScrollBar;
    var vsb:ScrollBar = _verticalScrollBar;
    var contentW:int = _documentView.contentWidth;
    var contentH:int = _documentView.contentHeight;

    // Decide which scrollbars will be visible based on the viewport's content size
    // and the scroller's scroll policies. A scrollbar is shown if the content size
    // greater than the viewport's size by at least SDT.
    const oldShowHSB:Boolean = hsbVisible;
    const oldShowVSB:Boolean = vsbVisible;

    const hAuto:Boolean = _horizontalScrollPolicy == ScrollPolicy.AUTO;
    if (hAuto) {
      _horizontalScrollBar.visible = contentW >= (w + SDT);
    }

    const vAuto:Boolean = _verticalScrollPolicy == ScrollPolicy.AUTO;
    if (vAuto) {
      _verticalScrollBar.visible = contentH >= (h + SDT);
    }

    // Reset the viewport's width,height to account for the visible scrollbars, unless
    // the viewport's size was explicitly set, then we just use that.
    var viewportW:int = w - (vsbVisible ? _verticalScrollBar.actualWidth : 0);
    var viewportH:int = h - (hsbVisible ? _horizontalScrollBar.actualHeight : 0);

    // If the scrollBarPolicy is auto, and we're only showing one scrollbar,
    // the viewport may have shrunk enough to require showing the other one.
    if (vsbVisible && !hsbVisible && hAuto && (contentW >= (viewportW + SDT))) {
      hsbVisible = true;
    }
    else if (!vsbVisible && hsbVisible && vAuto && (contentH >= (viewportH + SDT))) {
      vsbVisible = true;
    }

    viewportW = w - (vsbVisible ? _verticalScrollBar.getPreferredWidth() : 0);
    viewportH = h - (hsbVisible ? _horizontalScrollBar.getPreferredHeight() : 0);

    // Layout the viewport and scrollbars.
    _documentView.setSize(viewportW, viewportH);
    _documentView.validate();

    if (hsbVisible) {
      var hsbH:int = hsb.actualHeight;
      hsb.setBounds(hsb.x, h - hsbH, vsbVisible ? w - vsb.getPreferredWidth() : w, hsbH);
    }

    if (vsbVisible) {
      var vsbW:Number = vsb.actualWidth;
      vsb.setBounds(w - vsbW, vsb.y, vsbW, hsbVisible ? h - hsb.getPreferredHeight() : h);
    }

    if ((vAuto && vsbVisible != oldShowVSB) || (hAuto && hsbVisible != oldShowHSB)) {
      //invalidateSize();
      // If the viewport's layout is virtual, it's possible that its measured size changed as a consequence of laying it out,
      // so we invalidate its size as well.
      var viewportGroup:GroupBase = _documentView as GroupBase;
      if (viewportGroup != null && viewportGroup.layout.useVirtualLayout) {
        viewportGroup.invalidateSize();
      }
    }
  }
}
}