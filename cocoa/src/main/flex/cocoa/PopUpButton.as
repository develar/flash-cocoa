package cocoa
{
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.PopUpMenuController;
import cocoa.plaf.PushButtonSkin;
import cocoa.plaf.Skin;

import spark.utils.LabelUtil;

use namespace ui;

/**
 * http://developer.apple.com/Mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGControls/XHIGControls.html#//apple_ref/doc/uid/TP30000359-TPXREF132
 */
[DefaultProperty("menu")]
public class PopUpButton extends AbstractControl implements Button
{
	private var labelChanged:Boolean = false;

	private var menuController:PopUpMenuController;

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
			if (menuController != null)
			{
				menuController.menu = _menu;
			}
			labelChanged = true;
			invalidateProperties();
		}
	}

	override public final function createView(laf:LookAndFeel):Skin
	{
		super.createView(laf);
		menuController = laf.getFactory(lafPrefix + ".menuController").newInstance();
		menuController.initialize(this, _menu, laf);
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
		return _menu.selectedItem;
	}

	public function get selectedIndex():int
	{
		return _menu.selectedIndex;
	}
	public function set selectedIndex(value:int):void
	{
		if (value != selectedIndex)
		{
			_menu.selectedIndex = value;
			if (_action != null)
			{
				_action();
			}
			updateLabelDisplay();
		}
	}

	override public function get lafPrefix():String
	{
		return "PopUpButton";
	}

	override public function get objectValue():Object
	{
		return selectedItem;
	}

	override public function set objectValue(value:Object):void
	{
		_menu.selectedItem = value;
	}
}
}