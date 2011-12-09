package cocoa.plaf.aqua {
import cocoa.SkinnableView;
import cocoa.Toolbar;
import cocoa.plaf.basic.BoxSkin;

public class ToolbarSkin extends BoxSkin {
  override public function attach(component:SkinnableView):void {
    super.attach(component);

    laf.getBorder(hostComponent.lafKey + ".b", true);
    this.laf = AquaLookAndFeel(laf).createWindowFrameLookAndFeel(Toolbar(hostComponent).small);
  }
}
}