package cocoa {
import cocoa.pane.TitledPane;
import cocoa.plaf.TitledComponentSkin;

[Abstract]
public class TitledComponent extends AbstractSkinnableView implements TitledPane {
  private var _title:String;
  public function get title():String {
    return _title;
  }

  public function set title(value:String):void {
    if (value != _title) {
      _title = value;
      if (skin != null) {
        TitledComponentSkin(skin).title = _title;
      }
    }
  }

  override protected function skinAttached():void {
    if (_title != null) {
      TitledComponentSkin(skin).title = _title;
    }
  }
}
}