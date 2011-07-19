package cocoa.renderer {
public final class LayeringMode {
  public static const UNORDERED:int = 0;
  // z = itemIndex
  public static const ASCENDING_ORDER:int = 1;
  // z = maxItemIndex - itemIndex
  public static const DESCENDING_ORDER:int = 2;
}
}
