package cocoa.plaf.aqua {
import cocoa.SkinnableView;
import cocoa.Toolbar;
import cocoa.plaf.basic.BoxSkin;

public class ToolbarSkin extends BoxSkin {
  override public function attach(component:SkinnableView):void {
    border = laf.getBorder(component.lafKey + ".b", true);
    this.laf = AquaLookAndFeel(laf).createWindowFrameLookAndFeel(Toolbar(component).small);

    super.attach(component);
  }
}
}