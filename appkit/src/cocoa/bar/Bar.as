package cocoa.bar {
import cocoa.ObjectBackedSkinnableView;
import cocoa.ListViewDataSource;
import cocoa.SegmentedControl;
import cocoa.pane.PaneViewDataSource;
import cocoa.resources.ResourceManager;
import cocoa.ui;

import flash.utils.Dictionary;

import org.flyti.plexus.Injectable;

use namespace ui;

[Abstract]
public class Bar extends ObjectBackedSkinnableView implements Injectable {
  protected static const _skinParts:Dictionary = new Dictionary();
  _skinParts.segmentedControl = 0;
  override protected function get skinParts():Dictionary {
    return _skinParts;
  }

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

  override public function commitProperties():void {
    if (dataSourceChanged) {
      dataSourceChanged = false;
      validateItems();
    }

    super.commitProperties();
  }

  protected function validateItems():void {
    if (dataSource is PaneViewDataSource) {
      PaneViewDataSource(dataSource).localize(ResourceManager.instance);
    }
  }
}
}