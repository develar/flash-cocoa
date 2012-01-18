package cocoa.plaf.basic {
import cocoa.AbstractCollectionView;
import cocoa.Border;
import cocoa.Focusable;
import cocoa.Insets;
import cocoa.ScrollPolicy;
import cocoa.ScrollView;
import cocoa.View;
import cocoa.Viewport;

import flash.display.InteractiveObject;
import flash.errors.IllegalOperationError;

internal class AbstractCollectionViewSkin extends ContentViewableSkin implements Focusable {
  protected var contentView:View;
  protected var border:Border;
  protected var documentView:Viewport;

  protected function createDocumentView():Viewport {
    throw new IllegalOperationError("abstract");
  }

  override protected function doInit():void {
    super.doInit();

    border = getNullableBorder();

    var component:AbstractCollectionView = AbstractCollectionView(component);
    documentView = createDocumentView();
    if (component.horizontalScrollPolicy == ScrollPolicy.OFF && component.verticalScrollPolicy == ScrollPolicy.OFF) {
      contentView = documentView;
    }
    else {
      var scrollView:ScrollView = new ScrollView();
      scrollView.documentView = documentView;

      scrollView.horizontalScrollPolicy = component.horizontalScrollPolicy;
      scrollView.verticalScrollPolicy = component.verticalScrollPolicy;

      contentView = scrollView;
    }

    contentView.addToSuperview(this, laf, this);
    if (border != null) {
      contentView.setLocation(border.contentInsets.left, border.contentInsets.top);
    }
  }

  override protected function subviewsValidate():void {
    if (contentView != null) {
      contentView.validate();
    }
  }

  override protected function draw(w:int, h:int):void {
    if (border == null) {
      contentView.setSize(w, h);
    }
    else {
      contentView.setSize(w - border.contentInsets.width, h - border.contentInsets.height);
      graphics.clear();
      border.draw(graphics, w, h);
    }

    contentView.validate();
  }

  private function getWidth(pref:Boolean):int {
    return (pref ? contentView.getPreferredWidth() : contentView.getMinimumWidth()) + (border == null ? 0 : border.contentInsets.width);
  }

  private function getHeight(pref:Boolean):int {
    return (pref ? contentView.getPreferredHeight() : contentView.getMinimumHeight()) + (border == null ? 0 : border.contentInsets.height);
  }

  override public function getMinimumWidth(hHint:int = -1):int {
    return getWidth(false);
  }

  override public function getMinimumHeight(wHint:int = -1):int {
    return getHeight(false);
  }

  override public function getPreferredWidth(hHint:int = -1):int {
    return getWidth(true);
  }

  override public function getPreferredHeight(wHint:int = -1):int {
    return getHeight(true);
  }

  public function get focusObject():InteractiveObject {
    return InteractiveObject(documentView);
  }
}
}
