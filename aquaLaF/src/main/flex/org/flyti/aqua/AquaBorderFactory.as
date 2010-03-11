package org.flyti.aqua
{
import flash.utils.ByteArray;

import org.flyti.view.Border;
import org.flyti.view.ButtonBorder;
import org.flyti.view.GroupBorder;
import org.flyti.view.ListItemRendererBorder;

public final class AquaBorderFactory
{
	[Embed(source="/borders", mimeType="application/octet-stream")]
	private static var buttonsImageData:Class;
	private static var borders:Vector.<Border>;

	initAssets();
	private static function initAssets():void
	{
		var data:ByteArray = new buttonsImageData();
		buttonsImageData = null;

		var n:int = data.readUnsignedByte();
		borders = new Vector.<Border>(n, true);
		var border:AbstractBorder;
		for (var i:int = 0; i < n; i++)
		{
			switch (data.readUnsignedByte())
			{
				case 0: border = new Scale3HBitmapBorder(); break;
				case 1: border = new Scale1HBitmapBorder(); break;
				case 2: border = new Scale9BitmapBorder(); break;
			}
			border.readExternal(data);
			borders[i] = border;
		}
	}

	internal static function setBorders(value:Vector.<Border>):void
	{
		borders = value;
	}

	public static function getPushButtonBorder(bezelStyle:BezelStyle):ButtonBorder
	{
		return ButtonBorder(borders[bezelStyle.ordinal]);
	}

	public static function getPopUpOpenButtonBorder(bezelStyle:BezelStyle):ButtonBorder
	{
		return ButtonBorder(borders[2 + bezelStyle.ordinal]);
	}

	public static function getPopUpMenuBorder():GroupBorder
	{
		return GroupBorder(borders[3]);
	}

	public static function getMenuItemBorder():ListItemRendererBorder
	{
		return ListItemRendererBorder(borders[4]);
	}
}
}