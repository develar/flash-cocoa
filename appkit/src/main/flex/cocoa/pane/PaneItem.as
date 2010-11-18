package cocoa.pane {
import cocoa.Viewable;
import cocoa.resources.ResourceMetadata;

import mx.core.IFactory;

public class PaneItem extends LabeledItem {
  public var viewFactory:IFactory;
  public var view:Viewable;

  public function PaneItem(label:ResourceMetadata, viewFactory:IFactory) {
    super(label);

    this.viewFactory = viewFactory;
  }
}
}