package cocoa {
public class AbstractControl extends AbstractComponent implements Control, Cell {
  protected var _action:Function;
  public function set action(value:Function):void {
    _action = value;
  }

  protected var _toolTip:String;
  public function set toolTip(value:String):void {
    if (value != _toolTip) {
      _toolTip = value;
      if (skin != null) {
        skin.toolTip = _toolTip;
      }
    }
  }

  protected var _actionRequireTarget:Boolean;
  public function set actionRequireTarget(value:Boolean):void {
    _actionRequireTarget = value;
  }

  protected var _state:int = CellState.OFF;
  public final function get state():int {
    return _state;
  }

  public function set state(value:int):void {
    _state = value;
    if (skin != null) {
      skin.invalidateDisplayList();

      updateToolTip();
    }
  }

  protected function updateToolTip():void {
    if (_alternateToolTip != null) {
      skin.toolTip = _state == CellState.ON ? _alternateToolTip : _toolTip;
    }
  }

  public function get objectValue():Object {
    throw new Error("abstract");
  }

  public function set objectValue(value:Object):void {
    throw new Error("abstract");
  }

  override protected function skinAttached():void {
    super.skinAttached();

    if (_toolTip != null) {
      skin.toolTip = _toolTip;
    }
  }

  private var _alternateToolTip:String;
  public function set alternateToolTip(value:String):void {
    if (value != _alternateToolTip) {
      _alternateToolTip = value;
      if (skin != null && _state == CellState.ON) {
        skin.toolTip = _alternateToolTip;
      }
    }
  }
}
}