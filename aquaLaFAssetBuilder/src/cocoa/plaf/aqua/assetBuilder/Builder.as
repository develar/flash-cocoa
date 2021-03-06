package cocoa.plaf.aqua.assetBuilder {
import cocoa.Border;
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.TextInsets;
import cocoa.border.AbstractBitmapBorder;
import cocoa.border.AbstractBorder;
import cocoa.border.AbstractMultipleBitmapBorder;
import cocoa.border.CappedSmartBorder;
import cocoa.border.OneBitmapBorder;
import cocoa.border.Scale1BitmapBorder;
import cocoa.border.Scale3EdgeHBitmapBorder;
import cocoa.border.Scale3EdgeHBitmapBorderWithSmartFrameInsets;
import cocoa.border.Scale3HBitmapBorder;
import cocoa.border.Scale3VBitmapBorder;
import cocoa.border.Scale9EdgeBitmapBorder;
import cocoa.util.Files;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filesystem.File;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

public class Builder {
  [Embed(source="../../../../../../aquaLaF/resources/assets.png")]
  private static const assetsClass:Class;

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

  [Embed(source="/Tree.border.png")]
  private static var treeBorder:Class;

  [Embed(source="/Tree.sideBar.icons.png")]
  private static var treeSideBarIcons:Class;

  private static function finalizeRowsInfo(rowsInfo:Vector.<RowInfo>, top:Number = 0):void {
    for each (var rowInfo:RowInfo in rowsInfo) {
      rowInfo.top = top;
      top += rowInfo.height;
    }
  }

  public static function build():void {
    var borders:Vector.<Border> = new Vector.<Border>(BorderPosition.totalLength, true);
    var compoundImageReader:CompoundImageReader = new CompoundImageReader(borders);

    var buttonRowsInfo:Vector.<RowInfo> = new <RowInfo>[
      // rounded push button
      new RowInfo(BorderPosition.pushButtonRounded, Scale3EdgeHBitmapBorder.create(new FrameInsets(-2, 0, -2, -3), new Insets(9, NaN, 9, 5))),
      // textured rounded push button
      new RowInfo(BorderPosition.pushButtonTexturedRounded, Scale3EdgeHBitmapBorder.create(new FrameInsets(0, 0, 0, -1), new Insets(8, NaN, 8, 6))),
      // rounded pop up button
      new RowInfo(BorderPosition.popUpButton, Scale3EdgeHBitmapBorder.create(new FrameInsets(-2, 0, -2, -3), new TextInsets(21, 9, NaN, 9 + 21/* width of double-arrow area */, 5))),
      // textured rounded pop up button
      new RowInfo(BorderPosition.popUpButtonTexturedRounded, Scale3EdgeHBitmapBorder.create(new FrameInsets(-1, 0, -1), new Insets(4, NaN, 16, 7)))
    ];
    finalizeRowsInfo(buttonRowsInfo, 22);
    compoundImageReader.read(assetsClass, buttonRowsInfo);
    // image view bezel border (imagewell border)
    borders[BorderPosition.imageView] = Scale9EdgeBitmapBorder.create(new FrameInsets(-3, -3, -3, -3), new Insets(4, 4, 4, 4)).configure(compoundImageReader.parseScale9Grid(new Rectangle(0, 352, 50, 50), new Insets(8, 8, 8, 8)));

    borders[BorderPosition.textField] = Scale9EdgeBitmapBorder.create(null, new Insets(4, 3, 4, 2)).configure(compoundImageReader.parseScale9Grid(new Rectangle(120, 332, 100, 100)));

    var icons:ByteArray = new ByteArray();
    compoundImageReader.readMenu(icons, popUpMenuClass, Scale9EdgeBitmapBorder.create(new FrameInsets(-13, -3, -13, -23), new Insets(0, 4, 0, 4)), 18);

    var windowBottomBarFrameInsets:FrameInsets = new FrameInsets(-33, 0, -33, -48);
    compoundImageReader.readScale3(bottomBarApplicationClass, Scale3EdgeHBitmapBorder.create(windowBottomBarFrameInsets), BorderPosition.windowApplicationBottomBar);
    compoundImageReader.readScale3(bottomBarChooseDialogClass, Scale3EdgeHBitmapBorder.create(windowBottomBarFrameInsets), BorderPosition.windowChooseDialogBottomBar);

    compoundImageReader.readTitleBarAndContent(titleBarAndContentClass, Scale3EdgeHBitmapBorder.create(new FrameInsets(-33, -18, -33)), BorderPosition.window);
    compoundImageReader.readTitleBarAndContent(titleBarAndToolbarAndContent, Scale3EdgeHBitmapBorder.create(new FrameInsets(-33, -18, -33)), BorderPosition.windowWithToolbar);

    // для tree content insets left это h gap между иконкой/текстом
    borders[BorderPosition.treeItem] = OneBitmapBorder.create(Bitmap(new treeBorder()).bitmapData, new Insets(4, 0, 7, 6));
    compoundImageReader.readTreeIcons(treeSideBarIcons, new FrameInsets(10, 5), new FrameInsets(8, 6));

    writeBorders(borders, icons);
  }

  private static function writeBorders(borders:Vector.<Border>, icons:ByteArray):void {
    var data:ByteArray = new ByteArray();
    data.writeByte(borders.length - 2);

    var bordersNames:Vector.<String> = new <String>["PushButton", "PushButton", "PopUpButton", "PopUpButton", "ImageView", "Menu", "MenuItem.b.highlighted",
      "Window", "Window.b.toolbar", "Window.bottomBar.application", "Window.bottomBar.chooseDialog",
      "Tree", "Tree.disclosureIcon.open", "Tree.disclosureIcon.close", "TextInput"
    ];

    var fdata:ByteArray = new ByteArray();
    fdata.writeByte(2);

    var odata:ByteArray = data;

    for (var index:int = 0; index < borders.length; index++) {
      var border:AbstractBitmapBorder = AbstractBitmapBorder(borders[index]);
      assert(borders.indexOf(border) == borders.lastIndexOf(border));

      if (index == BorderPosition.pushButtonTexturedRounded || index == BorderPosition.popUpButtonTexturedRounded) {
        data = fdata;
      }
      else {
        data = odata;
      }

      var name:String = bordersNames[index];
      data.writeUTF(name.indexOf('.') == -1 ? (name + ".b") : name);

      if (border is Scale3EdgeHBitmapBorder) {
        data.writeByte(0);
      }
      else if (border is Scale1BitmapBorder) {
        data.writeByte(1);
      }
      else if (border is Scale1BitmapBorder) {
        data.writeByte(1);
      }
      else if (border is Scale9EdgeBitmapBorder) {
        data.writeByte(2);
      }
      else if (border is OneBitmapBorder) {
        data.writeByte(3);
      }
      else if (border is Scale3HBitmapBorder) {
        data.writeByte(4);
      }
      else if (border is Scale3VBitmapBorder) {
        data.writeByte(5);
      }
      else if (border is Scale3EdgeHBitmapBorderWithSmartFrameInsets) {
        data.writeByte(6);
      }
      else if (border is CappedSmartBorder) {
        data.writeByte(7);
      }
      else {
        throw new ArgumentError();
      }

      if (border is AbstractMultipleBitmapBorder) {
        wb(data, AbstractMultipleBitmapBorder(border).getBitmaps());
      }
      else if (border is OneBitmapBorder) {
        var bitmap:BitmapData = OneBitmapBorder(border).getBitmap();
        data.writeByte(bitmap.width);
        data.writeByte(bitmap.height);
        data.writeBytes(bitmap.getPixels(bitmap.rect));
      }

      if (border.contentInsets == Insets.EMPTY) {
        data.writeByte(0);
      }
      else {
        data.writeByte(1);
        writeInsets(data, border.contentInsets);
      }

      var fi:FrameInsets = border.frameInsets;
      if (fi == AbstractBorder.EMPTY_FRAME_INSETS) {
        data.writeByte(0);
      }
      else {
        data.writeByte(1);
        data.writeByte(fi.left);
        data.writeByte(fi.top);
        data.writeByte(fi.right);
        data.writeByte(fi.bottom);
      }
    }

    data.writeBytes(icons);

    Files.writeBytes(File.applicationDirectory.nativePath + "/../../aquaLaF/resources/borders", data);
    Files.writeBytes(File.applicationDirectory.nativePath + "/../../aquaLaF/resources/frameAssets", fdata);
  }

  protected static function writeInsets(output:ByteArray, insets:Insets):void {
    output.writeByte(insets is TextInsets ? TextInsets(insets).truncatedTailMargin : -1);
    output.writeByte(insets.left);
    output.writeByte(insets.top);
    output.writeByte(insets.right);
    output.writeByte(insets.bottom);
  }

  private static function wb(output:ByteArray, bitmaps:Vector.<BitmapData>):void {
    output.writeByte(bitmaps.length);
    for each (var bitmap:BitmapData in bitmaps) {
      if (bitmap == null) {
        output.writeByte(0);
      }
      else {
        output.writeByte(bitmap.width);
        output.writeByte(bitmap.height);
        output.writeBytes(bitmap.getPixels(bitmap.rect));
      }
    }
  }
}
}