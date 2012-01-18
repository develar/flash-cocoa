package cocoa.plaf.basic {
import cocoa.ContentView;

import flash.display.DisplayObjectContainer;
import flash.events.Event;

public class ContentViewableSkin extends AbstractSkin implements ContentView {
  private static const VALIDATE_LISTENER_ATTACHED:uint = 1 << 5;

  public function get displayObject():DisplayObjectContainer {
    return this;
  }

  public function invalidateSubview(invalidateSuperview:Boolean = true):void {
    if ((flags & VALIDATE_LISTENER_ATTACHED) == 0) {
      flags |= VALIDATE_LISTENER_ATTACHED;
      addEventListener(Event.RENDER, renderHandler);
      if (stage != null) {
        stage.invalidate();
      }

      if (invalidateSuperview) {
        superview.invalidateSubview(true);
      }
    }
  }

  override public function validate():Boolean {
    if ((flags & VALIDATE_LISTENER_ATTACHED) != 0) {
      flags &= ~VALIDATE_LISTENER_ATTACHED;
      removeEventListener(Event.RENDER, renderHandler);
    }

    if (super.validate()) {
      return true;
    }

    // i.e. our draw will not be called
    subviewsValidate();
    return false;
  }

  protected function subviewsValidate():void {

  }

  private function renderHandler(event:Event):void {
    validate();
  }
}
}