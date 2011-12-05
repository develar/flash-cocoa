package cocoa.plaf.aqua {
import cocoa.Toolbar;
import cocoa.plaf.basic.BoxSkin;

public class ToolbarSkin extends BoxSkin {
  override protected function createChildren():void {
    contentView = new BorderedContainer();

    super.createChildren();

    BorderedContainer(contentView).border = getNullableBorder();
    contentView.mouseEnabled = false;
    contentView.laf = AquaLookAndFeel(laf).createWindowFrameLookAndFeel(Toolbar(hostComponent).small);
    hostComponent.uiPartAdded("contentGroup", contentView);

    addChild(contentView);
  }
}
}