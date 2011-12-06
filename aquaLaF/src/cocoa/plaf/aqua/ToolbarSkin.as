package cocoa.plaf.aqua {
import cocoa.Container;
import cocoa.Toolbar;
import cocoa.plaf.basic.BoxSkin;

public class ToolbarSkin extends BoxSkin {
  override public function init(container:Container):void {
    var laf:AquaLookAndFeel = AquaLookAndFeel(container.laf);
    laf.getBorder(hostComponent.lafKey + ".b", true);
    this.laf = laf.createWindowFrameLookAndFeel(Toolbar(hostComponent).small);

    super.init(container);
  }
}
}