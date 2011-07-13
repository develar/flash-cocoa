package cocoa.plaf.basic {
import cocoa.Container;

public class BoxSkin extends AbstractSkin {
  protected var contentGroup:Container;

  override protected function createChildren():void {
    super.createChildren();

    if (contentGroup == null) {
      contentGroup = new Container();
      component.uiPartAdded("contentGroup", contentGroup);
      addChild(contentGroup);
    }
  }

  override protected function measure():void {
    measuredMinWidth = contentGroup.minWidth;
    measuredMinHeight = contentGroup.minHeight;
    measuredWidth = contentGroup.getExplicitOrMeasuredWidth();
    measuredHeight = contentGroup.getExplicitOrMeasuredHeight();
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    contentGroup.setActualSize(w, h);
  }
}
}