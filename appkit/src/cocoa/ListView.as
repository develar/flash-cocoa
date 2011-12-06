package cocoa {
import cocoa.plaf.LookAndFeel;

public class ListView extends SegmentedControl {
  private var border:Border;

  public function ListView() {
    _lafKey = "List";
  }

  override public function addToSuperview(superview:ContentView):void {
    super.addToSuperview(superview);

    var laf:LookAndFeel = superview.laf;
    border = laf.getBorder(_lafKey + ".b", true);
    if (border != null) {
      layout.insets = border.contentInsets;
    }
  }

  override protected function draw(w:int, h:int):void {
    if (border != null) {
      graphics.clear();
      border.draw(graphics, w, h);
    }

    super.draw(w, h);
  }
}
}