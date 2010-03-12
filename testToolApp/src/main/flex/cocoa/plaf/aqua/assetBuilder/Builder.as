package cocoa.plaf.aqua.assetBuilder
{
import cocoa.Border;
import cocoa.FrameInsets;
import cocoa.Icon;
import cocoa.Insets;
import cocoa.UIManager;
import cocoa.plaf.AbstractBitmapBorder;
import cocoa.plaf.ExternalizableResource;
import cocoa.plaf.Scale1HBitmapBorder;
import cocoa.plaf.Scale3HBitmapBorder;
import cocoa.plaf.Scale9BitmapBorder;
import cocoa.plaf.aqua.AquaLookAndFeel;
import cocoa.util.FileUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.filesystem.File;
import flash.utils.ByteArray;

public class Builder
{
	[Embed(source="/buttons.png")]
	private static var buttonsClass:Class;

	[Embed(source="/popUpMenu.png")]
	private static var popUpMenuClass:Class;

	private static var buttonRowsInfo:Vector.<RowInfo> = new Vector.<RowInfo>(3, true);
	buttonRowsInfo[0] = new RowInfo(Scale3HBitmapBorder.create(20, new FrameInsets(-2, 0, -2), new Insets(10, NaN, 10, 5)));
	buttonRowsInfo[1] = new RowInfo(Scale3HBitmapBorder.create(22, new FrameInsets(0, -1, 0), new Insets(10, NaN, 10, 6)));
	buttonRowsInfo[2] = new RowInfo(Scale3HBitmapBorder.create(20, new FrameInsets(-2, 0, -2), new Insets(9, NaN, 9 + 21/* width of double-arrow area */, 5)));

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
		var compoundImageReader:CompoundImageReader = new CompoundImageReader();

		var borders:Vector.<Border> = new Vector.<Border>(buttonRowsInfo.length + 2, true);
		var icons:Vector.<Icon> = new Vector.<Icon>(2, true);

		finalizeRowsInfo(buttonRowsInfo, 22);
		compoundImageReader.read(borders, buttonsClass, buttonRowsInfo);

		compoundImageReader.readMenu(borders, icons, popUpMenuClass, Scale9BitmapBorder.create(new FrameInsets(-13, -3, -13, -23), new Insets(0, 4, 0, 4)), 18);

		var data:ByteArray = new ByteArray();
		data.writeByte(borders.length);
		for each (var border:ExternalizableResource in borders)
		{
			border.writeExternal(data);
		}

		data.writeByte(icons.length);
		for each (var icon:ExternalizableResource in borders)
		{
			icon.writeExternal(data);
		}

		FileUtil.writeBytes(File.applicationDirectory.nativePath + "/../../aquaLaF/src/main/resources/borders", data);
		data.position = 0;
		
		show(testContainer, data);

		AquaLookAndFeel.setBorders(borders);
		UIManager.lookAndFeel = new AquaLookAndFeel();
	}

	private function show(displayObject:DisplayObjectContainer, data:ByteArray):void
	{
		var x:int = 100;
		var y:int = 100;

		var n:int = data.readUnsignedByte();
		while (--n > -1)
		{
			var border:AbstractBitmapBorder;
			switch (data.readUnsignedByte())
			{
				case 0: border = new Scale3HBitmapBorder(); break;
				case 1: border = new Scale1HBitmapBorder(); break;
				case 2: border = new Scale9BitmapBorder(); break;
			}
			border.readExternal(data);

			for each (var bitmapData:BitmapData in border.getBitmaps())
			{
				var bitmap:Bitmap = new Bitmap(bitmapData);
				bitmap.x = x;
				bitmap.y = y;
				displayObject.addChild(bitmap);
				x += bitmapData.width + 4;
			}

			x = 100;
			y += 30;
		}
	}
}
}