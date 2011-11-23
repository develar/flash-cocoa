package cocoa.pane {
import cocoa.resources.ResourceMetadata;

[Abstract]
public class LabeledItem {
  public var title:ResourceMetadata;
  public var localizedTitle:String;

  public function LabeledItem(title:ResourceMetadata) {
    this.title = title;
  }

  public function toString():String {
    return localizedTitle;
  }
}
}