package cocoa.tabView {
import cocoa.Toolbar;
import cocoa.View;
import cocoa.bar.SingleSelectionBar;
import cocoa.pane.PaneItem;
import cocoa.pane.TitledPane;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.TabViewSkin;
import cocoa.ui;

import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

use namespace ui;

public class TabView extends SingleSelectionBar {
  public static const DEFAULT:int = 0;
  public static const BORDERLESS:int = 1;

  private var _toolbar:Toolbar;
  public function get toolbar():Toolbar {
    return _toolbar;
  }

  public function set toolbar(value:Toolbar):void {
    if (_toolbar == value) {
      return;
    }

    var oldToolbar:Toolbar = _toolbar;
    _toolbar = value;
    if (skin != null) {
      TabViewSkin(skin).toolbarChanged(oldToolbar, _toolbar);
    }
  }

  override protected function segmentedControlSelectionChanged(oldItem:PaneItem, newItem:PaneItem, oldIndex:int, newIndex:int):void {
    if (_selectionChanging != null) {
      _selectionChanging.dispatch(oldItem, newItem);
    }

    if (newItem == null) {
      TabViewSkin(skin).hide();
    }
    else {
      showPane(newItem);
    }

    if (_selectionChanged != null) {
      _selectionChanged.dispatch(oldItem, newItem);
    }
  }

  protected var _selectionChanging:ISignal;
  public function get selectionChanging():ISignal {
    if (_selectionChanging == null) {
      _selectionChanging = new Signal();
    }
    return _selectionChanging;
  }

  protected var _selectionChanged:ISignal;
  public function get selectionChanged():ISignal {
    if (_selectionChanged == null) {
      _selectionChanged = new Signal();
    }
    return _selectionChanged;
  }

  protected function showPane(paneItem:PaneItem):void {
    if (paneItem.view == null) {
      createPaneView(paneItem);
    }

    TabViewSkin(skin).show(paneItem.view);
  }

  //noinspection JSMethodCanBeStatic
  protected function createPaneView(paneItem:PaneItem):void {
    assert(paneItem.view == null);

    var pane:View = paneItem.viewFactory.newInstance();
    paneItem.view = pane;

    if (pane is TitledPane) {
      TitledPane(pane).title = paneItem.localizedTitle;
    }
  }

  override protected function get primaryLaFKey():String {
    return "TabView";
  }

  private var _style:int = DEFAULT;
  public function set style(value:int):void {
    _style = value;
  }

  override protected function preSkinCreate(laf:LookAndFeel):void {
    if (_skinClass == null) {
      _skinClass = laf.getClass(_style == DEFAULT ? lafKey : (lafKey + ".borderless"));
    }
  }
}
}