package cocoa.plaf.basic {
import cocoa.AbstractCollectionView;
import cocoa.Border;
import cocoa.Focusable;
import cocoa.Insets;
import cocoa.ScrollPolicy;
import cocoa.ScrollView;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.errors.IllegalOperationError;

import mx.core.IUIComponent;

import spark.core.IViewport;

internal class AbstractCollectionViewSkin extends AbstractSkin implements Focusable {
  protected var contentView:IUIComponent;
  protected var border:Border;
  protected var documentView:IViewport;

  protected function createDocumentView():IViewport {
    throw new IllegalOperationError("abstract");
  }

  override protected function createChildren():void {
    super.createChildren();

    border = getNullableBorder();

    var component:AbstractCollectionView = AbstractCollectionView(this.hostComponent);
    documentView = createDocumentView();
    if (component.horizontalScrollPolicy == ScrollPolicy.OFF && component.verticalScrollPolicy == ScrollPolicy.OFF) {
      contentView = IUIComponent(documentView);
    }
    else {
      var scrollView:ScrollView = new ScrollView();
      //scrollView.hasFocusableChildren = false;
      scrollView.documentView = documentView;

      scrollView.horizontalScrollPolicy = component.horizontalScrollPolicy;
      scrollView.verticalScrollPolicy = component.verticalScrollPolicy;

      contentView = scrollView;
    }

    if (border != null) {
      contentView.move(border.contentInsets.left, border.contentInsets.top);
    }
    addChild(DisplayObject(contentView));
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    if (border == null) {
      contentView.setActualSize(w, h);
    }
    else {
      contentView.setActualSize(w - border.contentInsets.width, h - border.contentInsets.height);
      graphics.clear();
      border.draw(graphics, w, h);
    }
  }

  override protected function measure():void {
    var insets:Insets = border != null ? border.contentInsets : Insets.EMPTY;

    measuredMinWidth = contentView.minWidth + insets.width;
    measuredWidth = contentView.getExplicitOrMeasuredWidth() + insets.width;

    measuredMinHeight = contentView.minHeight + insets.height;
    measuredHeight = contentView.getExplicitOrMeasuredHeight() + insets.height;
  }

  public function get focusObject():InteractiveObject {
    return InteractiveObject(documentView);
  }
}
}
