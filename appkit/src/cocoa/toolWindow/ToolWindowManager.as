package cocoa.toolWindow {
import cocoa.ListViewDataSource;
import cocoa.ListViewModifiableDataSource;
import cocoa.MigLayout;
import cocoa.Panel;
import cocoa.RootContentView;
import cocoa.SegmentedControl;
import cocoa.SelectionMode;
import cocoa.pane.PaneItem;
import cocoa.pane.PaneViewDataSource;
import cocoa.resources.ResourceManager;
import cocoa.ui;

import flash.errors.IllegalOperationError;

import net.miginfocom.layout.BoundSize;
import net.miginfocom.layout.CC;
import net.miginfocom.layout.CellConstraint;
import net.miginfocom.layout.LC;
import net.miginfocom.layout.MigConstants;
import net.miginfocom.layout.UnitValue;

use namespace ui;

public class ToolWindowManager {
  private static const SET_COUNT:int = 5;

  private const columnConstraints:Vector.<CellConstraint> = new Vector.<CellConstraint>(SET_COUNT, true);
  private var toolWindows:Vector.<SegmentedControl> = new Vector.<SegmentedControl>(4, true);

  public function registerToolWindow(item:PaneItem, side:int, opened:Boolean = false):void {
    var tabBar:SegmentedControl;
    for each (tabBar in toolWindows) {
      if (tabBar != null && tabBar.dataSource.getItemIndex(item) != -1) {
        throw new IllegalOperationError("item already registered");
      }
    }

    if (item.localizedTitle == null && item.title != null) {
      item.localizedTitle = ResourceManager.instance.getStringByRM(item.title);
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
      cc.vertical.grow = 100;
      cc.cellX = side == MigConstants.RIGHT ? 4 : 0;
      cc.cellY = side == MigConstants.LEFT || side == MigConstants.RIGHT ? 2 : side == MigConstants.TOP ? 0 : 4;
      tabBar.constraints = cc;
      toolWindows[side] = tabBar;

      if (_container != null) {
        _container.addSubview(tabBar);
      }

      //columnConstraints[cc.cellX].size = null;
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
    assert(_container == null);
    _container = value;

    for each (var tabBar:SegmentedControl in toolWindows) {
      if (tabBar != null) {
        _container.addSubview(tabBar);
      }
    }

    var layout:MigLayout = new MigLayout();
    var i:int = 0;
    for (; i < SET_COUNT; i++) {
      columnConstraints[i] = createDimConstraint(i);
    }

    var rowConstraints:Vector.<CellConstraint> = new Vector.<CellConstraint>(SET_COUNT, true);
    i = 0;
    for (; i < SET_COUNT; i++) {
      rowConstraints[i] = createDimConstraint(i);
    }

    var lc:LC = new LC();
    lc.hideMode = 3;
    var insets:Vector.<UnitValue> = new Vector.<UnitValue>(4);
    for (i = 0; i < 4; i++) {
      insets[i] = UnitValue.ZERO;
    }
    lc.insets = insets;

    lc.gridGapX = BoundSize.ZERO_PIXEL;
    lc.gridGapY = BoundSize.ZERO_PIXEL;

    layout.setLayoutConstraints(lc);
    layout.setColumnConstraints(columnConstraints);
    layout.setRowConstraints(rowConstraints);
    _container.layout = layout;
  }

  private static function createDimConstraint(index:int):CellConstraint {
    var constraint:CellConstraint = new CellConstraint();
    if (index == 2) {
      constraint.grow = 100; // ResizeConstraint.WEIGHT_100
    }
    else {
      // cell for panel has zero size by default
      if (index == 1 || index == 3) {
        constraint.size = BoundSize.ZERO_PIXEL;
      }
      constraint.fill = true;
    }

    return constraint;
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

    if (show) {
      var columnConstraint:CellConstraint = columnConstraints[sideToColumn(side)];
      if (columnConstraint.size == BoundSize.ZERO_PIXEL) {
        columnConstraint.size = BoundSize.createSame(new UnitValue(0.33 * _container.screenWidth));
      }
    }
    else if (toolWindows[side].isSelectionEmpty) {
      columnConstraints[sideToColumn(side)].size = BoundSize.ZERO_PIXEL;
    }
  }

  private static function sideToColumn(side:int):int {
    return side == MigConstants.RIGHT ? 3 : 1;
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
    cc.cellX = sideToColumn(side);
    cc.cellY = side == MigConstants.LEFT || side == MigConstants.RIGHT ? 2 : side == MigConstants.TOP ? 1 : 3;
    pane.constraints = cc;

    columnConstraints[cc.cellX].size = BoundSize.createSame(new UnitValue(0.33 * _container.screenWidth));

    //pane.paneHid.add(hidePaneHandler);
    //pane.sideHid.add(hideSideHandler);

    _container.addSubview(pane);
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