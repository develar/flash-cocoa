package cocoa.keyboard {
public final class Shortcut {
  public static const ANY_PROFILE:int = 0;

  private static const COMMAND:uint = 1 << 0;
  private static const SHIFT:uint = 1 << 1;
  private static const ALT:uint = 1 << 2;

  public var keymap:int = ANY_PROFILE;

  public var code:uint;
  public var flags:uint = COMMAND;

  public function get command():Boolean {
    return (flags & COMMAND) != 0;
  }

  public function get shift():Boolean {
    return (flags & SHIFT) != 0;
  }

  public function get alt():Boolean {
    return (flags & ALT) != 0;
  }
}
}