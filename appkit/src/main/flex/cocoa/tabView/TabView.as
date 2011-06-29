package cocoa.tabView {
import cocoa.ListSelection;
import cocoa.SingleSelectionBar;
import cocoa.Viewable;
import cocoa.pane.PaneItem;
import cocoa.pane.TitledPane;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.TabViewSkin;
import cocoa.ui;

import flash.events.Event;

import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

import spark.events.IndexChangeEvent;

use namespace ui;

public class TabView extends SingleSelectionBar {
  public static const DEFAULT:int = 0;
  public static const BORDERLESS:int = 1;

  override protected function itemGroupSelectionChangeHandler(event:IndexChangeEvent):void {
    var oldItem:PaneItem;
    //  при удалении элемента, придет событие с его старым индексом, если он был ранее выделен
    if (event.oldIndex != ListSelection.NO_SELECTION && event.oldIndex < items.size) {
      oldItem = PaneItem(items.getItemAt(event.oldIndex));
    }
    var newItem:PaneItem = event.newIndex == -1 ? null : PaneItem(items.getItemAt(event.newIndex));

    if (oldItem != null /* такое только в самом начале — нам не нужно при этом кидать событие */ && _selectionChanging != null) {
      _selectionChanging.dispatch(oldItem, newItem);
    }

    if (newItem == null) {
      TabViewSkin(skin).hide();
    }
    else {
      showPane(newItem);
    }

    if (oldItem != null && _selectionChanged != null) {
      _selectionChanged.dispatch(oldItem, newItem);
    }
    
    if (hasEventListener("selectedItemChanged")) {
      dispatchEvent(new Event("selectedItemChanged"));
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

    var pane:Viewable = paneItem.viewFactory.newInstance();
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