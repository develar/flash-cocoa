package cocoa {
use namespace ui;

/**
 * http://developer.apple.com/mac/library/documentation/cocoa/reference/ApplicationKit/Classes/NSScrollView_Class/Reference/Reference.html
 * http://developer.apple.com/mac/library/documentation/cocoa/Conceptual/NSScrollViewGuide/Articles/Basics.html
 */
[DefaultProperty("documentView")]
public class ScrollView extends AbstractSkinnableView {
  private var _horizontalScrollBar:ScrollBar;
  private var _verticalScrollBar:ScrollBar;

  private var _documentView:Viewport;
  public function get documentView():Viewport {
    return _documentView;
  }
  public function set documentView(value:Viewport):void {
    if (value != _documentView) {
      _documentView = value;
      invalidateProperties();
    }
  }

  private var _verticalScrollPolicy:int = ScrollPolicy.AUTO;
  public function get verticalScrollPolicy():int {
    return _verticalScrollPolicy;
  }
  public function set verticalScrollPolicy(value:int):void {
    _verticalScrollPolicy = value;

    if (_verticalScrollBar != null) {
      _verticalScrollBar.visible = _verticalScrollPolicy != ScrollPolicy.OFF;
    }
  }

  private var _horizontalScrollPolicy:int = ScrollPolicy.AUTO;
  public function get horizontalScrollPolicy():int {
    return _horizontalScrollPolicy;
  }
  public function set horizontalScrollPolicy(value:int):void {
    _horizontalScrollPolicy = value;

    if (_horizontalScrollBar != null) {
      _horizontalScrollBar.visible = _horizontalScrollPolicy != ScrollPolicy.OFF;
    }
  }

  override public function uiPartAdded(id:String, instance:Object):void {
    var scrolBar:ScrollBar = ScrollBar(instance);
    scrolBar.action = scrollHandler;
    scrolBar.vertical ? _verticalScrollBar = scrolBar : _horizontalScrollBar = scrolBar;
  }

  private function scrollHandler(scrollbar:ScrollBar):void {
    if (scrollbar == _verticalScrollBar) {
      _documentView.verticalScrollPosition = scrollbar.value;
    }
    else {
      _documentView.horizontalScrollPosition = scrollbar.value;
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
}
}