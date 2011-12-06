package cocoa {
import flash.utils.Dictionary;

import net.miginfocom.layout.ComponentWrapper;

use namespace ui;

[DefaultProperty("subviews")]
public class Box extends ObjectBackedSkinnableView {
  ui var contentView:Container;

  protected static const _skinParts:Dictionary = new Dictionary();
  _skinParts.contentGroup = 0;
  override protected function get skinParts():Dictionary {
    return _skinParts;
  }

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

  ui function contentViewAdded():void {
    contentView.layout = _layout == null ? new MigLayout() : _layout;
    contentView.subviews = _subviews;
  }
}
}