package cocoa.plaf.aqua {
import cocoa.ContentView;
import cocoa.Toolbar;
import cocoa.plaf.basic.BoxSkin;

public class ToolbarSkin extends BoxSkin {
  override public function addToSuperview(superview:ContentView):void {
    super.addToSuperview(superview);

    var laf:AquaLookAndFeel = AquaLookAndFeel(superview.laf);
    laf.getBorder(hostComponent.lafKey + ".b", true);
    this.laf = laf.createWindowFrameLookAndFeel(Toolbar(hostComponent).small);
  }
}
}