package cocoa.cursor
{
import cocoa.Application;
import cocoa.plaf.CursorData;
import cocoa.plaf.basic.MXMLSkin;

import flash.utils.Dictionary;

import mx.core.FlexGlobals;
import mx.managers.CursorManager;

public class CursorManager
{
	private const cursorIDMap:Dictionary = new Dictionary();

	public function setCursor(cursorType:int, priority:int):void
	{
        assert(!(cursorType in cursorIDMap), "cursor with this ID must not be in current list");

		var cursorData:CursorData = MXMLSkin(Application(FlexGlobals.topLevelApplication).getSubviewAt(0)).laf.getCursor(cursorType); // думать о cursor manager не глобальном, а на уровне того display container, в котором используется нужный курсор
//		var cursorData:CursorData = Application(FlexGlobals.topLevelApplication).laf.getCursor(cursorType);
		cursorIDMap[cursorType] = mx.managers.CursorManager.setCursor(cursorData.clazz, priority, cursorData.x, cursorData.y);
	}

	public function removeCursor(cursorType:int):void
	{
        assert(cursorType in cursorIDMap, "cursor with this ID must be in current list");

		mx.managers.CursorManager.removeCursor(cursorIDMap[cursorType]);
		delete cursorIDMap[cursorType];
	}
}
}