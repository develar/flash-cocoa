package cocoa.renderer {
import cocoa.CheckBox;
import cocoa.plaf.ButtonSkinInteraction;

public class CheckBoxEntry extends TextLineEntry {
  private var factory:CheckBoxEntryFactory;

  public var checkbox:CheckBox;

  public function get interaction():ButtonSkinInteraction {
    return ButtonSkinInteraction(checkbox.skin);
  }

  function CheckBoxEntry(selected:Boolean, factory:CheckBoxEntryFactory) {
    this.factory = factory;
    checkbox = new CheckBox();
    checkbox.selected = selected;

    super(null);
  }

  override public function addToPool():void {
    factory.addToPool(this);
  }
}
}
