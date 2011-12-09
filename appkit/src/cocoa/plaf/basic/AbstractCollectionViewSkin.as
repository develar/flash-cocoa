package cocoa.plaf.basic {
import cocoa.AbstractCollectionView;
import cocoa.Border;
import cocoa.Focusable;
import cocoa.Insets;
import cocoa.ScrollPolicy;
import cocoa.ScrollView;
import cocoa.View;
import cocoa.Viewport;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.errors.IllegalOperationError;

internal class AbstractCollectionViewSkin extends AbstractSkin implements Focusable {
  protected var contentView:View;
  protected var border:Border;
  protected var documentView:Viewport;

  protected function createDocumentView():Viewport {
    throw new IllegalOperationError("abstract");
  }

  override protected function doInit():void {
    super.doInit();

    border = getNullableBorder();

    var component:AbstractCollectionView = AbstractCollectionView(this.hostComponent);
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

    if (border != null) {
      contentView.setLocation(border.contentInsets.left, border.contentInsets.top);
    }
    addChild(DisplayObject(contentView));
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

  override public function getPreferredWidth(hHint:int = -1):int {
    var insets:Insets = border != null ? border.contentInsets : Insets.EMPTY;
    return contentView.getPreferredWidth() + insets.width;
  }

  override public function getPreferredHeight(wHint:int = -1):int {
    var insets:Insets = border != null ? border.contentInsets : Insets.EMPTY;
    return contentView.getPreferredHeight() + insets.height;
  }

  public function get focusObject():InteractiveObject {
    return InteractiveObject(documentView);
  }
}
}
