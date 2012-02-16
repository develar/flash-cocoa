package cocoa.plaf.basic {
import cocoa.CellState;
import cocoa.Scroller;
import cocoa.border.StatefulBorder;

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
}
}
