package cocoa.plaf.basic {
import cocoa.Border;
import cocoa.FlexDataGroup;
import cocoa.LightFlexUIComponent;
import cocoa.ListView;
import cocoa.ScrollPolicy;
import cocoa.ScrollView;
import cocoa.plaf.ListViewSkin;
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObject;
import flash.display.Graphics;

import mx.core.IUIComponent;

public class ListViewSkin extends LightFlexUIComponent implements cocoa.plaf.ListViewSkin {
  private var scrollView:ScrollView;
  protected var dataGroup:FlexDataGroup;
  private var contentView:IUIComponent;

  private var border:Border;

  private var _bordered:Boolean = true;
  public function set bordered(value:Boolean):void {
    _bordered = value;
  }

  protected var _laf:LookAndFeel;
  public function set laf(value:LookAndFeel):void {
    _laf = value;
  }

  override protected function createChildren():void {
    dataGroup = new FlexDataGroup();

    if (_horizontalScrollPolicy != ScrollPolicy.OFF && _verticalScrollPolicy != ScrollPolicy.OFF) {
      scrollView = new ScrollView();
      scrollView.hasFocusableChildren = false;
      scrollView.documentView = dataGroup;

      scrollView.horizontalScrollPolicy = _horizontalScrollPolicy;
      scrollView.verticalScrollPolicy = _verticalScrollPolicy;

      contentView = scrollView;
    }
    else {
      contentView = dataGroup;
    }

    if (_bordered) {
      border = _laf.getBorder("ListView.border");
      contentView.move(border.contentInsets.left, border.contentInsets.top);
    }

    addChild(DisplayObject(contentView));

    ListView(parent).uiPartAdded("dataGroup", dataGroup);
  }

  private var _verticalScrollPolicy:int;
  public function set verticalScrollPolicy(value:uint):void {
    _verticalScrollPolicy = value;
    if (scrollView != null) {
      scrollView.verticalScrollPolicy = value;
    }
  }

  private var _horizontalScrollPolicy:int;
  public function set horizontalScrollPolicy(value:uint):void {
    _horizontalScrollPolicy = value;
    if (scrollView != null) {
      scrollView.horizontalScrollPolicy = value;
    }
  }

  override protected function measure():void {
    measuredMinWidth = contentView.minWidth;
    measuredWidth = contentView.getExplicitOrMeasuredWidth();

    measuredMinHeight = contentView.minHeight;
    measuredHeight = contentView.getExplicitOrMeasuredHeight();

    if (_bordered) {
      measuredMinWidth += border.contentInsets.height;
      measuredWidth += border.contentInsets.height;
    }
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    if (_bordered) {
      contentView.setActualSize(w - border.contentInsets.width, h - border.contentInsets.height);

      var g:Graphics = graphics;
      g.clear();
      border.draw(null, g, w, h);
    }
    else {
      contentView.setActualSize(w, h);
    }
  }
}
}