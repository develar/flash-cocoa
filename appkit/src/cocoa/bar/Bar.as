package cocoa.bar {
import cocoa.AbstractSkinnableView;
import cocoa.ListViewDataSource;
import cocoa.SegmentedControl;
import cocoa.pane.PaneViewDataSource;
import cocoa.resources.ResourceManager;
import cocoa.ui;

import org.flyti.plexus.Injectable;

use namespace ui;

[Abstract]
public class Bar extends AbstractSkinnableView implements Injectable {
  ui var segmentedControl:SegmentedControl;

  private var dataSourceChanged:Boolean;
  private var _dataSource:ListViewDataSource;
  public function get dataSource():ListViewDataSource {
    return _dataSource;
  }

  public function set dataSource(value:ListViewDataSource):void {
    if (_dataSource == value) {
      return;
    }

    _dataSource = value;
    dataSourceChanged = true;
    invalidateProperties();
  }

  ui function segmentedControlAdded():void {
    if (_dataSource != null) {
      segmentedControl.dataSource = dataSource;
    }
  }

  //override public function commitProperties():void {
  //  if (dataSourceChanged) {
  //    dataSourceChanged = false;
  //    validateItems();
  //  }
  //
  //  super.commitProperties();
  //}

  protected function validateItems():void {
    if (dataSource is PaneViewDataSource) {
      PaneViewDataSource(dataSource).localize(ResourceManager.instance);
    }
  }
}
}