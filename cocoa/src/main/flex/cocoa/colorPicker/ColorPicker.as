package cocoa.colorPicker {
import cocoa.PopUpButton;
import cocoa.ui;

import flash.events.Event;

use namespace ui;

public class ColorPicker extends PopUpButton {
  public function ColorPicker() {
    super();

    this.menu = new ColorPickerMenu();
  }

  private function colorChangeHandler(value:uint):void {

  }

  public function get argb():uint {
    return (0xff << 24) | selectedColor;
  }

  public function get hasSelectedColor():Boolean {
    return selectedIndex == 0;
  }

  public function get selectedColor():uint {
    return 9;
  }

  public function set selectedColor(value:uint):void {
  }

  public function set dataProvider(value:Object):void {

  }

  override protected function get primaryLaFKey():String {
    return "ColorPicker";
  }

  override public function get objectValue():Object {
    return 3;
  }

  override protected function synchronizeTitleAndSelectedItem(event:Event = null):void {

  }

  //	override public function commitProperties():void
  //	{
  //		super.commitProperties();
  //
  //		if (_menu == null)
  //		{
  //			var menu:Menu = new Menu();
  //			menu.items = new ArrayList(WebSafePalette.getList());
  //			this.menu = menu;
  //		}
  //	}
}
}