package cocoa.plaf.aqua {
public final class BorderPosition {
  public static const pushButtonRounded:int = 0;
  public static const pushButtonTexturedRounded:int = 1;
  public static const popUpButtonTexturedRounded:int = 2;

  public static const imageView:int = 3;

  public static const menu:int = 4;
  public static const menuItem:int = 5;
  public static const hudMenuItem:int = 6;

  public static const segmentItem:int = hudMenuItem + 1;
  public static const scrollbar:int = segmentItem + 1;

  public static const window:int = scrollbar + 14;
  public static const windowWithToolbar:int = window + 1;

  public static const windowApplicationBottomBar:int = windowWithToolbar + 1;
  public static const windowChooseDialogBottomBar:int = windowApplicationBottomBar + 1;

  public static const hudWindow:int = windowChooseDialogBottomBar + 1;

  public static const treeItem:int = hudWindow + 1;
  public static const treeDisclosureSideBar:int = treeItem + 1;

  public static const textField:int = treeDisclosureSideBar + 2;

  public static const totalLength:int = textField + 1;
}
}