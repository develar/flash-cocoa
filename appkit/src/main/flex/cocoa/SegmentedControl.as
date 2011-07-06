package cocoa {
import cocoa.layout.SegmentedControlHorizontalLayout;
import cocoa.plaf.LookAndFeelUtil;
import cocoa.plaf.basic.SegmentedControlController;

import org.flyti.util.List;

public class SegmentedControl extends AbstractView {
   public function get items():List {
    return List(dataProvider);
  }
  public function set items(value:List):void {
    dataProvider = value;
  }

  public function get hidden():Boolean {
    return !visible && !includeInLayout;
  }
  public function set hidden(value:Boolean):void {
    visible = !value;
    includeInLayout = !value;
  }

  private var _action:Function;
  public function set action(value:Function):void {
    _action = value;
  }

  public function get objectValue():Object {
    return null;
  }
  public function set objectValue(value:Object):void {
  }

  override protected function createChildren():void {
    if (layout == null) {
      layout = new SegmentedControlHorizontalLayout();
    }

    laf = LookAndFeelUtil.find(parent);
    SegmentedControlController(laf.getFactory((lafSubkey == null ? "SegmentedControl" : lafSubkey) + ".segmentedControlController", false).newInstance()).register(this);
    if (lafSubkey == null && itemRenderer == null) {
      itemRenderer = laf.getFactory("SegmentedControl.iR", false);
    }

    super.createChildren();
  }

  override protected function dispatchIndexChangeEvent(userInitiatedAction:Boolean):void {
    if (userInitiatedAction && _action != null) {
      _action.length == 0 ? _action() : _action(selectedItem);
    }
  }
}
}