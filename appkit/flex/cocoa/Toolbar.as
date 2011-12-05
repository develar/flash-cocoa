package cocoa {
public class Toolbar extends Box {
  override protected function get primaryLaFKey():String {
    return "Toolbar";
  }

  private var _small:Boolean;
  public function get small():Boolean {
    return _small;
  }

  public function set small(value:Boolean):void {
    _small = value;
  }
}
}