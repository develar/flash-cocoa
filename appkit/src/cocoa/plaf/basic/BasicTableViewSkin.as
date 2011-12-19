package cocoa.plaf.basic {
import cocoa.Viewport;
import cocoa.plaf.TableViewSkin;
import cocoa.tableView.TableView;

import flash.display.Sprite;

public class BasicTableViewSkin extends AbstractCollectionViewSkin implements TableViewSkin {
  override protected function createDocumentView():Viewport {
    return new TableBody(TableView(component), laf);
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

  //override protected function doInit():void {
  //  super.doInit();
  //
  //  var interactorFactory:IFactory = getFactory("interactor", true);
  //  if (interactorFactory != null) {
  //    TableViewInteractor(interactorFactory.newInstance()).register(TableView(hostComponent));
  //  }
  //}
}
}