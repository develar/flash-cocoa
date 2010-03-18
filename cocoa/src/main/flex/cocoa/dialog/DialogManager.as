package cocoa.dialog
{
import cocoa.Window;
import cocoa.dialog.events.DialogEvent;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;

import com.asfusion.mate.events.InjectorEvent;

import flash.display.DisplayObject;

import mx.core.FlexGlobals;
import mx.events.ResizeEvent;
import mx.managers.PopUpManager;

public class DialogManager
{
	private var modalBoxExists:Boolean;

	public function open(box:Window, modal:Boolean = true):void
	{
		if (modal)
		{
			if (modalBoxExists)
			{
				throw new Error("modal window already opened");
			}
			else
			{
				modalBoxExists = true;
			}
		}

		box.addEventListener(DialogEvent.OK, okOrCancelHandler);
		box.addEventListener(DialogEvent.CANCEL, okOrCancelHandler);

		var skin:Skin = box.skin;
		var parent:DisplayObject = DisplayObject(FlexGlobals.topLevelApplication);
		if (skin == null)
		{
			box.laf = LookAndFeelProvider(FlexGlobals.topLevelApplication).laf;
			skin = box.createView(box.laf);
			skin.dispatchEvent(new InjectorEvent(box));
			// на данный момент у нас каждое окно имеет local event map, поэтому проблемы из-за того, что скин еще не в dispay list, нет
//			parent.dispatchEvent(new InjectorEvent(box));
		}

		skin.addEventListener(ResizeEvent.RESIZE, dialogCreationCompleteHandler);
		PopUpManager.addPopUp(skin, parent, modal);
		skin.setFocus();
	}

	private function dialogCreationCompleteHandler(event:ResizeEvent):void
	{
		PopUpManager.centerPopUp(Skin(event.currentTarget));
	}

	private function okOrCancelHandler(event:DialogEvent):void
	{
		var box:Window = Window(event.currentTarget);

		box.removeEventListener(DialogEvent.OK, okOrCancelHandler);
		box.removeEventListener(DialogEvent.CANCEL, okOrCancelHandler);

		box.dispatchEvent(new DialogEvent(DialogEvent.CLOSING));

		if (modalBoxExists)
		{
			modalBoxExists = false;
		}
		PopUpManager.removePopUp(box.skin);
	}
}
}