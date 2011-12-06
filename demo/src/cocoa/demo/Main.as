package cocoa.demo {
import cocoa.Container;
import cocoa.Label;
import cocoa.MigLayout;
import cocoa.plaf.aqua.AquaLookAndFeel;

import flash.display.StageAlign;
import flash.display.StageScaleMode;

import net.miginfocom.layout.ComponentWrapper;

[ResourceBundle("Dialog")]
public class Main extends Container {
  public function Main() {
    var layout:MigLayout = new MigLayout("", "[][grow][][grow]", "[][]");
    subviews = createComponents();
    this.layout = layout;
    initRoot(new AquaLookAndFeel());
    validate();
  }

  private function createComponents():Vector.<ComponentWrapper> {
    stage.scaleMode = StageScaleMode.NO_SCALE;
    stage.align = StageAlign.TOP_LEFT;

    var components:Vector.<ComponentWrapper> = new Vector.<ComponentWrapper>();
    var l1:Label = new Label();
    l1.title = "First Name";
    components[0] = l1;

    return components;
  }
}
}
