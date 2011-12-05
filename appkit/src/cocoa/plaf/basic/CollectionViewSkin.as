package cocoa.plaf.basic {
import cocoa.CollectionView;
import cocoa.plaf.Skin;

import flash.display.DisplayObject;

public class CollectionViewSkin extends AbstractSkin {
  override protected function createChildren():void {
    super.createChildren();

    //ListHorizontalLayout(CollectionView(component).layout).init(CollectionView(component), this);
  }

  override public function addChild(child:DisplayObject):DisplayObject {
    child is Skin ? super.addChild(child) : addChild(child);
    return child;
  }

  override public function removeChild(child:DisplayObject):DisplayObject {
    child is Skin ? super.removeChild(child) : removeChild(child);
    return child;
  }

  override protected function measure():void {
    CollectionView(hostComponent).layout.measure();
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    var collectionView:CollectionView = CollectionView(hostComponent);
    //collectionView.layout.updateDisplayList(this, w, h);
  }
}
}