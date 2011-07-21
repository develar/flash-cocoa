package cocoa.plaf.basic {
import cocoa.colorPicker.ColorEvent;
import cocoa.colorPicker.ColorPicker;

public class ColorPickerMenuController extends PullDownMenuInteractor {
  private var proposedColor:Number;

  override protected function addHandlers():void {
    super.addHandlers();

    itemGroup.addEventListener(ColorEvent.SET_COLOR, setColorHandler);
  }

  private function setColorHandler(event:ColorEvent):void {
    // пока что нам приходит только rgb
    proposedColor = ColorPicker(popUpButton).showsAlpha ? ((0xff << 24) | event.color) : event.color;
  }

  override protected function setSelectedIndex(value:int):void {
    ColorPicker(popUpButton).setColorAndCallUserInitiatedActionHandler(value, proposedColor);
  }

  override protected function close():void {
    super.close();

    proposedColor = NaN;
  }
}
}