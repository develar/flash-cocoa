package cocoa.tableView {
import org.osflash.signals.ISignal;

public interface TableViewDataSource {
  function get rowCount():int;

  function getObjectValue(column:TableColumn, rowIndex:int):Object;
  function getStringValue(column:TableColumn, rowIndex:int):String;

  function get reset():ISignal;
}
}