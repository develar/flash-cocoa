package cocoa.tableView {
import cocoa.CollectionViewDataSource;

public interface TableViewDataSource extends CollectionViewDataSource {
  function getObjectValue(column:TableColumn, rowIndex:int):Object;
  function getStringValue(column:TableColumn, rowIndex:int):String;
}
}