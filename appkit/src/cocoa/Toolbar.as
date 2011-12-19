package cocoa {
import net.miginfocom.layout.LC;
import net.miginfocom.layout.UnitValue;

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

  override protected function createDefaultLayout():MigLayout {
    var lc:LC = new LC();
    lc.hideMode = 3;
    lc.alignY = UnitValue.CENTER;

    var insets:Vector.<UnitValue> = new Vector.<UnitValue>(4, true);
    for (var i:int = 0; i < 4; i++) {
      insets[i] = UnitValue.ZERO;
    }
    lc.insets = insets;

    var layout:MigLayout = new MigLayout();
    layout.setLayoutConstraints(lc);
    return layout;
  }
}
}