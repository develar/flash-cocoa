package cocoa.tableView {
public interface TableViewDataSource {
  function get rowCount():int;

  function getValue(column:TableColumn, rowIndex:int):Object;
  function getStringValue(column:TableColumn, rowIndex:int):String;
}
}
