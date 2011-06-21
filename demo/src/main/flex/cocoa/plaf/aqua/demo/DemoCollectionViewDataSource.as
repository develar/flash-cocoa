package cocoa.plaf.aqua.demo {
import cocoa.CollectionViewDataSource;
import cocoa.tableView.AbstractCollectionViewDataSource;

public class DemoCollectionViewDataSource extends AbstractCollectionViewDataSource implements CollectionViewDataSource {
  private var source:Vector.<String> = new <String>["First", "Second", "Third"];

  public function DemoCollectionViewDataSource() {
    sourceItemCounter = source.length;
  }

  public function getObjectValue(itemIndex:int):Object {
    return null;
  }

  public function getStringValue(itemIndex:int):String {
    return source[itemIndex];
  }
}
}
