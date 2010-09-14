package cocoa.plaf.aqua.assetBuilder {
import cocoa.Border;
import cocoa.FrameInsets;
import cocoa.Icon;
import cocoa.Insets;
import cocoa.TextInsets;
import cocoa.border.AbstractBitmapBorder;
import cocoa.border.AbstractMultipleBitmapBorder;
import cocoa.border.OneBitmapBorder;
import cocoa.border.Scale1BitmapBorder;
import cocoa.border.Scale3EdgeHBitmapBorder;
import cocoa.border.Scale3HBitmapBorder;
import cocoa.border.Scale3VBitmapBorder;
import cocoa.border.Scale9EdgeBitmapBorder;
import cocoa.plaf.basic.BitmapIcon;
import cocoa.plaf.ExternalizableResource;
import cocoa.plaf.aqua.AquaLookAndFeel;
import cocoa.plaf.aqua.BorderPosition;
import cocoa.util.FileUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.filesystem.File;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

public class Builder {
  [Embed(source="/assets.png")]
  private static var assetsClass:Class;

  [Embed(source="/popUpMenu.png")]
  private static var popUpMenuClass:Class;

  [Embed(source="/Window.bottomBar.application.png")]
  private static var bottomBarApplicationClass:Class;
  [Embed(source="/Window.bottomBar.chooseDialog.png")]
  private static var bottomBarChooseDialogClass:Class;

  [Embed(source="/Window.titleBarAndContent.png")]
  private static var titleBarAndContentClass:Class;
  [Embed(source="/Window.titleBarAndToolbarAndContent.png")]
  private static var titleBarAndToolbarAndContent:Class;

  [Embed(source="/Window.hud.titleBarAndContent.png")]
  private static var hudTitleBarAndContentClass:Class;

  [Embed(source="/segmentedControl.png")]
  private static var segmentedControlClass:Class;
  [Embed(source="/segmentedControl2.png")]
  private static var segmentedControl2Class:Class;
  [Embed(source="/segmentedControl3.png")]
  private static var segmentedControl3Class:Class;
  [Embed(source="/segmentedControl4.png")]
  private static var segmentedControl4Class:Class;

  [Embed(source="/segmentedControl.texturedRounded.png")]
  private static var segmentedControlTRClass:Class;
  [Embed(source="/segmentedControl2.texturedRounded.png")]
  private static var segmentedControl2TRClass:Class;
  [Embed(source="/segmentedControl3.texturedRounded.png")]
  private static var segmentedControl3TRClass:Class;
  [Embed(source="/segmentedControl4.texturedRounded.png")]
  private static var segmentedControl4TRClass:Class;

  [Embed(source="/Tree.border.png")]
  private static var treeBorder:Class;

  [Embed(source="/Tree.sideBar.icons.png")]
  private static var treeSideBarIcons:Class;

  [Embed(source="/hud/menuItem.h.png")]
  private static var hudMenuItemH:Class;

  private static var buttonRowsInfo:Vector.<RowInfo> = new Vector.<RowInfo>(3, true);
  // rounded push button
  buttonRowsInfo[0] = new RowInfo(BorderPosition.pushButtonRounded, Scale3EdgeHBitmapBorder.create(new FrameInsets(-2, 0, -2, -3), new Insets(9, NaN, 9, 5)));
  // textured rounded push button
  buttonRowsInfo[1] = new RowInfo(BorderPosition.pushButtonTexturedRounded, Scale3EdgeHBitmapBorder.create(new FrameInsets(0, 0, 0, -1), new Insets(8, NaN, 8, 6)));
  // rounded pop up button
  buttonRowsInfo[2] = new RowInfo(BorderPosition.popUpButtonTexturedRounded, Scale3EdgeHBitmapBorder.create(new FrameInsets(-2, 0, -2, -3), new TextInsets(21, 9, NaN, 9 + 21/* width of double-arrow area */, 5)));

  private function finalizeRowsInfo(rowsInfo:Vector.<RowInfo>, top:Number = 0):void {
    for each (var rowInfo:RowInfo in rowsInfo) {
      rowInfo.top = top;
      top += rowInfo.height;
    }
  }

  private var borders:Vector.<Border>;

  public function build(testContainer:DisplayObjectContainer):void {
    borders = new Vector.<Border>(BorderPosition.totalLength, true);
    var compoundImageReader:CompoundImageReader = new CompoundImageReader(borders);

    finalizeRowsInfo(buttonRowsInfo, 22);
    compoundImageReader.read(assetsClass, buttonRowsInfo);
    // image view bezel border (imagewell border)
    borders[BorderPosition.imageView] = Scale9EdgeBitmapBorder.create(new FrameInsets(-3, -3, -3, -3), new Insets(4, 4, 4, 4)).configure(compoundImageReader.parseScale9Grid(new Rectangle(0, 352, 50, 50), new Insets(8, 8, 8, 8)));

    borders[BorderPosition.textField] = Scale9EdgeBitmapBorder.create(null, new Insets(4, 3, 4, 2)).configure(compoundImageReader.parseScale9Grid(new Rectangle(120, 332, 100, 100)));

    var icons:Vector.<Icon> = new Vector.<Icon>(2, true);
    compoundImageReader.readMenu(icons, popUpMenuClass, Scale9EdgeBitmapBorder.create(new FrameInsets(-13, -3, -13, -23), new Insets(0, 4, 0, 4)), 18);
    borders[BorderPosition.hudMenuItem] = OneBitmapBorder.create(Bitmap(new hudMenuItemH()).bitmapData, new Insets(21, NaN, 21, 4));

    var windowBottomBarFrameInsets:FrameInsets = new FrameInsets(-33, 0, -33, -48);
    compoundImageReader.readScale3(bottomBarApplicationClass, Scale3EdgeHBitmapBorder.create(windowBottomBarFrameInsets), BorderPosition.windowApplicationBottomBar);
    compoundImageReader.readScale3(bottomBarChooseDialogClass, Scale3EdgeHBitmapBorder.create(windowBottomBarFrameInsets), BorderPosition.windowChooseDialogBottomBar);

    borders[BorderPosition.segmentItem] = new SegmentedControlBorderReader().read(segmentedControlClass, segmentedControl2Class, segmentedControl3Class, segmentedControl4Class);
    borders[BorderPosition.segmentItem + 1] = new SegmentedControlBorderReader().read(segmentedControlTRClass, segmentedControl2TRClass, segmentedControl3TRClass, segmentedControl4TRClass);

    compoundImageReader.readScrollbar();

    compoundImageReader.readTitleBarAndContent(titleBarAndContentClass, Scale3EdgeHBitmapBorder.create(new FrameInsets(-33, -18, -33)), BorderPosition.window);
    compoundImageReader.readTitleBarAndContent(titleBarAndToolbarAndContent, Scale3EdgeHBitmapBorder.create(new FrameInsets(-33, -18, -33)), BorderPosition.windowWithToolbar);
    compoundImageReader.readScale9(hudTitleBarAndContentClass, BorderPosition.hudWindow, Scale9EdgeBitmapBorder.create(new FrameInsets(-7, -2, -7, -10)), 25);

    // для tree content insets left это h gap между иконкой/текстом
    borders[BorderPosition.treeItem] = OneBitmapBorder.create(Bitmap(new treeBorder()).bitmapData, new Insets(4, 0, 7, 6));
    compoundImageReader.readTreeIcons(treeSideBarIcons, new FrameInsets(10, 5), new FrameInsets(8, 6));

    var data:ByteArray = new ByteArray();
    data.writeByte(borders.length);
    for each (var border:ExternalizableResource in borders) {
      assert(borders.indexOf(border) == borders.lastIndexOf(border));
      border.writeExternal(data);
    }

    data.writeByte(icons.length);
    for each (var icon:ExternalizableResource in icons) {
      icon.writeExternal(data);
    }

    FileUtil.writeBytes(File.applicationDirectory.nativePath + "/../../aquaLaF/src/main/resources/borders", data);
    data.position = 0;

//		show(testContainer, data);

    AquaLookAndFeel._setBordersAndIcons(borders, icons);
  }

  private function show(displayObject:DisplayObjectContainer, data:ByteArray):void {
    var x:int = 100;
    var y:int = 100;

    var pendingBitmaps:Vector.<BitmapData> = new Vector.<BitmapData>();

    var n:int = data.readUnsignedByte();
    while (--n > -1 || (n == -1 && pendingBitmaps.length > 0)) {
      var bitmaps:Vector.<BitmapData>;
      if (n != -1) {
        var border:AbstractBitmapBorder;
        switch (data.readUnsignedByte()) {
          case 0: border = new Scale3EdgeHBitmapBorder(); break;
          case 1: border = new Scale1BitmapBorder(); break;
          case 2: border = new Scale9EdgeBitmapBorder(); break;
          case 3: border = new OneBitmapBorder(); break;
          case 4: border = new Scale3HBitmapBorder(); break;
          case 5: border = new Scale3VBitmapBorder(); break;
        }
        border.readExternal(data);

        if (border is AbstractMultipleBitmapBorder) {
          bitmaps = AbstractMultipleBitmapBorder(border).getBitmaps();
          if (pendingBitmaps.length > 0) {
            bitmaps = pendingBitmaps.concat(bitmaps);
            pendingBitmaps.length = 0;
          }
        }
        else {
          pendingBitmaps.push(OneBitmapBorder(border).getBitmap());
          continue;
        }
      }
      else {
        bitmaps = pendingBitmaps;
      }

      var lastHeight:Number;
      for each (var bitmapData:BitmapData in bitmaps) {
        if (bitmapData == null) {
          continue;
        }

        var bitmap:Bitmap = new Bitmap(bitmapData);
        bitmap.x = x;
        bitmap.y = y;
        displayObject.addChild(bitmap);
        x += bitmapData.width + 4;

        lastHeight = bitmapData.height;
      }

      x = 100;
      y += lastHeight < 30 ? 30 : 100;
    }

    y += 40;

    n = data.readUnsignedByte();
    var icon:BitmapIcon;
    for (var i:int = 0; i < n; i++) {
      var shape:Shape = new Shape();
      shape.x = x;
      shape.y = y;

      x += 20;

      icon = new BitmapIcon();
      icon.readExternal(data);
      icon.draw(null, shape.graphics, 5, 3);

      displayObject.addChild(shape);
    }
  }
}
}