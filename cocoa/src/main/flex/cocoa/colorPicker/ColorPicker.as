package cocoa.colorPicker {
import cocoa.PopUpButton;
import cocoa.ui;

import flash.events.Event;

use namespace ui;

public class ColorPicker extends PopUpButton {
  public function ColorPicker() {
    super();

    _menu = ColorPickerMenu.create();
  }

  public function get argb():uint {
    return (0xff << 24) | color;
  }

  public function get hasSelectedColor():Boolean {
    return selectedIndex != ColorPickerMenu(menu).noColorItemIndex;
  }

  private var _color:uint;
  public function get color():uint {
    return _color;
  }

  public function set color(value:uint):void {
    _color = value;
  }

  override protected function get primaryLaFKey():String {
    return "ColorPicker";
  }

  override protected function synchronizeTitleAndSelectedItem(event:Event = null):void {
  }

  public function setColorAndCallUserInitiatedActionHandler(index:int, value:Number):void {
    if (index == ColorPickerMenu(menu).noColorItemIndex) {
      setSelectedIndex(index, true);
    }
    else if (!isNaN(value) && value != color) {
      color = value;
      selectedIndex = index;
      
      if (_action != null) {
        _action();
      }
    }
  }

  /**
   * @return color if hasColor, or null
   */
  override public function get objectValue():Object {
    return hasSelectedColor ? color : null;
  }

  override public function set objectValue(value:Object):void {
    if (value is uint) {
      color = uint(value);
    }
    else {
      selectedIndex = ColorPickerMenu(menu).noColorItemIndex;
    }
  }
}
}