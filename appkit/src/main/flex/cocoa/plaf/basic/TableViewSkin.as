package cocoa.plaf.basic {
import cocoa.ScrollPolicy;
import cocoa.ScrollView;
import cocoa.tableView.TableView;

import flash.display.DisplayObject;

import mx.core.IUIComponent;

public class TableViewSkin extends AbstractSkin {
  private var contentView:IUIComponent;

  private var scrollView:ScrollView;
  private var tableBody:TableBody;

  public function set verticalScrollPolicy(value:uint):void {
    scrollView.verticalScrollPolicy = value;
  }

  public function set horizontalScrollPolicy(value:uint):void {
    scrollView.horizontalScrollPolicy = value;
  }

  override protected function createChildren():void {
    super.createChildren();

    var component:TableView = TableView(component);

    tableBody = new TableBody(component, laf);

    if (component.horizontalScrollPolicy == ScrollPolicy.OFF && component.verticalScrollPolicy == ScrollPolicy.OFF) {
      contentView = tableBody;
    }
    else {
      scrollView = new ScrollView();
      scrollView.hasFocusableChildren = false;
      scrollView.documentView = tableBody;

      scrollView.horizontalScrollPolicy = component.horizontalScrollPolicy;
      scrollView.verticalScrollPolicy = component.verticalScrollPolicy;

      contentView = scrollView;
    }

    addChild(DisplayObject(contentView));
  }

  override protected function measure():void {
    measuredMinWidth = contentView.minWidth;
    measuredWidth = contentView.getExplicitOrMeasuredWidth();

    measuredMinHeight = contentView.minHeight;
    measuredHeight = contentView.getExplicitOrMeasuredHeight();
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    contentView.setActualSize(w, h);
  }
}
}