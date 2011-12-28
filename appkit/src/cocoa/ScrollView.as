package cocoa {
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObjectContainer;

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

  protected var _actualWidth:int = -1;
  override public function get actualWidth():int {
    return _actualWidth;
  }

  protected var _actualHeight:int = -1;
  override public function get actualHeight():int {
    return _actualHeight;
  }

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

  override public final function setSize(w:int, h:int):void {
    var resized:Boolean = false;
    if (w != _actualWidth) {
      _actualWidth = w;
      resized = true;
    }
    if (h != _actualHeight) {
      _actualHeight = h;
      resized = true;
    }

    if (resized) {
      // after setBounds/setLocation/setSize superview call subview validate in any case — subview doesn't need to invalidate container
      flags |= LayoutState.DISPLAY_INVALID;
    }
  }

  override public function validate():void {
    if ((flags & LayoutState.DISPLAY_INVALID) == 0) {
      return;
    }

    flags &= ~LayoutState.DISPLAY_INVALID;
    flags &= ~LayoutState.SIZE_INVALID;
    draw(_actualWidth, _actualHeight);
  }

  override public function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void {
    this.superview = superview;

    if (_verticalScrollPolicy != ScrollPolicy.OFF) {
      _verticalScrollBar = new ScrollBar(true);
      _verticalScrollBar.addToSuperview(displayObjectContainer, laf, superview);
      _verticalScrollBar.setAction(scrollHandler, _verticalScrollBar);
    }

    if (_horizontalScrollPolicy != ScrollPolicy.OFF) {
      _horizontalScrollBar = new ScrollBar(false);
      _horizontalScrollBar.addToSuperview(displayObjectContainer, laf, superview);
      _horizontalScrollBar.setAction(scrollHandler, _verticalScrollBar);
    }

    _documentView.clipAndEnableScrolling = true;
    _documentView.addToSuperview(displayObjectContainer, laf, superview);

    _documentView.contentSizeChanged.add(contentSizeChanged);
    _documentView.scrollPositionReset.add(scrollPositionReset);
  }

  private function scrollHandler(scrollbar:ScrollBar):void {
    if (scrollbar == _verticalScrollBar) {
      _documentView.verticalScrollPosition = scrollbar.value;
    }
    else {
      _documentView.horizontalScrollPosition = scrollbar.value;
    }
  }

  private function scrollPositionReset():void {
    if (_horizontalScrollBar != null) {
      _horizontalScrollBar.value = 0;
    }
    if (_verticalScrollBar != null) {
      _verticalScrollBar.value = 0;
    }
  }

  private function contentSizeChanged():void {
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

  private function getWidth(pref:Boolean):int {
    var w:int = pref ? _documentView.getPreferredWidth() : _documentView.getMinimumWidth();
    if (_verticalScrollPolicy == ScrollPolicy.AUTO ? _documentView.contentHeight > _documentView.getPreferredHeight() : _verticalScrollPolicy == ScrollPolicy.ON) {
      w += _verticalScrollBar.getPreferredHeight();
    }

    return w;
  }

  private function getHeight(pref:Boolean):int {
    var h:int = pref ? _documentView.getPreferredHeight() : _documentView.getMinimumHeight();
    if (_horizontalScrollPolicy == ScrollPolicy.AUTO ? _documentView.contentWidth > _documentView.getPreferredWidth() : _horizontalScrollPolicy == ScrollPolicy.ON) {
      h += _horizontalScrollBar.getPreferredHeight();
    }

    return h;
  }

  override public function getMinimumWidth(hHint:int = -1):int {
    return getWidth(false);
  }

  override public function getMinimumHeight(wHint:int = -1):int {
    return getHeight(false);
  }

  override public function getPreferredWidth(hHint:int = -1):int {
    return getWidth(true);
  }

  override public function getPreferredHeight(wHint:int = -1):int {
    return getHeight(true);
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
      _horizontalScrollBar.visible = contentW > w;
    }

    const vAuto:Boolean = _verticalScrollPolicy == ScrollPolicy.AUTO;
    if (vAuto) {
      _verticalScrollBar.visible = contentH > h;
    }

    // Reset the viewport's width,height to account for the visible scrollbars, unless
    // the viewport's size was explicitly set, then we just use that.
    var viewportW:int = w - (vsbVisible ? hsb.getPreferredWidth() : 0);
    var viewportH:int = h - (hsbVisible ? vsb.getPreferredHeight() : 0);

    // If the scrollBarPolicy is auto, and we're only showing one scrollbar,
    // the viewport may have shrunk enough to require showing the other one.
    if (vsbVisible && !hsbVisible && hAuto && (contentW > viewportW)) {
      hsbVisible = true;
    }
    else if (!vsbVisible && hsbVisible && vAuto && contentH > viewportH) {
      vsbVisible = true;
    }

    viewportW = w - (vsbVisible ? _verticalScrollBar.getPreferredWidth() : 0);
    viewportH = h - (hsbVisible ? _horizontalScrollBar.getPreferredHeight() : 0);

    _documentView.setSize(viewportW, viewportH);
    _documentView.validate();

    if (hsbVisible) {
      var hsbH:int = hsb.getPreferredHeight();
      hsb.setBounds(hsb.x, h - hsbH, vsbVisible ? w - vsb.getPreferredWidth() : w, hsbH);
      hsb.validate();
    }

    if (vsbVisible) {
      var vsbW:Number = vsb.getPreferredWidth();
      vsb.setBounds(w - vsbW, vsb.y, vsbW, hsbVisible ? h - hsb.getPreferredHeight() : h);
      vsb.validate();
    }

    if ((vAuto && vsbVisible != oldShowVSB) || (hAuto && hsbVisible != oldShowHSB)) {
      //invalidateSize();
    }
  }
}
}