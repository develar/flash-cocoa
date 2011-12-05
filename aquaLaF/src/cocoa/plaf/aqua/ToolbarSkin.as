package cocoa.plaf.aqua {
import cocoa.BorderedContainer;
import cocoa.Toolbar;
import cocoa.layout.BarLayout;
import cocoa.plaf.basic.BoxSkin;

public class ToolbarSkin extends BoxSkin {
  public function ToolbarSkin() {
    super();

    mouseEnabled = false;
  }

  override protected function createChildren():void {
    contentGroup = new BorderedContainer();

    super.createChildren();

    BorderedContainer(contentGroup).border = getNullableBorder();
    contentGroup.mouseEnabled = false;
    contentGroup.laf = AquaLookAndFeel(laf).createWindowFrameLookAndFeel(Toolbar(hostComponent).small);
    hostComponent.uiPartAdded("contentGroup", contentGroup);

    if (contentGroup.layout == null) {
      var layout:BarLayout = new BarLayout();
      layout.padding = 10;
      layout.gap = 10;
      contentGroup.layout = layout;
    }

    addChild(contentGroup);
  }
}
}