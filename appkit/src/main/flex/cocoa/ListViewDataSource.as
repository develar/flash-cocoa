package cocoa {
public interface ListViewDataSource extends CollectionViewDataSource {
  function getObjectValue(itemIndex:int):Object;
  function getStringValue(itemIndex:int):String;
}
}
