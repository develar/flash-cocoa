package cocoa.colorPicker {
import cocoa.AbstractView;
import cocoa.plaf.LookAndFeel;

import flash.display.Graphics;
import flash.events.MouseEvent;

public class SwatchPanel extends AbstractView {
  private var swatchGrid:SwatchGrid;

  public function SwatchPanel() {
    super();

    addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
  }

  private function mouseMoveHandler(event:MouseEvent):void {
    //event.stopImmediatePropagation();
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
      invalidateProperties();
    }
  }

  private var colorListChanged:Boolean;
  private var _colorList:Vector.<uint>;
  public function set colorList(value:Vector.<uint>):void {
    _colorList = value;
    colorListChanged = true;
    invalidateProperties();
  }

  private var _changeColorHandler:Function;
  public function set changeColorHandler(value:Function):void {
    _changeColorHandler = value;
  }

  override protected function createChildren():void {
    swatchGrid = new SwatchGrid();
    swatchGrid.x = 8;
    swatchGrid.y = 8;
    addDisplayObject(swatchGrid);
  }

  override protected function commitProperties():void {
    if (colorChanged) {
      colorChanged = false;
    }

    if (colorListChanged) {
      colorListChanged = false;

      swatchGrid.drawGrid(_colorList, _laf.getBorder("SwatchGrid.border"));
    }
  }

  override protected function measure():void {
    measuredWidth = swatchGrid.width + 16;
    measuredHeight = swatchGrid.height + 16;
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    var g:Graphics = graphics;
    _laf.getBorder("MenuItem.border").draw(null, g, w, h);
  }
}
}
