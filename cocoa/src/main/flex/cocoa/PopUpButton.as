package cocoa
{
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.PopUpMenuController;
import cocoa.plaf.PushButtonSkin;
import cocoa.plaf.Skin;

import flash.events.Event;

import spark.utils.LabelUtil;

use namespace ui;

/**
 * @see http://developer.apple.com/Mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGControls/XHIGControls.html#//apple_ref/doc/uid/TP30000359-TPXREF132
 */
[DefaultProperty("menu")]
public class PopUpButton extends AbstractControl implements Cell
{
	private var labelChanged:Boolean = false;
	private var menuController:PopUpMenuController;

	public function get isMouseDown():Boolean
	{
		return false;
	}

	private var _menu:Menu;
	public function set menu(value:Menu):void
	{
		if (value != _menu)
		{
			if (_menu != null)
			{
				_menu.removeEventListener(Event.CHANGE, updateLabelDisplay);
			}

			_menu = value;
			_menu.addEventListener(Event.CHANGE, updateLabelDisplay);
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
		menuController = laf.getFactory(lafKey + ".menuController").newInstance();
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

	protected function updateLabelDisplay(event:Event = null):void
	{
		PushButtonSkin(skin).label = selectedItem == null ? null : LabelUtil.itemToLabel(selectedItem, null, _menu.labelFunction);
	}

	public function get selectedItem():Object
	{
		return _menu.selectedItem;
	}
	public function set selectedItem(value:Object):void
	{
		if (value != selectedItem)
		{
			_menu.selectedItem = value;
			if (_action != null)
			{
				_action();
			}
			updateLabelDisplay();
		}
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
				// иначе если у некого компонента, что использует pop up menu уже invalid properties,
				// то вызов invalidateProperties инициированнный вызовом action не приведет к commitProperties
//				AbstractView(skin).callLater(_action);
				_action();
			}
			updateLabelDisplay();
		}
	}

	override protected function get primaryLaFKey():String
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