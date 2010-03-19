package cocoa.plaf.aqua
{
import cocoa.Border;
import cocoa.Icon;
import cocoa.plaf.AbstractBitmapBorder;
import cocoa.plaf.AbstractLookAndFeel;
import cocoa.plaf.BitmapIcon;
import cocoa.plaf.BoxSkin;
import cocoa.plaf.MenuSkin;
import cocoa.plaf.Scale1HBitmapBorder;
import cocoa.plaf.Scale3HBitmapBorder;
import cocoa.plaf.Scale9BitmapBorder;

import flash.utils.ByteArray;

import mx.core.ClassFactory;

import org.flyti.aqua.SourceListSkin;
import org.flyti.aqua.TabSkin;

public class AquaLookAndFeel extends AbstractLookAndFeel
{
	[Embed(source="/borders", mimeType="application/octet-stream")]
	private static var assetsDataClass:Class;
	private static var borders:Vector.<Border>;
	private static var icons:Vector.<Icon>;

	public function AquaLookAndFeel()
	{
		initialize();
	}

	protected function initialize():void
	{
		initAssets();

		data["SystemFont"] = AquaFonts.SYSTEM_FONT;
		data["SystemFont.disabled"] = AquaFonts.SYSTEM_FONT_DISABLED;
		data["SystemFont.highlighted"] = AquaFonts.SYSTEM_FONT_HIGHLIGHTED;

		data["Box"] = BoxSkin;

		data["Dialog"] = WindowSkin;
		data["Window.border"] = new WindowBorder();
		data["Window.bottomBar.application"] = borders[5];

		data["SourceListView"] = SourceListSkin;
		data["TabView"] = TabSkin;

		data["PushButton"] = PushButtonSkin;
		data["PushButton.border"] = borders[BezelStyle.rounded.ordinal];
//		data["PushButton.border.texturedRounded"] = borders[BezelStyle.texturedRounded.ordinal];

		data["PopUpButton"] = PushButtonSkin;
		data["PopUpButton.border"] = borders[2 + BezelStyle.rounded.ordinal];
//		data["PopUpButton.openButton.skin"] = PopUpOpenButtonSkin;
		data["Menu"] = MenuSkin;
		data["Menu.border"] = borders[3];
		data["Menu.itemFactory"] = new ClassFactory(MenuItemRenderer);

		data["MenuItem.onStateIcon"] = icons[0];
		data["MenuItem.onStateIcon.highlighted"] = icons[1];

		data["MenuItem.border"] = new MenuItemBorder(borders[4].contentInsets);
		data["MenuItem.border.highlighted"] = borders[4];
		data["MenuItem.separatorBorder"] = new SeparatorMenuItemBorder();
	}

	private static function initAssets():void
	{
		if (borders != null)
		{
			return;
		}

		var data:ByteArray = new assetsDataClass();
		assetsDataClass = null;

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

	public static function _setBordersAndIcons(borders:Vector.<Border>, icons:Vector.<Icon>):void
	{
		AquaLookAndFeel.borders = borders;
		AquaLookAndFeel.icons = icons;
	}

	private var windowFrameLookAndFeel:WindowFrameLookAndFeel;
	public function createWindowFrameLookAndFeel():WindowFrameLookAndFeel
	{
		if (windowFrameLookAndFeel == null)
		{
			windowFrameLookAndFeel = new WindowFrameLookAndFeel(borders, this);
		}
		return windowFrameLookAndFeel;
	}
}
}

import cocoa.Border;
import cocoa.plaf.AbstractLookAndFeel;
import cocoa.plaf.aqua.AquaLookAndFeel;
import cocoa.plaf.aqua.BezelStyle;

import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;

final class WindowFrameLookAndFeel extends AbstractLookAndFeel
{
	public function WindowFrameLookAndFeel(borders:Vector.<Border>, parent:AquaLookAndFeel)
	{
		initialize(borders);
		this.parent = parent;
	}

	private function initialize(borders:Vector.<Border>):void
	{
		data["PushButton.border"] = borders[BezelStyle.texturedRounded.ordinal];
	}
}

final class AquaFonts
{
	private static const FONT_DESCRIPTION:FontDescription = new FontDescription("Lucida Grande, Segoe UI");

	public static const SYSTEM_FONT:ElementFormat = new ElementFormat(FONT_DESCRIPTION, 13);
	public static const MENU_FONT:ElementFormat = new ElementFormat(FONT_DESCRIPTION, 14);

	public static const VIEW_FONT:ElementFormat = new ElementFormat(FONT_DESCRIPTION, 12);

	public static const SYSTEM_FONT_DISABLED:ElementFormat = SYSTEM_FONT.clone();
	SYSTEM_FONT_DISABLED.color = 0x808080;

	public static const SYSTEM_FONT_HIGHLIGHTED:ElementFormat = SYSTEM_FONT.clone();
	SYSTEM_FONT_HIGHLIGHTED.color = 0xffffff;

	public static const VIEW_FONT_WHITE:ElementFormat = VIEW_FONT.clone();
	VIEW_FONT_WHITE.color = 0xffffff;
}