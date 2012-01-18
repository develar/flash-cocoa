package cocoa {
/** http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ActionMessages/Concepts/TargetsAndActions.html
 */
public interface Control {
  /** Action Handler for User initiated action, can be called only as result of user interaction (programmatically initiated (like set selectedIndex for PopUpButton) is ignored or see userInitiated flag).
   * actionHandler():void or
   * actionHandler(targetControl:T):void where T is actual type of control (cocoa.PushButton for example) or
   * actionHandler(targetControl:T, userInitiated:Boolean):void where userInitiated is flag — true if action called as result of user interaction
   * If you want to pass additional parameters to your handler, use @see #setAction() instead of this.
   */
  function set action(value:Function):void;

  function setAction(value:Function, ...parameters):void;

  function get objectValue():Object;

  function set objectValue(value:Object):void;
}
}