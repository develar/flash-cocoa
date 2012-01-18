package cocoa.plaf.basic {
import cocoa.CellState;
import cocoa.Scroller;
import cocoa.border.StatefulBorder;

import flash.events.MouseEvent;

public class ScrollerSkin extends SliderSkin {
  override public function validate():Boolean {
    if (super.validate()) {
      return true;
    }

    drawKnob(CellState.OFF);

    return false;
  }

  override protected function doDrawKnob(knobBorder:StatefulBorder):void {
    if (slider.vertical) {
      knobBorder.draw(knob.graphics, NaN, Math.round(actualHeight * (actualHeight / Scroller(slider).contentSize)));
    }
    else {
      knobBorder.draw(knob.graphics, Math.round(actualWidth * (actualWidth / Scroller(slider).contentSize)), NaN);
    }
  }

  override protected function addListeners():void {
    super.addListeners();

    addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
  }

  private function mouseWheelHandler(event:MouseEvent):void {
    if (event.delta == 0) {
      return;
    }

    //const newValue:Number = slider.correctValue(slider.value - (event.delta * dV));
    //if (newValue == slider.value) {
    //  return;
    //}
    //
    //positionKnob();
    //slider.setValue(newValue, true);
    //
    //event.updateAfterEvent();
  }
}
}
