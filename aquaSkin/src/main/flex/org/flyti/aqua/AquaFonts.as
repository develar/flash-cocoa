package org.flyti.aqua
{
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;

public final class AquaFonts
{
	private static const FONT_DESCRIPTION:FontDescription = new FontDescription("Lucida Grande, Segoe UI");

	public static const SYSTEM_FONT:ElementFormat = new ElementFormat(FONT_DESCRIPTION, 13);
	public static const MENU_FONT:ElementFormat = new ElementFormat(FONT_DESCRIPTION, 14);

	public static const VIEW_FONT:ElementFormat = new ElementFormat(FONT_DESCRIPTION, 12);

	public static const SYSTEM_FONT_DISABLED:ElementFormat = SYSTEM_FONT.clone();
	SYSTEM_FONT_DISABLED.color = 0x808080;

	public static const SYSTEM_FONT_WHITE:ElementFormat = SYSTEM_FONT.clone();
	SYSTEM_FONT_WHITE.color = 0xffffff;

	public static const VIEW_FONT_WHITE:ElementFormat = VIEW_FONT.clone();
	VIEW_FONT_WHITE.color = 0xffffff;
}
}