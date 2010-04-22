package cocoa.plaf.aqua.assetBuilder
{
import cocoa.Border;
import cocoa.FrameInsets;
import cocoa.Icon;
import cocoa.Insets;
import cocoa.TextInsets;
import cocoa.plaf.AbstractBitmapBorder;
import cocoa.plaf.AbstractMultipleBitmapBorder;
import cocoa.plaf.BitmapIcon;
import cocoa.plaf.ExternalizableResource;
import cocoa.plaf.OneBitmapBorder;
import cocoa.plaf.Scale1BitmapBorder;
import cocoa.plaf.Scale3EdgeHBitmapBorder;
import cocoa.plaf.Scale3HBitmapBorder;
import cocoa.plaf.Scale3VBitmapBorder;
import cocoa.plaf.Scale9BitmapBorder;
import cocoa.plaf.aqua.AquaLookAndFeel;
import cocoa.util.FileUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.filesystem.File;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

public class Builder
{
	[Embed(source="/assets.png")]
	private static var assetsClass:Class;

	[Embed(source="/popUpMenu.png")]
	private static var popUpMenuClass:Class;

	[Embed(source="/Window.bottomBar.application.png")]
	private static var bottomBarApplicationClass:Class;
	[Embed(source="/Window.titleBarAndContent.png")]
	private static var titleBarAndContentClass:Class;
	[Embed(source="/Window.titleBarAndSmallToolbarAndContent.png")]
	private static var titleBarAndSmallToolbarAndContent:Class;

	[Embed(source="/segmentedControl.png")]
	private static var segmentedControlClass:Class;

	[Embed(source="/segmentedControl2.png")]
	private static var segmentedControl2Class:Class;

	[Embed(source="/segmentedControl3.png")]
	private static var segmentedControl3Class:Class;

	[Embed(source="/segmentedControl4.png")]
	private static var segmentedControl4Class:Class;

	private static var buttonRowsInfo:Vector.<RowInfo> = new Vector.<RowInfo>(3, true);
	// rounded push button
	buttonRowsInfo[0] = new RowInfo(Scale3EdgeHBitmapBorder.create(new FrameInsets(-2, 0, -2, -2), new Insets(10, NaN, 10, 5)));
	// textured rounded push button
	buttonRowsInfo[1] = new RowInfo(Scale3EdgeHBitmapBorder.create(new FrameInsets(0, -1, 0, 0), new Insets(10, NaN, 10, 6)));
	// rounded pop up button
	buttonRowsInfo[2] = new RowInfo(Scale3EdgeHBitmapBorder.create(new FrameInsets(-2, 0, -2, -3), new TextInsets(9, NaN, 9 + 21/* width of double-arrow area */, 5, 21)));

	private function finalizeRowsInfo(rowsInfo:Vector.<RowInfo>, top:Number = 0):void
	{
		for each (var rowInfo:RowInfo in rowsInfo)
		{
			rowInfo.top = top;
			top += rowInfo.height;
		}
	}

	public function build(testContainer:DisplayObjectContainer):void
	{
		var borders:Vector.<Border> = new Vector.<Border>(buttonRowsInfo.length + 3 + 2 + 14 /* scrollbars */ + 2 /* title bar, titleBarAndSmallToolbarAndContent */, true);
		var compoundImageReader:CompoundImageReader = new CompoundImageReader(borders);

		var icons:Vector.<Icon> = new Vector.<Icon>(2, true);

		finalizeRowsInfo(buttonRowsInfo, 22);
		compoundImageReader.read(assetsClass, buttonRowsInfo);
		// image view bezel border (imagewell border)
		borders[compoundImageReader.position++] = Scale9BitmapBorder.create(new FrameInsets(-3, -3, -3, -3), new Insets(4, 4, 4, 4)).configure(compoundImageReader.parseScale9Grid(new Rectangle(0, 352, 50, 50), new Insets(8, 8, 8, 8)));

		compoundImageReader.readMenu(icons, popUpMenuClass, Scale9BitmapBorder.create(new FrameInsets(-13, -3, -13, -23), new Insets(0, 4, 0, 4)), 18);

		compoundImageReader.readScale3(bottomBarApplicationClass, Scale3EdgeHBitmapBorder.create(new FrameInsets(-33, 0, -33, -48)));
		borders[compoundImageReader.position++] = new SegmentedControlBorderReader().read(segmentedControlClass, segmentedControl2Class, segmentedControl3Class, segmentedControl4Class);

		compoundImageReader.readScrollbar();

		compoundImageReader.readTitleBarAndContent(titleBarAndContentClass, Scale3EdgeHBitmapBorder.create(new FrameInsets(-33, -18, -33)));
		compoundImageReader.readTitleBarAndContent(titleBarAndSmallToolbarAndContent, Scale3EdgeHBitmapBorder.create(new FrameInsets(-33, -18, -33)));

		var data:ByteArray = new ByteArray();
		data.writeByte(borders.length);
		for each (var border:ExternalizableResource in borders)
		{
			border.writeExternal(data);
		}

		data.writeByte(icons.length);
		for each (var icon:ExternalizableResource in icons)
		{
			icon.writeExternal(data);
		}

		FileUtil.writeBytes(File.applicationDirectory.nativePath + "/../../aquaLaF/src/main/resources/borders", data);
		data.position = 0;
		
		show(testContainer, data);

		AquaLookAndFeel._setBordersAndIcons(borders, icons);
	}

	private function show(displayObject:DisplayObjectContainer, data:ByteArray):void
	{
		var x:int = 100;
		var y:int = 100;

		var pendingBitmaps:Vector.<BitmapData> = new Vector.<BitmapData>();

		var n:int = data.readUnsignedByte();
		while (--n > -1 || (n == -1 && pendingBitmaps.length > 0))
		{
			var bitmaps:Vector.<BitmapData>;
			if (n != -1)
			{
				var border:AbstractBitmapBorder;
				switch (data.readUnsignedByte())
				{
					case 0: border = new Scale3EdgeHBitmapBorder(); break;
					case 1: border = new Scale1BitmapBorder(); break;
					case 2: border = new Scale9BitmapBorder(); break;
					case 3: border = new OneBitmapBorder(); break;
					case 4: border = new Scale3HBitmapBorder(); break;
					case 5: border = new Scale3VBitmapBorder(); break;
				}
				border.readExternal(data);

				if (border is AbstractMultipleBitmapBorder)
				{
					bitmaps = AbstractMultipleBitmapBorder(border).getBitmaps();
					if (pendingBitmaps.length > 0)
					{
						bitmaps = pendingBitmaps.concat(bitmaps);
						pendingBitmaps.length = 0;
					}
				}
				else
				{
					pendingBitmaps.push(OneBitmapBorder(border).getBitmap());
					continue;
				}
			}
			else
			{
				bitmaps = pendingBitmaps;
			}

			for each (var bitmapData:BitmapData in bitmaps)
			{
				var bitmap:Bitmap = new Bitmap(bitmapData);
				bitmap.x = x;
				bitmap.y = y;
				displayObject.addChild(bitmap);
				x += bitmapData.width + 4;
			}

			x = 100;
			y += bitmapData.height < 30 ? 30 : 100;
		}

		n = data.readUnsignedByte();
		var icon:BitmapIcon;
		for (var i:int = 0; i < n; i++)
		{
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