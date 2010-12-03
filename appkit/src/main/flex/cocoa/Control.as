package cocoa {
/**
 * http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ActionMessages/Concepts/TargetsAndActions.html
 */
public interface Control {
  /**
   * Action Handler for User initiated action, called only as result of user interaction (programmatically initiated (like set selectedIndex for PopUpButton) is ignored)
   */
  function set action(value:Function):void;

  function get objectValue():Object;

  function set objectValue(value:Object):void;

  function get hidden():Boolean;
  function set hidden(value:Boolean):void;
}
}