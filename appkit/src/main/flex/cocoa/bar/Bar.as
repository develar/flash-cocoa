package cocoa.bar {
import cocoa.AbstractComponent;
import cocoa.ListViewDataSource;
import cocoa.SegmentedControl;
import cocoa.pane.PaneViewDataSource;
import cocoa.ui;

import flash.utils.Dictionary;

import org.flyti.plexus.Injectable;

use namespace ui;

[Abstract]
public class Bar extends AbstractComponent implements Injectable {
  protected static const _skinParts:Dictionary = new Dictionary();
  _skinParts.segmentedControl = 0;
  override protected function get skinParts():Dictionary {
    return _skinParts;
  }

  ui var segmentedControl:SegmentedControl;

  public function Bar() {
    listenResourceChange();
  }

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
      PaneViewDataSource(dataSource).localize(resourceManager);
    }

    segmentedControl.dataSource = dataSource;
  }

  override protected function resourcesChanged():void {
    //if (items == null || segmentedControl == null) {
    //  return;
    //}
    //
    //var i:int;
    //var n:int = items.size;
    //for (i = 0; i < n; i++) {
    //  var item:LabeledItem = LabeledItem(items.getItemAt(i));
    //  if (item.title == null) {
    //    continue;
    //  }
    //
    //  var localizedLabel:String = itemToLabel(item);
    //  item.localizedTitle = localizedLabel;
    //  if (item is PaneItem) {
    //    var paneItem:PaneItem = PaneItem(item);
    //    if (paneItem.view != null && paneItem.view is TitledPane) {
    //      TitledPane(paneItem.view).title = localizedLabel;
    //    }
    //  }
    //
    //  var labelRenderer:IVisualElement = segmentedControl.getElementAt(i);
    //  if (labelRenderer is IItemRenderer) {
    //    IItemRenderer(labelRenderer).label = localizedLabel;
    //  }
    //}
  }
}
}