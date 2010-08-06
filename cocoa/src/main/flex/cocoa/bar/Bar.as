package cocoa.bar {
import cocoa.AbstractComponent;
import cocoa.SelectableDataGroup;
import cocoa.pane.LabeledItem;
import cocoa.pane.PaneItem;
import cocoa.pane.TitledPane;
import cocoa.ui;

import flash.utils.Dictionary;

import mx.core.IVisualElement;

import org.flyti.plexus.Injectable;
import org.flyti.util.List;

import spark.components.IItemRenderer;

use namespace ui;

[Abstract]
public class Bar extends AbstractComponent implements Injectable {
  protected static const _skinParts:Dictionary = new Dictionary();
  _skinParts.segmentedControl = 0;
  override protected function get skinParts():Dictionary {
    return _skinParts;
  }

  ui var segmentedControl:SelectableDataGroup;

  public function Bar() {
    listenResourceChange();
  }

  private var itemsChanged:Boolean;
  private var _items:List/*<PaneMetadata>*/;
  public function get items():List {
    return _items;
  }

  public function set items(value:List):void {
    if (value == items) {
      return;
    }

    _items = value;
    itemsChanged = true;
    invalidateProperties();
  }

  ui function segmentedControlAdded():void {

  }

  override public function commitProperties():void {
    if (itemsChanged) {
      itemsChanged = false;
      validateItems();
    }

    super.commitProperties();
  }

  protected function validateItems():void {
    itemsChanged = false;

    for each (var item:LabeledItem in items.iterator) {
      item.localizedLabel = itemToLabel(item);
    }

    segmentedControl.dataProvider = items;
  }

  override protected function resourcesChanged():void {
    if (items == null || segmentedControl == null) {
      return;
    }

    var i:int;
    var n:int = items.size;
    for (i = 0; i < n; i++) {
      var item:LabeledItem = LabeledItem(items.getItemAt(i));
      var localizedLabel:String = itemToLabel(item);
      item.localizedLabel = localizedLabel;
      if (item is PaneItem) {
        var paneItem:PaneItem = PaneItem(item);
        if (paneItem.view != null && paneItem.view is TitledPane) {
          TitledPane(paneItem.view).title = localizedLabel;
        }
      }

      var labelRenderer:IVisualElement = segmentedControl.getElementAt(i);
      if (labelRenderer is IItemRenderer) {
        IItemRenderer(labelRenderer).label = localizedLabel;
      }
    }
  }

  protected function itemToLabel(paneMetadata:LabeledItem):String {
    return resourceManager.getString(paneMetadata.label.bundleName, paneMetadata.label.resourceName);
  }
}
}