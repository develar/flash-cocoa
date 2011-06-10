package cocoa {
public class TogglePushButton extends PushButton implements ToggleButton {
  [Bindable(event="selectedChanged")]
  public function get selected():Boolean {
    return _state == CellState.ON;
  }

  public function set selected(value:Boolean):void {
    if (value != selected) {
      state = value ? CellState.ON : CellState.OFF;
    }
  }
}
}