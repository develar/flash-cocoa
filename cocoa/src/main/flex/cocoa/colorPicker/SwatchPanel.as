package cocoa.colorPicker {
import cocoa.AbstractView;
import cocoa.plaf.LookAndFeel;

import flash.events.MouseEvent;

public class SwatchPanel extends AbstractView {
  private var swatches:SwatchGrid;

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
    swatches = new SwatchGrid();
    addDisplayObject(swatches);
  }

  override protected function commitProperties():void {
    if (colorChanged) {
      colorChanged = false;
    }

    if (colorListChanged) {
      colorListChanged = false;

      swatches.drawGrid(_colorList);
    }
  }

  override protected function measure():void {
    measuredWidth = swatches.width;
    measuredHeight = swatches.height;
  }

  override protected function updateDisplayList(w:Number, h:Number):void {

  }
}
}
