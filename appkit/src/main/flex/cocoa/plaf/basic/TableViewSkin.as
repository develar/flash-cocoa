package cocoa.plaf.basic {
import cocoa.Border;
import cocoa.ScrollPolicy;
import cocoa.ScrollView;
import cocoa.tableView.TableView;

import flash.display.DisplayObject;
import flash.display.Graphics;

import mx.core.IUIComponent;

public class TableViewSkin extends AbstractSkin {
  private var contentView:IUIComponent;

  private var scrollView:ScrollView;
  private var tableBody:TableBody;
  private var border:Border;

  public function set verticalScrollPolicy(value:uint):void {
    scrollView.verticalScrollPolicy = value;
  }

  public function set horizontalScrollPolicy(value:uint):void {
    scrollView.horizontalScrollPolicy = value;
  }

  override protected function createChildren():void {
    super.createChildren();

    border = getBorder();

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

    contentView.move(border.contentInsets.left, border.contentInsets.top);
    addChild(DisplayObject(contentView));
  }

  override protected function measure():void {
    measuredMinWidth = contentView.minWidth + border.contentInsets.height;
    measuredWidth = contentView.getExplicitOrMeasuredWidth() + border.contentInsets.height;

    measuredMinHeight = contentView.minHeight + border.contentInsets.height;
    measuredHeight = contentView.getExplicitOrMeasuredHeight() + border.contentInsets.height;
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    contentView.setActualSize(w - border.contentInsets.width, h - border.contentInsets.height);

    var g:Graphics = graphics;
    g.clear();
    border.draw(null, g, w, h);
  }
}
}