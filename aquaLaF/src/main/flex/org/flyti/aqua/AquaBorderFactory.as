package org.flyti.aqua
{
import cocoa.Border;
import cocoa.Icon;
import cocoa.plaf.AbstractBitmapBorder;
import cocoa.plaf.BitmapIcon;
import cocoa.plaf.Scale1HBitmapBorder;
import cocoa.plaf.Scale3HBitmapBorder;
import cocoa.plaf.Scale9BitmapBorder;
import cocoa.plaf.aqua.SeparatorMenuItemBorder;

import flash.utils.ByteArray;

import org.flyti.view.GroupBorder;

public final class AquaBorderFactory
{
	[Embed(source="/borders", mimeType="application/octet-stream")]
	private static var buttonsImageData:Class;
	private static var borders:Vector.<Border>;
	private static var icons:Vector.<Icon>;

	initAssets();
	private static function initAssets():void
	{
		var data:ByteArray = new buttonsImageData();
		buttonsImageData = null;

		var n:int = data.readUnsignedByte();
		borders = new Vector.<Border>(n, true);
		var border:AbstractBitmapBorder;
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

		n = data.readUnsignedByte();
		var icon:BitmapIcon;
		icons = new Vector.<Icon>(n, true);
		for (i = 0; i < n; i++)
		{
			icon = new BitmapIcon();
			icon.readExternal(data);
			icons[i] = icon;
		}
	}

	internal static function setBorders(value:Vector.<Border>):void
	{
		borders = value;
	}

	public static function getPushButtonBorder(bezelStyle:BezelStyle):Border
	{
		return borders[bezelStyle.ordinal];
	}

	public static function getPopUpOpenButtonBorder(bezelStyle:BezelStyle):Border
	{
		return Border(borders[2 + bezelStyle.ordinal]);
	}

	public static function getPopUpMenuBorder():GroupBorder
	{
		return GroupBorder(borders[3]);
	}

	public static function get menuItemBorder():Border
	{
		return borders[4];
	}

	private static var _separatorMenuItemBorder:Border = SeparatorMenuItemBorder;
	public static function get separatorMenuItemBorder():Border
	{
		if (_separatorMenuItemBorder == null)
		{
			_separatorMenuItemBorder = new SeparatorMenuItemBorder();
		}

		return _separatorMenuItemBorder;
	}

	public static function getMenuItemStateIcon(highlighted:Boolean):Icon
	{
		return icons[highlighted ? 1 : 0];
	}
}
}