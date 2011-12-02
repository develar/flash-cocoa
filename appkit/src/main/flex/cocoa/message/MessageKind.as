package cocoa.message {
import cocoa.View;

import flash.display.DisplayObjectContainer;
import flash.events.IEventDispatcher;

public class MessageKind {
  public var position:uint = MessagePosition.MOUSE_CURSOR;
  public var positioner:Function;

  public function MessageKind(id:uint = 0):void {
    _id = id;
  }

  protected var _id:uint = 0;
  public function get id():uint {
    return _id;
  }

  private var _message:View;
  public function get message():View {
    return _message;
  }

  public function set message(value:View):void {
    _message = value;
  }

  private var _target:IEventDispatcher;
  public function set target(value:IEventDispatcher):void {
    _target = value;
  }

  public function get target():IEventDispatcher {
    return _target;
  }

  private var _parent:DisplayObjectContainer;
  public function set parent(value:DisplayObjectContainer):void {
    _parent = value;
  }

  public function get parent():DisplayObjectContainer {
    return _parent;
  }

  /**
   * Time to show
   */
  private var _showTime:uint = 5000;
  public function set showTime(value:uint):void {
    _showTime = value;
  }

  public function get showTime():uint {
    return _showTime;
  }

  private var _showDelay:uint = 500;
  public function set showDelay(value:uint):void {
    _showDelay = value;
  }

  public function get showDelay():uint {
    return _showDelay;
  }

  /**
   * Time to hide after roll out from context
   * Сколько ждать возврата курсора мыши на ComplexToolTip до его удаления после ухода из контекста
   */
  private var _returnTime:uint = 500;
  public function set returnTime(value:uint):void {
    _returnTime = value;
  }

  public function get returnTime():uint {
    return _returnTime;
  }
}
}