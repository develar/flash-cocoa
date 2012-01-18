package cocoa {
public class ListViewDataSourceImpl extends AbstractCollectionViewDataSource implements ListViewDataSource {
  private var source:Vector.<Object>;

  public function ListViewDataSourceImpl(source:Vector.<Object>) {
    this.source = source;
  }

  override public function get itemCount():int {
    return source.length;
  }

  public function getObjectValue(itemIndex:int):Object {
    return source[itemIndex];
  }

  public function getStringValue(itemIndex:int):String {
    return source.toString();
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
