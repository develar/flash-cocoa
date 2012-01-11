package cocoa {
import net.miginfocom.layout.ComponentWrapper;

[DefaultProperty("subviews")]
public class Box extends AbstractSkinnableView {
  override protected function get primaryLaFKey():String {
    return "Box";
  }

  private var _layout:MigLayout;
  public function set layout(value:MigLayout):void {
    _layout = value;
  }

  private var _subviews:Vector.<ComponentWrapper>;
  public function set subviews(value:Vector.<ComponentWrapper>):void {
    _subviews = value;
  }

  override public function uiPartAdded(id:String, instance:Object):void {
    var contentView:Container = Container(instance);
    contentView.layout = _layout == null ? createDefaultLayout() : _layout;
    contentView.subviews = _subviews;
  }

  protected function createDefaultLayout():MigLayout {
    return new MigLayout();
  }
}
}