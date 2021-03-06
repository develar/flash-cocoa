package cocoa.renderer {
import cocoa.CheckBox;
import cocoa.plaf.ButtonSkinInteraction;

public class CheckBoxEntry extends TextLineEntry {
  private var factory:CheckBoxEntryFactory;

  public var checkbox:CheckBox;

  function CheckBoxEntry(selected:Boolean, factory:CheckBoxEntryFactory) {
    this.factory = factory;
    checkbox = new CheckBox();
    checkbox.selected = selected;

    super(null);
  }

  public function get interaction():ButtonSkinInteraction {
    return ButtonSkinInteraction(checkbox.skin);
  }

  override public function addToPool():void {
    factory.addToPool(this);
  }
}
}
