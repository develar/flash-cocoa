package cocoa.plaf.basic {
public class CollectionViewSkin extends AbstractSkin {
  override protected function doInit():void {
    super.doInit();

    //ListHorizontalLayout(CollectionView(component).layout).init(CollectionView(component), this);
  }


  //override protected function measure():void {
  //  CollectionView(hostComponent).layout.measure();
  //}

  override protected function draw(w:int, h:int):void {
    //var collectionView:CollectionView = CollectionView(hostComponent);
    //collectionView.layout.updateDisplayList(this, w, h);
  }
}
}