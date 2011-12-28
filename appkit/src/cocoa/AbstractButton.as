package cocoa {
import cocoa.plaf.TitledComponentSkin;

public class AbstractButton extends AbstractControl {
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

  override public function get objectValue():Object {
    return title;
  }

  override public function set objectValue(value:Object):void {
    title = value as String;
  }

  public function setStateAndCallUserInitiatedActionHandler(value:int):void {
    _state = value;
    updateToolTip();

    callUserInitiatedActionHandler();
  }

  override protected function skinAttached():void {
    super.skinAttached();

    if (_title != null) {
      TitledComponentSkin(skin).title = _title;
    }
  }
}
}