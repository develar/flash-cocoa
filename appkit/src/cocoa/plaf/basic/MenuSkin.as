package cocoa.plaf.basic {
import cocoa.Border;
import cocoa.Menu;
import cocoa.SegmentedControl;

public class MenuSkin extends AbstractSkin {
  private var itemGroup:SegmentedControl;

  private var _border:Border;
  public function get border():Border {
    return _border;
  }

  override protected function doInit():void {
    super.doInit();

    _border = getBorder();

    itemGroup = new SegmentedControl();
    //itemGroup.itemRenderer = getFactory("iR");
    //itemGroup.rendererUpdateDelegate = this;
    //var itemGroupLayout:VerticalLayout = new VerticalLayout();
    //itemGroupLayout.gap = 0;
    //itemGroupLayout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
    //itemGroup.layout = itemGroupLayout;
    itemGroup.x = _border.contentInsets.left;
    itemGroup.y = _border.contentInsets.top;
    addChild(itemGroup);

    component.uiPartAdded("itemGroup", itemGroup);
  }

  public function itemToLabel(item:Object):String {
    return Menu(component).labelFunction == null ? String(item) : Menu(component).labelFunction(item);
  }

  //public function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void {
  //  if (renderer is IItemRenderer) {
  //    //AbstractItemRenderer(renderer).laf = laf;
  //
  //    IItemRenderer(renderer).itemIndex = itemIndex;
  //    IItemRenderer(renderer).label = (data is MenuItem && MenuItem(data).isSeparatorItem) ? null : itemToLabel(data);
  //  }
  //
  //  if ((renderer is IDataRenderer) && (renderer !== data)) {
  //    IDataRenderer(renderer).data = data;
  //  }
  //}

  //override protected function measure():void {
  //  var contentInsets:Insets = _border.contentInsets;
  //  measuredMinWidth = measuredWidth = contentInsets.width + itemGroup.getExplicitOrMeasuredWidth();
  //  measuredMinHeight = measuredHeight = contentInsets.height + itemGroup.getExplicitOrMeasuredHeight();
  //}

  //override protected function updateDisplayList(w:Number, h:Number):void {
  //  itemGroup.setActualSize(w - _border.contentInsets.width, h - _border.contentInsets.height);
  //
  //  var g:Graphics = graphics;
  //  g.clear();
  //  _border.draw(g, w, h);
  //}
}
}