package cocoa {
import cocoa.plaf.IconButtonSkin;
import cocoa.plaf.LookAndFeel;

public class ToggleIconButton extends IconButton implements ToggleButton {
  override protected function get toggled():Boolean {
    return true;
  }

  private var _alternateIconId:String;
  public function set alternateIconId(value:String):void {
    if (value != _alternateIconId) {
      _alternateIconId = value;
    }
  }

  private var _alternateIcon:Icon;
  public function get alternateIcon():Icon {
    return _alternateIcon;
  }

  public function set alternateIcon(value:Icon):void {
    if (value != _alternateIcon) {
      _alternateIcon = value;
      if (skin != null && _state == CellState.ON) {
        IconButtonSkin(skin).icon = _alternateIcon;
      }
    }
  }

  override protected function preSkinCreate(laf:LookAndFeel):void {
    super.preSkinCreate(laf);
    
    if (_alternateIconId != null) {
      _alternateIcon = laf.getIcon(_alternateIconId);
    }
  }

  override protected function skinAttached():void {
    super.skinAttached();
  }

  override public function set state(value:int):void {
    if (_alternateIcon != null) {
      IconButtonSkin(skin).icon = value == CellState.ON ? _alternateIcon : icon;
    }

    super.state = value;
  }
}
}