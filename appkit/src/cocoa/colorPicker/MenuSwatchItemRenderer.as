package cocoa.colorPicker {
import cocoa.ControlView;
import cocoa.plaf.LookAndFeel;

import flash.display.Graphics;

public class MenuSwatchItemRenderer extends ControlView {
  private var swatchGrid:SwatchGrid;

  public function MenuSwatchItemRenderer() {
    super();
  }

  private var _laf:LookAndFeel;
  public function set laf(value:LookAndFeel):void {
    _laf = value;
  }

  private var colorChanged:Boolean;
  private var _color:uint;
  public function set color(value:uint):void {
    if (value != _color) {
      _color = value;
      colorChanged = true;
      invalidate();
    }
  }

  private var colorListChanged:Boolean;
  private var _colorList:Vector.<uint>;
  public function set colorList(value:Vector.<uint>):void {
    _colorList = value;
    colorListChanged = true;
    //invalidateProperties();
  }

  private var _changeColorHandler:Function;
  public function set changeColorHandler(value:Function):void {
    _changeColorHandler = value;
  }

  //override protected function createChildren():void {
  //  swatchGrid = new SwatchGridWithHighlightIndicator();
  //  swatchGrid.x = 8;
  //  swatchGrid.y = 8;
  //  addChild(swatchGrid);
  //}

  //override protected function commitProperties():void {
  //  if (colorChanged) {
  //    colorChanged = false;
  //  }
  //
  //  if (colorListChanged) {
  //    colorListChanged = false;
  //
  //    swatchGrid.drawGrid(_colorList, _laf.getBorder("SwatchGrid.b", false));
  //    width = swatchGrid.width + 16;
  //    height = swatchGrid.height + 16;
  //  }
  //
  //  super.commitProperties();
  //}

  override protected function draw(w:int, h:int):void {
    var g:Graphics = graphics;
    g.clear();
    _laf.getBorder("MenuItem.b", false).draw(g, w, h);
  }
}
}
