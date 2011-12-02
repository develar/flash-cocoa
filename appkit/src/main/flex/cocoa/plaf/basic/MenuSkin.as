package cocoa.plaf.basic {
import cocoa.Border;
import cocoa.Insets;
import cocoa.Menu;
import cocoa.MenuItem;
import cocoa.SingleSelectionDataGroup;

import flash.display.Graphics;

import mx.core.IDataRenderer;
import mx.core.IVisualElement;
import mx.core.mx_internal;

import spark.components.IItemRenderer;
import spark.components.IItemRendererOwner;
import spark.layouts.HorizontalAlign;
import spark.layouts.VerticalLayout;

use namespace mx_internal;

public class MenuSkin extends AbstractSkin implements IItemRendererOwner {
  private var itemGroup:SingleSelectionDataGroup;

  private var _border:Border;
  public function get border():Border {
    return _border;
  }

  override protected function createChildren():void {
    super.createChildren();

    _border = getBorder();

    itemGroup = new SingleSelectionDataGroup();
    itemGroup.itemRenderer = getFactory("iR");
    itemGroup.rendererUpdateDelegate = this;
    var itemGroupLayout:VerticalLayout = new VerticalLayout();
    itemGroupLayout.gap = 0;
    itemGroupLayout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
    itemGroup.layout = itemGroupLayout;
    itemGroup.x = _border.contentInsets.left;
    itemGroup.y = _border.contentInsets.top;
    addChild(itemGroup);

    hostComponent.uiPartAdded("itemGroup", itemGroup);
  }

  public function itemToLabel(item:Object):String {
    return Menu(hostComponent).labelFunction == null ? String(item) : Menu(hostComponent).labelFunction(item);
  }

  public function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void {
    if (renderer is IItemRenderer) {
      AbstractItemRenderer(renderer).laf = laf;

      IItemRenderer(renderer).itemIndex = itemIndex;
      IItemRenderer(renderer).label = (data is MenuItem && MenuItem(data).isSeparatorItem) ? null : itemToLabel(data);
    }

    if ((renderer is IDataRenderer) && (renderer !== data)) {
      IDataRenderer(renderer).data = data;
    }
  }

  override protected function measure():void {
    var contentInsets:Insets = _border.contentInsets;
    measuredMinWidth = measuredWidth = contentInsets.width + itemGroup.getExplicitOrMeasuredWidth();
    measuredMinHeight = measuredHeight = contentInsets.height + itemGroup.getExplicitOrMeasuredHeight();
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    itemGroup.setActualSize(w - _border.contentInsets.width, h - _border.contentInsets.height);

    var g:Graphics = graphics;
    g.clear();
    _border.draw(g, w, h);
  }
}
}