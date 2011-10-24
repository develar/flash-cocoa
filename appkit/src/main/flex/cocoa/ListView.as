package cocoa {
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelUtil;

public class ListView extends SegmentedControl {
  private var border:Border;

  public function ListView() {
    _lafKey = "List";
  }

  override protected function createChildren():void {
    super.createChildren();

    var laf:LookAndFeel = LookAndFeelUtil.find(parent);
    border = laf.getBorder(_lafKey + ".b", true);
    if (border != null) {
      layout.insets = border.contentInsets;
    }
  }

  override protected function measure():void {
    super.measure();
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    if (border != null) {
      graphics.clear();
      border.draw(graphics, w, h);
    }

    super.updateDisplayList(w, h);
  }
}
}