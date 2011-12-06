package cocoa.toolWindow {
import cocoa.ContentView;
import cocoa.ListViewModifiableDataSource;
import cocoa.Panel;
import cocoa.SegmentedControl;
import cocoa.pane.PaneItem;
import cocoa.pane.PaneViewDataSource;
import cocoa.ui;

import flash.errors.IllegalOperationError;

import net.miginfocom.layout.CC;
import net.miginfocom.layout.MigConstants;

use namespace ui;

public class ToolWindowManager {
  private var toolWindows:Vector.<SegmentedControl> = new Vector.<SegmentedControl>(4, true);

  public function registerToolWindow(item:PaneItem, side:int):void {
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
      dataSource = new PaneViewDataSource(new Vector.<PaneItem>());
      tabBar.dataSource = dataSource;

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
  }

  private var _container:ContentView;
  public function set container(value:ContentView):void {
    _container = value;
  }

  private var pendingSelectedIndices:Vector.<int>;

  public function set selectedIndices(value:Vector.<int>):void {
    if (segmentedControl == null) {
      pendingSelectedIndices = value;
    }
    else {
      segmentedControl.selectedIndices = value;
    }
  }

  override ui function segmentedControlAdded():void {
    super.segmentedControlAdded();
    segmentedControl.selectionChanged.add(paneLabelBarSelectionChanged);
  }

  private function paneLabelBarSelectionChanged(added:Vector.<int>, removed:Vector.<int>):void {
    if (removed != null) {
      showPanes(removed, false);
    }
    if (added != null) {
      showPanes(added, true);
    }

    if (collapsed != segmentedControl.isSelectionEmpty) {
      collapsed = !collapsed;

      skin.invalidateSize();

      paneGroup.includeInLayout = !collapsed;
    }
  }

  override public function commitProperties():void {
    super.commitProperties();

    if (pendingSelectedIndices != null) {
      segmentedControl.selectedIndices = pendingSelectedIndices;
      pendingSelectedIndices = null;
    }
  }

  private function showPanes(indices:Vector.<int>, show:Boolean):void {
    for each (var index:int in indices) {
      showPane(PaneItem(dataSource.getObjectValue(index)), show);
    }
  }

  private function showPane(paneMetadata:PaneItem, show:Boolean):void {
    if (paneMetadata.view == null) {
      createPaneView(paneMetadata);
    }
    Panel(paneMetadata.view).hidden = !show;
  }

  private function createPaneView(paneMetadata:PaneItem):void {
    assert(paneMetadata.view == null);

    var pane:Panel = paneMetadata.viewFactory.newInstance();
    paneMetadata.view = pane;

    pane.title = paneMetadata.localizedTitle;

    pane.paneHid.add(hidePaneHandler);
    pane.sideHid.add(hideSideHandler);

    if (paneGroup != null) {
      paneGroup.addSubview(pane);
    }
  }

  private function hidePaneHandler(pane:Panel):void {
    assert(!pane.hidden);
    segmentedControl.setSelected(paneGroup.getSubviewIndex(pane), false);
  }

  private function hideSideHandler():void {
    selectedIndices = null;
  }

  override protected function get primaryLaFKey():String {
    return "Sidebar";
  }
}
}