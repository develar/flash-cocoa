package cocoa.plaf.basic {
import cocoa.Container;
import cocoa.SkinnableView;
import cocoa.plaf.Skin;

public class BoxSkin extends Container implements Skin {
  protected var contentView:Container;

  public function BoxSkin() {
    super();

    mouseEnabled = false;
  }



    public function set preferredWidth(value:int):void {
      _preferredWidth = value;
      _layout.invalidateSubview(true);
    }

    override public function getPreferredHeight(wHint:int = -1):int {
      return _preferredHeight == 0 ? _layout.preferredLayoutHeight(LayoutUtil.PREF) : _preferredHeight;
    }

  override protected function createChildren():void {
    super.createChildren();

    if (contentView == null) {
      contentView = new Container();
      hostComponent.uiPartAdded("contentView", contentView);
      addChild(contentView);
    }
  }

  override protected function measure():void {
    measuredMinWidth = contentView.minWidth;
    measuredMinHeight = contentView.minHeight;
    measuredWidth = contentView.getExplicitOrMeasuredWidth();
    measuredHeight = contentView.getExplicitOrMeasuredHeight();
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    contentView.setActualSize(w, h);
  }

  public function get hostComponent():SkinnableView {
    return null;
  }

  public function attach(component:SkinnableView):void {
  }

  public function hostComponentPropertyChanged():void {
  }
}
}