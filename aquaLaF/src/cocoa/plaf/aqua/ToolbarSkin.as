package cocoa.plaf.aqua {
import cocoa.ContentView;
import cocoa.Toolbar;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.basic.BoxSkin;

import flash.display.DisplayObjectContainer;

public class ToolbarSkin extends BoxSkin {
  override public function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void {
    super.addToSuperview(displayObjectContainer, laf, superview);

    laf.getBorder(hostComponent.lafKey + ".b", true);
    this.laf = AquaLookAndFeel(laf).createWindowFrameLookAndFeel(Toolbar(hostComponent).small);
  }
}
}