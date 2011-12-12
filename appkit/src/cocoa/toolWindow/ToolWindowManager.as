package cocoa.toolWindow {
import cocoa.ListViewDataSource;
import cocoa.ListViewModifiableDataSource;
import cocoa.Panel;
import cocoa.RootContentView;
import cocoa.SegmentedControl;
import cocoa.SelectionMode;
import cocoa.pane.PaneItem;
import cocoa.pane.PaneViewDataSource;
import cocoa.resources.ResourceManager;
import cocoa.ui;

import flash.errors.IllegalOperationError;

import net.miginfocom.layout.CC;
import net.miginfocom.layout.MigConstants;

use namespace ui;

public class ToolWindowManager {
  private var toolWindows:Vector.<SegmentedControl> = new Vector.<SegmentedControl>(4, true);

  public function registerToolWindow(item:PaneItem, side:int, opened:Boolean = false):void {
    var tabBar:SegmentedControl;
    for each (tabBar in toolWindows) {
      if (tabBar != null && tabBar.dataSource.getItemIndex(item) != -1) {
        throw new IllegalOperationError("item already registered");
      }
    }
    
    tabBar = toolWindows[side];
    var dataSource:ListViewModifiableDataSource;
    if (tabBar == null) {
      tabBar = new SegmentedControl();
      tabBar.mode = SelectionMode.ANY;
      tabBar.lafKey = "ToolWindowManager.tabBar";

      dataSource = new PaneViewDataSource(new Vector.<PaneItem>());
      tabBar.dataSource = dataSource;

      tabBar.selectionChanged.add(paneLabelBarSelectionChanged);

      var cc:CC = new CC();
      cc.cellX = side == MigConstants.RIGHT ? 4 : 0;
      cc.cellY = side == MigConstants.LEFT || side == MigConstants.RIGHT ? 1 : side == MigConstants.TOP ? 0 : 3;
      tabBar.constraints = cc;
      toolWindows[side] = tabBar;

      if (_container != null) {
        _container.addSubview(tabBar);
      }
    }
    else {
      dataSource = ListViewModifiableDataSource(tabBar.dataSource);
    }

    dataSource.addItem(item);
    if (opened) {
      tabBar.setSelected(dataSource.itemCount - 1, true);
    }
  }

  private var _container:RootContentView;
  public function set container(value:RootContentView):void {
    _container = value;

    for each (var tabBar:SegmentedControl in toolWindows) {
      if (tabBar != null) {
        _container.addSubview(tabBar);
      }
    }
  }

  private function paneLabelBarSelectionChanged(added:Vector.<int>, removed:Vector.<int>):void {
    // todo side
    var side:int = MigConstants.RIGHT;
    if (removed != null) {
      showPanes(removed, false, side);
    }
    if (added != null) {
      showPanes(added, true, side);
    }
  }

  private function showPanes(indices:Vector.<int>, show:Boolean, side:int):void {
    var dataSource:ListViewDataSource = toolWindows[side].dataSource;
    for each (var index:int in indices) {
      showPane(PaneItem(dataSource.getObjectValue(index)), show, side);
    }
  }

  private function showPane(paneItem:PaneItem, show:Boolean, side:int):void {
    if (paneItem.view == null) {
      createPaneView(paneItem, side);
    }
    Panel(paneItem.view).visible = show;
  }

  private function createPaneView(paneItem:PaneItem, side:int):void {
    assert(paneItem.view == null);

    var pane:Panel = paneItem.viewFactory.newInstance();
    paneItem.view = pane;

    if (paneItem.localizedTitle == null) {
      paneItem.localizedTitle = ResourceManager.instance.getStringByRM(paneItem.title);
    }
    pane.title = paneItem.localizedTitle;
    
    var cc:CC = new CC();
    cc.cellX = side == MigConstants.RIGHT ? 3 : 1;
    cc.cellY = side == MigConstants.LEFT || side == MigConstants.RIGHT ? 1 : side == MigConstants.TOP ? 1 : 2;
    pane.constraints = cc;

    //pane.paneHid.add(hidePaneHandler);
    //pane.sideHid.add(hideSideHandler);

    if (_container != null) {
      _container.addSubview(pane);
    }
  }

  //private function hidePaneHandler(pane:Panel):void {
  //  assert(!pane.hidden);
  //  segmentedControl.setSelected(paneGroup.getSubviewIndex(pane), false);
  //}
  //
  //private function hideSideHandler():void {
  //  selectedIndices = null;
  //}
}
}