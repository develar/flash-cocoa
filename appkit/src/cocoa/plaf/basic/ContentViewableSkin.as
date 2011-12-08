package cocoa.plaf.basic {
import cocoa.ContentView;
import cocoa.View;
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObjectContainer;

import flash.errors.IllegalOperationError;
import flash.events.Event;

public class ContentViewableSkin extends AbstractSkin implements ContentView {
  private static const VALIDATE_LISTENERS_ATTACHED:uint = 1 << 3;

  public function set preferredWidth(value:int):void {
    throw new IllegalOperationError("not allowed");
  }

  public function set preferredHeight(value:int):void {
    throw new IllegalOperationError("not allowed");
  }

  public function get displayObject():DisplayObjectContainer {
    return this;
  }

  public function invalidateSubview(invalidateSuperview:Boolean = true):void {
    if ((flags & VALIDATE_LISTENERS_ATTACHED) == 0) {
      flags |= VALIDATE_LISTENERS_ATTACHED;
      addEventListener(Event.ENTER_FRAME, enterFrameHandler);
    }
  }

  override public function validate():void {
    if ((flags & VALIDATE_LISTENERS_ATTACHED) != 0) {
      flags &= ~VALIDATE_LISTENERS_ATTACHED;
      removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
    }

    // i.e. our draw will not be called
    if ((flags & INVALID) == 0) {
      subviewsValidate();
    }

    super.validate();
  }

  protected function subviewsValidate():void {

  }

  private function enterFrameHandler(event:Event):void {
    validate();
  }

  public function set laf(value:LookAndFeel):void {
    throw new IllegalOperationError("not allowed");
  }

  public function addSubview(view:View):void {
    throw new IllegalOperationError("not allowed");
  }
}
}
