package cocoa {
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.TitledComponentSkin;
import cocoa.plaf.basic.PopUpMenuInteractor;

import flash.events.Event;

import spark.utils.LabelUtil;

use namespace ui;

/**
 * @see http://developer.apple.com/Mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGControls/XHIGControls.html#//apple_ref/doc/uid/TP30000359-TPXREF132
 */
[DefaultProperty("menu")]
public class PopUpButton extends AbstractControl implements LookAndFeelProvider {
  private var _laf:LookAndFeel;
  public function get laf():LookAndFeel {
    return _laf;
  }

  public function set laf(value:LookAndFeel):void {
    _laf = value;
  }

  protected var _menu:Menu;
  public function get menu():Menu {
    return _menu;
  }

  public function set menu(value:Menu):void {
    if (value != _menu) {
      if (_menu != null) {
        _menu.removeEventListener(Event.CHANGE, synchronizeTitleAndSelectedItem);
      }

      _menu = value;
      _menu.addEventListener(Event.CHANGE, synchronizeTitleAndSelectedItem);

      if (skin != null) {
        synchronizeTitleAndSelectedItem();
      }
    }
  }

  override protected function preSkinCreate(laf:LookAndFeel):void {
    _laf = laf;
  }

  public function get selectedItem():Object {
    return _menu.getItemAt(selectedIndex);
  }

  public function set selectedItem(value:Object):void {
    if (value != null) {
      selectedIndex = _menu.getItemIndex(value);
    }
    else if (_state != CellState.MIXED) {
      state = CellState.MIXED;
    }
  }

  private var _selectedIndex:int = 0;
  public function get selectedIndex():int {
    return _selectedIndex;
  }

  public function set selectedIndex(value:int):void {
    if (_state == CellState.MIXED) {
      _state = CellState.OFF;
    }
    setSelectedIndex(value, false);
  }

  public function setSelectedIndex(value:int, callUserInitiatedActionHandler:Boolean = true):void {
    if (value == selectedIndex) {
      return;
    }

    _selectedIndex = value;
    if (callUserInitiatedActionHandler && _action != null) {
      // иначе если у некого компонента, что использует pop up menu уже invalid properties,
      // то вызов invalidateProperties инициированнный вызовом action не приведет к commitProperties
      //				AbstractView(skin).callLater(_action);
      _action();
    }

    if (_menu != null && skin != null) {
      synchronizeTitleAndSelectedItem();
    }
  }

  override protected function skinAttached():void {
    super.skinAttached();

    PopUpMenuInteractor(laf.getFactory(lafKey + ".menuController", false).newInstance()).register(this);
    if (_menu != null) {
      synchronizeTitleAndSelectedItem();
    }
  }

  protected function synchronizeTitleAndSelectedItem(event:Event = null):void {
    var item:Object = selectedItem;
    TitledComponentSkin(skin).title = item == null ? null : LabelUtil.itemToLabel(item, null, _menu.labelFunction);
  }

  override protected function get primaryLaFKey():String {
    return "PopUpButton";
  }

  /**
   * selected item
   */
  override public function get objectValue():Object {
    return selectedItem;
  }

  override public function set objectValue(value:Object):void {
    selectedItem = value;
  }
}
}