package cocoa.plaf.basic {
import cocoa.colorPicker.ColorEvent;
import cocoa.colorPicker.ColorPicker;

public class ColorPickerMenuController extends PullDownMenuController {
  private var proposedColor:Number;

  override protected function addHandlers():void {
    super.addHandlers();

    itemGroup.addEventListener(ColorEvent.SET_COLOR, setColorHandler);
  }

  private function setColorHandler(event:ColorEvent):void {
    proposedColor = event.color;
  }

  override protected function setSelectedIndex(value:int):void {
    ColorPicker(popUpButton).setColorAndCallUserInitiatedActionHandler(value, proposedColor);
  }
}
}