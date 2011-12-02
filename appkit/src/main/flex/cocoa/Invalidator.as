package cocoa {
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.IEventDispatcher;

public class Invalidator {
  private static const _instance:Invalidator = new Invalidator();

  private var invalid:Boolean = true;

  private var containers:Vector.<Container> = new Vector.<Container>();
  private var controls:Vector.<View> = new Vector.<View>();

  public static function get instance():Invalidator {
    return _instance;
  }

  public function invalidateControl(control:View, dispatcher:DisplayObject):void {
    if (controls.indexOf(control) == -1) {
      controls[controls.length] = control;
      if (!invalid) {
        attachListeners(dispatcher);
      }
    }
  }

  public function invalidateContainer(container:Container, dispatcher:DisplayObject):void {
    if (containers.indexOf(container) == -1) {
      containers[containers.length] = container;
      if (!invalid) {
        attachListeners(dispatcher);
      }
    }
  }

  private function attachListeners(dispatcher:DisplayObject):void {
    dispatcher.stage.getChildAt(0).addEventListener(Event.ENTER_FRAME, enterFrameHandler);
  }

  private function enterFrameHandler(event:Event):void {
    IEventDispatcher(event.currentTarget).removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
    if (containers.length > 0) {
      var oldContainers:Vector.<Container> = containers;
      containers = new Vector.<Container>();
      for each (var container:Container in oldContainers) {
        container.validate();
      }
    }

    if (controls.length > 0) {
      var oldControls:Vector.<View> = controls;
      controls = new Vector.<View>();
      for each (var control:View in oldControls) {
        control.validate();
      }
    }
  }
}
}
