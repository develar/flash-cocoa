package cocoa.pane {
import cocoa.AbstractCollectionViewDataSource;
import cocoa.ListViewModifiableDataSource;
import cocoa.resources.ResourceManager;
import cocoa.resources.ResourceMetadata;

public class PaneViewDataSource extends AbstractCollectionViewDataSource implements ListViewModifiableDataSource {
  private var source:Vector.<PaneItem>;

  public function PaneViewDataSource(source:Vector.<PaneItem>) {
    this.source = source;
  }

  public function localize(resourceManager:ResourceManager):void {
    var title:ResourceMetadata;
    for each (var item:PaneItem in source) {
      if ((title = item.title) != null) {
        item.localizedTitle = resourceManager.getString(title.bundleName, title.resourceName);
      }
    }
  }

  public function getObjectValue(itemIndex:int):Object {
    return source[itemIndex];
  }

  public function getStringValue(itemIndex:int):String {
    return source[itemIndex].localizedTitle;
  }

  override public function get itemCount():int {
    return source.length;
  }

  override public function addItemAt(item:Object, index:int):void {
    source.splice(index, 0, item);
    if (_itemAdded != null) {
      _itemAdded.dispatch(item, index);
    }
  }

  public function removeItem(item:Object):void {
    removeItemAt(source.indexOf(item));
  }

  public function removeItemAt(index:int):Object {
    var removedItem:Object = source.splice(index, 1)[0];
    if (_itemRemoved != null) {
      _itemRemoved.dispatch(removedItem, index);
    }
    return removedItem;
  }

  public function getItemIndex(object:Object):int {
    return source.indexOf(object);
  }

  public function clear():void {
    source.length = 0;
    if (_reset != null) {
      _reset.dispatch();
    }
  }
}
}
