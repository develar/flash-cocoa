package cocoa.plaf.aqua.demo {
import cocoa.plaf.LookAndFeel;
import cocoa.tableView.TableColumn;
import cocoa.tableView.TableViewDataSource;

import flash.errors.IllegalOperationError;

public class DemoTableViewDataSource implements TableViewDataSource {
  private var data:Vector.<TestItem> = new <TestItem>[new TestItem("wfeg wqd we", "fewrqcwdscawc cwd"), new TestItem("sdgas efv ", "sdfe aew c"), new TestItem("cwscvafe4 3q4rc", "csedg hretw")];
  private var laf:LookAndFeel;

  public function DemoTableViewDataSource(laf:LookAndFeel) {
    this.laf = laf;
  }

  public function get numberOfRows():int {
    return data.length;
  }

  public function getValue(column:TableColumn, rowIndex:int):Object {
    throw new IllegalOperationError();
  }

  public function getStringValue(column:TableColumn, rowIndex:int):String {
    return data[rowIndex][column.dataField];
  }
}
}

class TestItem {
  public var a:String;
  public var b:String;

  public function TestItem(a:String, b:String) {
    this.a = a;
    this.b = b;
  }
}