package cocoa.demo {
import cocoa.ListViewDataSource;
import cocoa.AbstractCollectionViewDataSource;

public class DemoCollectionViewDataSource extends AbstractCollectionViewDataSource implements ListViewDataSource {
  private var source:Vector.<String> = new <String>["First", "Second", "Third"];
  private var source2:Vector.<String> = new <String>["Lysandra", "Mallory", "Garth"];

  private var data:Vector.<String> = source;

  public function changeData():void {
    data = data == source ? source2 : source;
    _itemCount = data.length;
    reset.dispatch();
  }

  public function changeDataToNull():void {
    data = new <String>[];
    _itemCount = 0;
    reset.dispatch();
  }

  public function DemoCollectionViewDataSource() {
    _itemCount = data.length;
  }

  public function getObjectValue(itemIndex:int):Object {
    return null;
  }

  public function getStringValue(itemIndex:int):String {
    return data[itemIndex];
  }

  public function getItemIndex(object:Object):int {
    return data.indexOf(object);
  }
}
}
