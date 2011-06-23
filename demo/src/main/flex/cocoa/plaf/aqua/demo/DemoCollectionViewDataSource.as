package cocoa.plaf.aqua.demo {
import cocoa.CollectionViewDataSource;
import cocoa.tableView.AbstractCollectionViewDataSource;

public class DemoCollectionViewDataSource extends AbstractCollectionViewDataSource implements CollectionViewDataSource {
  private var source:Vector.<String> = new <String>["First", "Second", "Third"];
  private var source2:Vector.<String> = new <String>["Lysandra", "Mallory", "Garth"];

  private var data:Vector.<String> = source;

  public function changeData():void {
    data = data == source ? source2 : source;
    sourceItemCounter = data.length;
    reset.dispatch();
  }

  public function changeDataToNull():void {
    data = new <String>[];
    sourceItemCounter = 0;
    reset.dispatch();
  }

  public function DemoCollectionViewDataSource() {
    sourceItemCounter = data.length;
  }

  public function getObjectValue(itemIndex:int):Object {
    return null;
  }

  public function getStringValue(itemIndex:int):String {
    return data[itemIndex];
  }
}
}
