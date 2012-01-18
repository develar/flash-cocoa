package cocoa {
/**
 * http://developer.apple.com/mac/library/documentation/cocoa/reference/ApplicationKit/Classes/NSScrollView_Class/Reference/Reference.html
 * http://developer.apple.com/mac/library/documentation/cocoa/Conceptual/NSScrollViewGuide/Articles/Basics.html
 */
[DefaultProperty("documentView")]
public class ScrollView extends AbstractSkinnableView {
  override protected function get primaryLaFKey():String {
    return "ScrollView";
  }

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

  private var _horizontalScroller:Scroller;
  public function get horizontalScroller():Scroller {
    return _horizontalScroller;
  }

  private var _verticalScroller:Scroller;
  public function get verticalScroller():Scroller {
    return _verticalScroller;
  }

  private var _verticalScrollPolicy:int = ScrollPolicy.AUTO;
  public function get verticalScrollPolicy():int {
    return _verticalScrollPolicy;
  }
  public function set verticalScrollPolicy(value:int):void {
    _verticalScrollPolicy = value;

    if (_verticalScroller != null) {
      _verticalScroller.visible = _verticalScrollPolicy != ScrollPolicy.OFF;
    }
  }

  private var _horizontalScrollPolicy:int = ScrollPolicy.AUTO;
  public function get horizontalScrollPolicy():int {
    return _horizontalScrollPolicy;
  }
  public function set horizontalScrollPolicy(value:int):void {
    _horizontalScrollPolicy = value;

    if (_horizontalScroller != null) {
      _horizontalScroller.visible = _horizontalScrollPolicy != ScrollPolicy.OFF;
    }
  }

  override public function uiPartAdded(id:String, instance:Object):void {
    var scroller:Scroller = Scroller(instance);
    scroller.action = scrollHandler;
    scroller.vertical ? _verticalScroller = scroller : _horizontalScroller = scroller;
  }

  private function scrollHandler(scroller:Scroller, userInitiated:Boolean):void {
    if (scroller == _verticalScroller) {
      _documentView.verticalScrollPosition = scroller.value;
    }
    else {
      _documentView.horizontalScrollPosition = scroller.value;
    }
  }
}
}