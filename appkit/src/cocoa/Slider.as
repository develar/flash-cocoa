package cocoa {
public class Slider extends AbstractControl {
  public static const VERTICAL:uint = 1 << 4;
  public static const CONTINUOUS:uint = 1 << 5;

  public function Slider(vertical:Boolean) {
    super();

    if (vertical) {
      flags |= VERTICAL;
    }
  }

  override protected function get primaryLaFKey():String {
    return "Slider";
  }

  public function get vertical():Boolean {
    return (flags & VERTICAL) != 0;
  }

  public function get continuous():Boolean {
    return (flags & CONTINUOUS) != 0;
  }

  public function set continuous(value:Boolean):void {
    value ? flags &= ~CONTINUOUS : flags |= CONTINUOUS;
  }

  private var _tick:Number = 0.01;
  public function get tick():Number {
    return _tick;
  }

  public function set tick(value:Number):void {
    _tick = value;
  }
  
  private var _value:Number;
  public function get value():Number {
    return _value;
  }

  public function set value(value:Number):void {
    value = snapValue(correctValue(value));
    if (_value == value) {
      return;
    }
    
    _value = value;
  }

  private var _min:Number;
  public function get min():Number {
    return _min;
  }

  public function set min(value:Number):void {
    _min = value;
  }

  private var _max:Number = 100;
  public function get max():Number {
    return _max;
  }

  public function set max(value:Number):void {
    _max = value;
  }

  override public function get objectValue():Object {
    return value;
  }

  override public function set objectValue(value:Object):void {
    this.value = value as Number;
  }

  public function setValue(value:Number, finalChange:Boolean):void {
    // value is NaN if we want inform slider about end of interaction (but value already set) – finalChange must be always true and continuous must be false in this case.
    if (finalChange && value != value) {
      callUserInitiatedActionHandler();
      return;
    }

    value = snapValue(value);
    if (_value == value) {
      return;
    }

    _value = value;

    if (finalChange || continuous) {
      callUserInitiatedActionHandler();
    }
  }

  private function correctValue(value:Number):Number {
    return Math.max(Math.min(value, max), min);
  }

  private function snapValue(value:Number):Number {
    return Math.round(value / _tick) * _tick;
  }
}
}
