package cocoa.plaf.basic {
import cocoa.Container;

public class BoxSkin extends Container {
  protected var contentView:Container;

  public function BoxSkin() {
    super();

    mouseEnabled = false;
  }

  override public function getMinimumWidth(hHint:int = -1):int {
      return contentView.getMinimumWidth(hHint);
    }

    override public function getMinimumHeight(wHint:int = -1):int {
      return _layout.preferredLayoutHeight(LayoutUtil.MIN);
    }

    override public function getPreferredWidth(hHint:int = -1):int {
      return _preferredWidth == 0 ? _layout.preferredLayoutWidth(LayoutUtil.PREF) : _preferredWidth;
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
}
}