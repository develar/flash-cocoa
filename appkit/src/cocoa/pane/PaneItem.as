package cocoa.pane {
import cocoa.View;
import cocoa.resources.ResourceMetadata;

import mx.core.IFactory;

public class PaneItem extends LabeledItem {
  public var viewFactory:IFactory;
  public var view:View;

  public function PaneItem(title:ResourceMetadata, viewFactory:IFactory) {
    super(title);

    this.viewFactory = viewFactory;
  }

  public static function create(localizedTitle:String, viewFactory:IFactory):PaneItem {
    var paneItem:PaneItem = new PaneItem(null, viewFactory);
    paneItem.localizedTitle = localizedTitle;
    return paneItem;
  }
}
}