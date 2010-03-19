package cocoa
{
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.PopUpMenuController;
import cocoa.plaf.PushButtonSkin;
import cocoa.plaf.Skin;

import flash.display.DisplayObject;

import spark.utils.LabelUtil;

use namespace ui;

/**
 * http://developer.apple.com/Mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGControls/XHIGControls.html#//apple_ref/doc/uid/TP30000359-TPXREF132
 */
[DefaultProperty("menu")]
public class PopUpButton extends AbstractComponent implements Button
{
	private var labelChanged:Boolean = false;

	private var menuController:PopUpMenuController;

	public function PopUpButton()
	{
	}

	private var _state:int = ButtonState.off;
	public function get state():int
	{
		return _state;
	}

	private var _menu:Menu;
	public function set menu(value:Menu):void
	{
		if (value != _menu)
		{
			_menu = value;
			labelChanged = true;
			invalidateProperties();
		}
	}

	override public final function createView(laf:LookAndFeel):Skin
	{
		super.createView(laf);
		menuController = new PopUpMenuController(DisplayObject(skin), _menu, laf);
		return skin;
	}

	override public function commitProperties():void
    {
        super.commitProperties();

        if (labelChanged)
        {
            labelChanged = false;
            updateLabelDisplay();
        }
    }

	protected function updateLabelDisplay():void
	{
		PushButtonSkin(skin).label = LabelUtil.itemToLabel(selectedItem, null, _menu.labelFunction);
	}

	public function get selectedItem():Object
	{
		return "Item 1";
	}

	override public function get lafPrefix():String
	{
		return "PopUpButton";
	}
}
}