package cocoa {
import flash.utils.Dictionary;

import spark.layouts.supportClasses.LayoutBase;

use namespace ui;

[DefaultProperty("subviews")]
public class Box extends AbstractSkinnableView {
  public var subviews:Vector.<View>;

  protected static const _skinParts:Dictionary = new Dictionary();
  _skinParts.contentGroup = 0;
  override protected function get skinParts():Dictionary {
    return _skinParts;
  }

  ui var contentView:Container;

  override protected function get primaryLaFKey():String {
    return "Box";
  }

  private var _layout:LayoutBase;
  public function set layout(value:LayoutBase):void {
    _layout = value;
  }

  protected var _resourceBundle:String;
  public function set resourceBundle(value:String):void {
    _resourceBundle = value;
  }
}
}