package cocoa.plaf.aqua
{
import cocoa.Border;
import cocoa.FrameInsets;
import cocoa.Icon;
import cocoa.SingletonClassFactory;
import cocoa.plaf.AbstractBitmapBorder;
import cocoa.plaf.AbstractLookAndFeel;
import cocoa.plaf.BitmapIcon;
import cocoa.plaf.MenuSkin;
import cocoa.plaf.OneBitmapBorder;
import cocoa.plaf.Scale1BitmapBorder;
import cocoa.plaf.Scale3EdgeHBitmapBorder;
import cocoa.plaf.Scale3HBitmapBorder;
import cocoa.plaf.Scale3VBitmapBorder;
import cocoa.plaf.Scale9BitmapBorder;
import cocoa.plaf.SegmentedControlController;
import cocoa.plaf.SliderNumericStepperSkin;
import cocoa.plaf.basic.BoxSkin;
import cocoa.plaf.basic.IconButtonSkin;
import cocoa.plaf.basic.ListViewSkin;

import flash.utils.ByteArray;

import mx.core.ClassFactory;

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

		const scrollbarBorderPosition:int = 9;

		data["SystemFont"] = AquaFonts.SYSTEM_FONT;
		data["SystemFont.disabled"] = AquaFonts.SYSTEM_FONT_DISABLED;
		data["SystemFont.highlighted"] = AquaFonts.SYSTEM_FONT_HIGHLIGHTED;
		data["SmallSystemFont.emphasized"] = AquaFonts.SMALL_EMPHASIZED_SYSTEM_FONT;

		data["ViewFont"] = AquaFonts.VIEW_FONT;
		data["ViewFont.highlighted"] = AquaFonts.VIEW_FONT_HIGHLIGHTED;

		data["ImageView.border"] = borders[3];

		data["Box"] = BoxSkin;

		data["Dialog"] = WindowSkin;
		data["HUDWindow"] = HUDWindowSkin;
		data["Window.border"] = borders[scrollbarBorderPosition + 14];
		data["Window.border.smallToolbar"] = borders[scrollbarBorderPosition + 15];
		data["Window.bottomBar.application"] = borders[6];

		data["SourceListView"] = SourceListViewSkin;
		data["ListView"] = ListViewSkin;
		data["ListView.border"] = new ListViewBorder();

		data["TabView"] = TabViewSkin;
		data["TabView.borderless"] = BorderlessTabViewSkin;
		data["TabView.segmentedControlController"] = new SingletonClassFactory(SegmentedControlController);

		data["PushButton"] = PushButtonSkin;
		data["PushButton.border"] = borders[BezelStyle.rounded.ordinal];

		data["IconButton"] = IconButtonSkin;

		data["PopUpButton"] = PushButtonSkin;
		data["PopUpButton.border"] = borders[2 + BezelStyle.rounded.ordinal];
		data["PopUpButton.menuController"] = new ClassFactory(PopUpMenuController);
		
		data["Menu"] = MenuSkin;
		data["Menu.border"] = borders[4];
		data["Menu.itemFactory"] = new ClassFactory(MenuItemRenderer);

		data["MenuItem.onStateIcon"] = icons[0];
		data["MenuItem.onStateIcon.highlighted"] = icons[1];

		data["MenuItem.border"] = new MenuItemBorder(borders[5].contentInsets);
		data["MenuItem.border.highlighted"] = borders[5];
		data["MenuItem.separatorBorder"] = new SeparatorMenuItemBorder();

		data["SliderNumericStepper"] = SliderNumericStepperSkin;

		data["SegmentItem.border"] = borders[7];
		Scale1BitmapBorder(borders[7]).frameInsets = new FrameInsets(0, 0, 0, -3);

		data["Scrollbar.track.v"] = borders[scrollbarBorderPosition];
		data["Scrollbar.track.h"] = borders[scrollbarBorderPosition + 1];

		data["Scrollbar.decrementButton.h"] = borders[scrollbarBorderPosition + 2];
		data["Scrollbar.decrementButton.h.highlighted"] = borders[scrollbarBorderPosition + 3];

		data["Scrollbar.incrementButton.h"] = borders[scrollbarBorderPosition + 4];
		data["Scrollbar.incrementButton.h.highlighted"] = borders[scrollbarBorderPosition + 5];

		data["Scrollbar.decrementButton.v"] = borders[scrollbarBorderPosition + 6];
		data["Scrollbar.decrementButton.v.highlighted"] = borders[scrollbarBorderPosition + 7];

		data["Scrollbar.incrementButton.v"] = borders[scrollbarBorderPosition + 8];
		data["Scrollbar.incrementButton.v.highlighted"] = borders[scrollbarBorderPosition + 9];

		data["Scrollbar.thumb.v"] = borders[scrollbarBorderPosition + 10];
		data["Scrollbar.thumb.h"] = borders[scrollbarBorderPosition + 11];

		data["Scrollbar.track.v.off"] = borders[scrollbarBorderPosition + 12];
		data["Scrollbar.track.h.off"] = borders[scrollbarBorderPosition + 13];
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
				case 0: border = new Scale3EdgeHBitmapBorder(); break;
				case 1: border = new Scale1BitmapBorder(); break;
				case 2: border = new Scale9BitmapBorder(); break;
				case 3: border = new OneBitmapBorder(); break;
				case 4: border = new Scale3HBitmapBorder(); break;
				case 5: border = new Scale3VBitmapBorder(); break;
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
import flash.text.engine.FontWeight;

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
	private static const FONT_DESCRIPTION:FontDescription = new FontDescription("Lucida Grande, Segoe UI, Sans");

	public static const SYSTEM_FONT:ElementFormat = new ElementFormat(FONT_DESCRIPTION, 13);
	public static const MENU_FONT:ElementFormat = new ElementFormat(FONT_DESCRIPTION, 14);

	public static const VIEW_FONT:ElementFormat = new ElementFormat(FONT_DESCRIPTION, 12);

	public static const SYSTEM_FONT_DISABLED:ElementFormat = SYSTEM_FONT.clone();
	SYSTEM_FONT_DISABLED.color = 0x808080;

	public static const SYSTEM_FONT_HIGHLIGHTED:ElementFormat = SYSTEM_FONT.clone();
	SYSTEM_FONT_HIGHLIGHTED.color = 0xffffff;

	public static const SMALL_EMPHASIZED_SYSTEM_FONT:ElementFormat = new ElementFormat(new FontDescription("Lucida Grande, Segoe UI, Sans", FontWeight.BOLD), 11);

	public static const VIEW_FONT_HIGHLIGHTED:ElementFormat = VIEW_FONT.clone();
	VIEW_FONT_HIGHLIGHTED.color = 0xffffff;
}