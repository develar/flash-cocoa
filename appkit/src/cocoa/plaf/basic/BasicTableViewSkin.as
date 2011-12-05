package cocoa.plaf.basic {
import cocoa.plaf.TableViewSkin;
import cocoa.tableView.TableView;

import flash.display.Sprite;

import spark.core.IViewport;

public class BasicTableViewSkin extends AbstractCollectionViewSkin implements TableViewSkin {
  override protected function createDocumentView():IViewport {
    return new TableBody(TableView(hostComponent), laf);
  }

  public function get bodyHitArea():Sprite {
    return Sprite(documentView);
  }

  public function getColumnIndexAt(x:Number):int {
    return TableBody(documentView).getColumnIndexAt(x);
  }

  public function getRowIndexAt(y:Number):int {
    return TableBody(documentView).getRowIndexAt(y);
  }
}
}