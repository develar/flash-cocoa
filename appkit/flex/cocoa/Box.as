package cocoa {
import flash.utils.Dictionary;

import spark.layouts.supportClasses.LayoutBase;

use namespace ui;

public class Box extends AbstractSkinnableComponent implements ViewContainerProvider {
  protected static const _skinParts:Dictionary = new Dictionary();
  _skinParts.contentGroup = 0;
  override protected function get skinParts():Dictionary {
    return _skinParts;
  }

  ui var contentGroup:Container;


  override protected function get primaryLaFKey():String {
    return "Box";
  }

  private var _layout:LayoutBase;
  public function set layout(value:LayoutBase):void {
    _layout = value;
  }

  ui function contentGroupAdded():void {
    if (_layout != null) {
      //contentGroup.layout = _layout;
    }

    //contentGroup.subviews = _elements;
  }

  protected var _resourceBundle:String;
  public function set resourceBundle(value:String):void {
    _resourceBundle = value;
  }

  public function get viewContainer():ViewContainer {
    return contentGroup;
  }
}
}