package cocoa.tabView {
import cocoa.ListSelection;
import cocoa.SingleSelectionBar;
import cocoa.Viewable;
import cocoa.pane.PaneItem;
import cocoa.pane.TitledPane;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;
import cocoa.plaf.TabViewSkin;
import cocoa.ui;

import flash.events.Event;

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
    var newItem:PaneItem = PaneItem(items.getItemAt(event.newIndex));

    if (oldItem != null /* такое только в самом начале — нам не нужно при этом кидать событие */ && hasEventListener(CurrentPaneChangeEvent.CHANGING)) {
      dispatchEvent(new CurrentPaneChangeEvent(CurrentPaneChangeEvent.CHANGING, oldItem, newItem));
    }

    showPane(newItem);

    if (oldItem != null && hasEventListener(CurrentPaneChangeEvent.CHANGED)) {
      dispatchEvent(new CurrentPaneChangeEvent(CurrentPaneChangeEvent.CHANGED, oldItem, newItem));
    }
    
    if (hasEventListener("selectedItemChanged")) {
      dispatchEvent(new Event("selectedItemChanged"));
    }
  }

  protected function showPane(paneItem:PaneItem):void {
    if (paneItem.view == null) {
      createPaneView(paneItem);
    }

    TabViewSkin(skin).show(paneItem.view);
  }

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

  override public function createView(laf:LookAndFeel):Skin {
    if (_skinClass == null) {
      _skinClass = laf.getClass(_style == DEFAULT ? lafKey : (lafKey + ".borderless"));
    }
    return super.createView(laf);
  }
}
}