package cocoa.plaf.basic {
import cocoa.Border;
import cocoa.CellState;
import cocoa.Slider;
import cocoa.border.StatefulBorder;
import cocoa.util.SharedPoint;

import flash.display.Shape;
import flash.events.MouseEvent;
import flash.geom.Point;

public class SliderSkin extends AbstractSkin {
  protected var knob:Shape;

  private var slider:Slider;

  public function valueOrMinOrMaxChanged():void {
    positionKnob(getKnobBorder());
  }

  override protected function doInit():void {
    super.doInit();

    slider = Slider(component);
    knob = new Shape();
    addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
  }

  override protected function draw(w:int, h:int):void {
    super.draw(w, h);

    graphics.clear();
    getBorder("track." + (slider.vertical ? "v" : "h"));

    positionKnob(drawKnob(CellState.OFF));
  }

  protected function drawKnob(state:int):Border {
    var knobBorder:StatefulBorder = getKnobBorder();
    knobBorder.stateIndex = state;
    knob.graphics.clear();
    knobBorder.draw(knob.graphics);
    return knobBorder;
  }

  protected function getKnobBorder():StatefulBorder {
    return StatefulBorder(getBorder("knob." + (slider.vertical ? "v" : "h")));
  }

  protected function mouseDownHandler(event:MouseEvent):void {
    var thumbBorder:StatefulBorder = getKnobBorder();
    if (event.localX >= knob.x && event.localX <= (knob.x + thumbBorder.layoutWidth) && event.localY >= knob.y && event.localY <= (knob.y + thumbBorder.layoutHeight)) {
      stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
      stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);

      drawKnob(CellState.ON);
      event.updateAfterEvent();
    }
  }

  protected function stageMouseUpHandler(event:MouseEvent):void {
    stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
    stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);

    drawKnob(CellState.OFF);

    // if continuous, user initiated action handler already called, otherwise we call it now
    if (!slider.continuous) {
      slider.setValue(NaN, true);
    }

    event.updateAfterEvent();
  }

  protected function stageMouseMoveHandler(event:MouseEvent):void {
    var knobBorder:StatefulBorder = getKnobBorder();
    var position:Number;
    const pixelRange:Number = computePixelRange(knobBorder);
    var mouseLocal:Point = globalToLocal(SharedPoint.mouseGlobal(event));
    if (slider.vertical) {
      position = Math.min(mouseLocal.y, pixelRange);
      if (knob.y == position) {
        return;
      }
      else {
        knob.y = position;
      }
    }
    else {
      position = Math.min(mouseLocal.x, pixelRange);
      if (knob.x == position) {
        return;
      }
      else {
        knob.x = position;
      }
    }

    slider.setValue(((position / pixelRange) * (slider.max - slider.min)) + slider.min, false);

    event.updateAfterEvent();
  }

  protected function computePixelRange(knobBorder:Border):Number {
    return slider.vertical ? actualHeight - knobBorder.layoutHeight : actualWidth - knobBorder.layoutWidth;
  }

  protected function positionKnob(knobBorder:Border):void {
    const position:Number = Math.round((slider.value - slider.min) / (slider.max - slider.min) * computePixelRange(knobBorder));
    if (slider.vertical) {
      knob.y = position;
    }
    else {
      knob.x = position;
    }
  }
}
}