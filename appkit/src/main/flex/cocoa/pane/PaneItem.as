package cocoa.pane {
import cocoa.Viewable;
import cocoa.resources.ResourceMetadata;

import mx.core.IFactory;

public class PaneItem extends LabeledItem {
  public var viewFactory:IFactory;
  public var view:Viewable;

  public function PaneItem(title:ResourceMetadata, viewFactory:IFactory) {
    super(title);

    this.viewFactory = viewFactory;
  }

  public static function create(viewFactory:IFactory, localizedTitle:String):PaneItem {
    var paneItem:PaneItem = new PaneItem(null, viewFactory);
    paneItem.localizedTitle = localizedTitle;
    return paneItem;
  }
}
}