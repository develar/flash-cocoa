package cocoa.colorPicker {
import cocoa.Menu;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;
import cocoa.resources.ResourceManager;
import cocoa.ui;

import mx.core.IFactory;

import org.flyti.util.ArrayList;

use namespace ui;

[ResourceBundle("ColorPickerMenu")]
public class ColorPickerMenu extends Menu {
  private static const PANEL:int = 1;

  private var laf:LookAndFeel;

  private static var menu:ColorPickerMenu;
  private static var menuWithoutNoColor:ColorPickerMenu;

  public static function create():ColorPickerMenu {
    if (menu == null) {
      menu = new ColorPickerMenu();
      menu._items = new ArrayList(new <Object>[PANEL, "noColor"]);
      menu.labelFunction = menu.stringItemLabelFunction;
    }

    return menu;
  }

  public static function createWithoutNoColor():ColorPickerMenu {
    if (menuWithoutNoColor == null) {
      menuWithoutNoColor = new ColorPickerMenu();
      menuWithoutNoColor._items = new ArrayList(new <Object>[PANEL]);
    }

    return menuWithoutNoColor;
  }

  public function get noColorItemIndex():int {
    return 1;
  }

  public function get colorItemIndex():int {
    return 0;
  }

  private var _colorChangeHandler:Function;
  public function set colorChangeHandler(value:Function):void {
    _colorChangeHandler = value;
  }

  private function colorChangeProxyHandler(value:int):void {
    _colorChangeHandler(value);
  }

  override ui function itemGroupAdded():void {
    super.itemGroupAdded();

    itemGroup.itemRendererFunction = itemRendererFunction;
    itemGroup.dataProvider = _items;
  }

  override public function createView(laf:LookAndFeel):Skin {
    this.laf = laf;

    return super.createView(laf);
  }

  private function itemRendererFunction(item:int):IFactory {
    switch (item) {
      case PANEL:
      {
        return new SwatchPanelFactory(laf, colorChangeProxyHandler);
      }
        break;

      default: return itemGroup.itemRenderer;
      //			default: throw new ArgumentError();
    }
  }

  private function stringItemLabelFunction(item:Object):String {
    return ResourceManager.instance.getString("ColorPickerMenu", String(item));
  }
}
}

import cocoa.PushButton;
import cocoa.colorPicker.MenuSwatchItemRenderer;
import cocoa.plaf.LookAndFeel;

import mx.core.IFactory;

class SwatchPanelFactory implements IFactory {
  private var laf:LookAndFeel;
  private var colorChangeHandler:Function;

  public function SwatchPanelFactory(laf:LookAndFeel, colorChangeHandler:Function) {
    this.laf = laf;
    this.colorChangeHandler = colorChangeHandler;
  }

  public function newInstance():* {
    var swatchPanel:MenuSwatchItemRenderer = new MenuSwatchItemRenderer();
    swatchPanel.laf = laf;
    swatchPanel.changeColorHandler = colorChangeHandler;
    swatchPanel.colorList = WebSafePalette.getList();
    return swatchPanel;
  }
}

class ButtonFactory implements IFactory {
  private var laf:LookAndFeel;

  public function ButtonFactory(laf:LookAndFeel) {
    this.laf = laf;
  }

  public function newInstance():* {
    var button:PushButton = new PushButton();
    button.title = "No Color";
    return button.createView(laf);
  }
}

class WebSafePalette {
  public static function getList():Vector.<uint> {
//    var list:Vector.<uint> = new Vector.<uint>(240, true);
    var list:Vector.<uint> = new Vector.<uint>(228, true);

    const spacer:uint = 0xffffff;
    var c1:Vector.<uint> = new <uint>[0x000000, 0x333333, 0x666666, 0x999999, 0xcccccc, 0xffffff, 0xff0000, 0x00ff00, 0x0000ff, 0xffff00, 0x00ffff, 0xff00ff];

    var ra:Vector.<String> = new <String>[ "00", "00", "00", "00", "00", "00",
      "33", "33", "33", "33", "33", "33",
      "66", "66", "66", "66", "66", "66" ];
    ra.fixed = true;

    var rb:Vector.<String> = new <String>[ "99", "99", "99", "99", "99", "99",
      "CC", "CC", "CC", "CC", "CC", "CC",
      "FF", "FF", "FF", "FF", "FF", "FF" ];
    rb.fixed = true;

    var g:Vector.<String> = new <String>[ "00", "33", "66", "99", "CC", "FF",
      "00", "33", "66", "99", "CC", "FF",
      "00", "33", "66", "99", "CC", "FF" ];
    g.fixed = true;

    var b:Vector.<String> = new <String>[ "00", "33", "66", "99", "CC", "FF",
      "00", "33", "66", "99", "CC", "FF" ];
    b.fixed = true;

    var index:int = 0;
    for (var x:int = 0; x < 12; x++) {
      for (var j:int = 0; j < 20; j++) {
        var item:uint;
        if (j == 0) {
          item = c1[x];
        }
        else if (j == 1) {
//          item = spacer;
          continue;
        }
        else {
          item = uint("0x" + (x < 6 ? ra[j - 2] : rb[j - 2]) + g[j - 2] + b[x]);
        }

        list[index++] = item;
      }
    }

    return list;
  }
}