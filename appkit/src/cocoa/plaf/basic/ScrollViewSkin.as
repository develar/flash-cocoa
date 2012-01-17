package cocoa.plaf.basic {
import cocoa.ContentView;
import cocoa.LayoutState;
import cocoa.ScrollPolicy;
import cocoa.ScrollView;
import cocoa.Scroller;
import cocoa.SkinnableView;
import cocoa.Viewport;
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObjectContainer;

public class ScrollViewSkin extends ObjectBackedSkin {
  private var displayObjectContainer:DisplayObjectContainer;
  private var laf:LookAndFeel;

  private var scrollView:ScrollView;
  override public final function get component():SkinnableView {
    return scrollView;
  }

  override public function setLocation(x:Number, y:Number):void {
    _x = x;
    _y = y;

    scrollView.documentView.setLocation(x, y);
    var hScroller:Scroller = scrollView.horizontalScroller;
    if (hScroller != null) {
      hScroller.setLocation(x, y + (actualHeight - hScroller.actualHeight));
    }

    var vScroller:Scroller = scrollView.verticalScroller;
    if (vScroller != null) {
      vScroller.setLocation(x + (actualWidth - vScroller.actualWidth), y);
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
      // after setBounds/setLocation/setSize superview validate subview (i.e. call subview.validate) in any case — subview doesn't need to invalidate container
      flags |= LayoutState.DISPLAY_INVALID;
    }
  }

  override public function validate():Boolean {
    if ((flags & LayoutState.DISPLAY_INVALID) == 0) {
      return false;
    }

    flags &= ~LayoutState.DISPLAY_INVALID;
    flags &= ~LayoutState.SIZE_INVALID;
    draw(_actualWidth, _actualHeight);

    return true;
  }

  private function getWidth(pref:Boolean):int {
    var w:int = pref ? scrollView.documentView.getPreferredWidth() : scrollView.documentView.getMinimumWidth();
    if (scrollView.verticalScrollPolicy == ScrollPolicy.AUTO ? scrollView.documentView.contentHeight > scrollView.documentView.getPreferredHeight() : scrollView.verticalScrollPolicy == ScrollPolicy.ON) {
      w += scrollView.verticalScroller.getPreferredHeight();
    }

    return w;
  }

  private function getHeight(pref:Boolean):int {
    var h:int = pref ? scrollView.documentView.getPreferredHeight() : scrollView.documentView.getMinimumHeight();
    if (scrollView.horizontalScrollPolicy == ScrollPolicy.AUTO ? scrollView.documentView.contentWidth > scrollView.documentView.getPreferredWidth() : scrollView.horizontalScrollPolicy == ScrollPolicy.ON) {
      h += scrollView.horizontalScroller.getPreferredHeight();
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

  override public function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void {
    this.displayObjectContainer = displayObjectContainer;
    this.laf = laf;
    this.superview = superview;
  }

  override public function attach(component:SkinnableView):void {
    scrollView = ScrollView(component);

    var documentView:Viewport = scrollView.documentView;
    documentView.addToSuperview(displayObjectContainer, laf);
    documentView.clipAndEnableScrolling = true;

    documentView.contentSizeChanged.add(contentSizeChanged);
    documentView.scrollPositionReset.add(scrollPositionReset);

    if (scrollView.verticalScrollPolicy == ScrollPolicy.ON) {
      createScroller(true);
    }
    if (scrollView.horizontalScrollPolicy == ScrollPolicy.ON) {
      createScroller(false);
    }
  }

  private function createScroller(vertical:Boolean):Scroller {
    var scroller:Scroller = new Scroller(vertical);
    scroller.addToSuperview(displayObjectContainer, laf);
    scrollView.uiPartAdded(null, scroller);
    return scroller;
  }

  private function contentSizeChanged():void {
    invalidate(true);
  }

  private function scrollPositionReset():void {
    if (scrollView.horizontalScroller != null) {
      scrollView.horizontalScroller.value = 0;
    }
    if (scrollView.verticalScroller != null) {
      scrollView.verticalScroller.value = 0;
    }
  }

  private function get hScrollerVisible():Boolean {
    return scrollView.horizontalScroller != null && scrollView.horizontalScroller.visible;
  }

  private function get vScrollerVisible():Boolean {
    return scrollView.verticalScroller != null && scrollView.verticalScroller.visible;
  }

  protected function draw(w:Number, h:Number):void {
    var hScroller:Scroller = scrollView.horizontalScroller;
    var vScroller:Scroller = scrollView.verticalScroller;
    const contentW:int = scrollView.documentView.contentWidth;
    const contentH:int = scrollView.documentView.contentHeight;

    // Decide which scrollbars will be visible based on the viewport's content size
    // and the scroller's scroll policies. A scrollbar is shown if the content size
    // greater than the viewport's size by at least SDT.
    const oldShowHScroller:Boolean = hScrollerVisible;
    const oldShowVScroller:Boolean = vScrollerVisible;

    const hAuto:Boolean = scrollView.horizontalScrollPolicy == ScrollPolicy.AUTO;
    if (hAuto) {
      hScroller = setScrollerVisible(contentW > w, hScroller, false);
    }

    const vAuto:Boolean = scrollView.verticalScrollPolicy == ScrollPolicy.AUTO;
    if (vAuto) {
      vScroller = setScrollerVisible(contentH > h, vScroller, true);
    }

    // Reset the viewport's width, height to account for the visible scrollers
    var viewportW:int = w - (vScrollerVisible ? vScroller.getPreferredWidth() : 0);
    var viewportH:int = h - (hScrollerVisible ? hScroller.getPreferredHeight() : 0);

    // If the scrollPolicy is auto, and we're only showing one scroller,
    // the viewport may have shrunk enough to require showing the other one.
    if (vScrollerVisible && !hScrollerVisible && hAuto && (contentW > viewportW)) {
      setScrollerVisible(true, hScroller, false);
    }
    else if (!vScrollerVisible && hScrollerVisible && vAuto && contentH > viewportH) {
      setScrollerVisible(true, vScroller, true);
    }

    viewportW = w - (vScrollerVisible ? vScroller.getPreferredWidth() : 0);
    viewportH = h - (hScrollerVisible ? hScroller.getPreferredHeight() : 0);

    scrollView.documentView.setBounds(_x, _y, viewportW, viewportH);
    scrollView.documentView.validate();

    if (hScrollerVisible) {
      hScroller.contentSize = contentW;

      var hScrollerH:int = hScroller.getPreferredHeight();
      hScroller.setBounds(hScroller.x, h - hScrollerH, vScrollerVisible ? w - vScroller.getPreferredWidth() : w, hScrollerH);
      hScroller.validate();
    }

    if (vScrollerVisible) {
      const vScrollerW:Number = vScroller.getPreferredWidth();
      const vScrollerH:Number = hScrollerVisible ? h - hScroller.getPreferredHeight() : h;

      vScroller.contentSize = contentH;
      vScroller.max = Math.max(0, contentH - vScrollerH);

      vScroller.setBounds(_x + (w - vScrollerW), _y, vScrollerW, vScrollerH);
      vScroller.validate();
    }

    if ((vAuto && vScrollerVisible != oldShowVScroller) || (hAuto && hScrollerVisible != oldShowHScroller)) {
      invalidate(true);
    }
  }

  private function setScrollerVisible(visible:Boolean, scroller:Scroller, vertical:Boolean):Scroller {
    if (visible) {
      if (scroller == null) {
        return createScroller(vertical);
      }
      else {
        scroller.visible = true;
      }
    }
    else if (scroller != null) {
      scroller.visible = false;
    }

    return scroller;
  }
}
}
