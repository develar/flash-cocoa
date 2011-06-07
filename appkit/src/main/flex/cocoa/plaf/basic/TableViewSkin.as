package cocoa.plaf.basic {
import cocoa.tableView.TableView;

import spark.core.IViewport;

public class TableViewSkin extends AbstractCollectionViewSkin {
  override protected function createDocumentView():IViewport {
    return new TableBody(TableView(component), laf);
  }
}
}