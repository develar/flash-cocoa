package cocoa.plaf.basic {
import cocoa.MenuItem;
import cocoa.plaf.TextFormatId;

import flash.display.Graphics;

public class MenuItemRenderer extends LabeledItemRenderer {
  public function get labelLeftMargin():Number {
    return border.contentInsets.left;
  }

  override public function get lafPrefix():String {
    return "MenuItem";
  }

  protected var menuItem:Object;

  override public function get data():Object {
    return menuItem;
  }

  override public function set data(value:Object):void {
    var isSeparatorItem:Boolean = false;
    menuItem = value;
    if (menuItem is MenuItem) {
      enabled = mouseEnabled = MenuItem(menuItem).enabled;
      isSeparatorItem = MenuItem(menuItem).isSeparatorItem;
    }
    else {
      enabled = mouseEnabled = true;
    }

    border = getBorder(isSeparatorItem ? "separatorBorder" : "b");

    invalidateSize();
    invalidateDisplayList();
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    const highlighted:Boolean = (state & HIGHLIGHTED) != 0;
    if (!(menuItem is MenuItem && MenuItem(menuItem).isSeparatorItem)) {
      border = getBorder(highlighted ? "b.highlighted" : "b");

      labelHelper.textFormat = _laf.getTextFormat(highlighted ? TextFormatId.MENU_HIGHLIGHTED : TextFormatId.MENU);
      labelHelper.validate();
      labelHelper.moveByInsets(h, border.contentInsets);
    }

    var g:Graphics = graphics;
    g.clear();

    border.draw(this, g, w, h);
  }
}
}