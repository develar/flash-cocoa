package cocoa.plaf.basic {
import cocoa.ContentView;
import cocoa.ObjectBackedView;
import cocoa.ScrollBar;
import cocoa.ScrollPolicy;
import cocoa.ScrollView;
import cocoa.SkinnableView;
import cocoa.Viewport;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;

import flash.display.DisplayObjectContainer;

public class ScrollViewSkin extends ObjectBackedView implements Skin {
  private var displayObjectContainer:DisplayObjectContainer;
  private var laf:LookAndFeel;

  private var scrollView:ScrollView;
  public final function get component():SkinnableView {
    return scrollView;
  }

  override public function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void {
    this.displayObjectContainer = displayObjectContainer;
    this.laf = laf;
  }

  public function attach(component:SkinnableView):void {
    scrollView = ScrollView(component);

    var documentView:Viewport = scrollView.documentView;
    documentView.addToSuperview(displayObjectContainer, laf);
    documentView.clipAndEnableScrolling = true;

    documentView.contentSizeChanged.add(contentSizeChanged);
    documentView.scrollPositionReset.add(scrollPositionReset);

    if (scrollView.verticalScrollPolicy != ScrollPolicy.OFF) {
      var vScrollBar:ScrollBar = new ScrollBar(true);
      vScrollBar.addToSuperview(displayObjectContainer, laf);
      component.uiPartAdded(null, vScrollBar);
    }
    if (scrollView.horizontalScrollPolicy != ScrollPolicy.OFF) {
      var hScrollBar:ScrollBar = new ScrollBar(true);
      hScrollBar.addToSuperview(displayObjectContainer, laf);
      component.uiPartAdded(null, hScrollBar);
    }
  }

  private function contentSizeChanged():void {
    if (superview != null) {
      superview.invalidateSubview(false);
    }
  }

  private function scrollPositionReset():void {
    if (scrollViewhorizontalScrollBar != null) {
      _horizontalScrollBar.value = 0;
    }
    if (_verticalScrollBar != null) {
      _verticalScrollBar.value = 0;
    }
  }


  public function hostComponentPropertyChanged():void {
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
