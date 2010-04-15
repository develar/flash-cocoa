package cocoa.dialog
{
import cocoa.ComponentEvent;
import cocoa.DeferredSkinOwner;
import cocoa.Window;
import cocoa.dialog.events.DialogEvent;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;

import com.asfusion.mate.events.InjectorEvent;

import flash.display.DisplayObject;

import mx.core.FlexGlobals;
import mx.managers.PopUpManager;

public class DialogManager
{
	private var modalBoxExists:Boolean;

	public function open(window:Window, modal:Boolean = true):void
	{
		if (modal)
		{
			if (modalBoxExists)
			{
				//throw new Error("modal window already opened");
			}
			else
			{
				modalBoxExists = true;
			}
		}

		window.addEventListener(DialogEvent.OK, okOrCancelHandler);
		window.addEventListener(DialogEvent.CANCEL, okOrCancelHandler);

		if (window is DeferredSkinOwner && !DeferredSkinOwner(window).isReadyToCreateSkin)
		{
			window.addEventListener(ComponentEvent.READY_TO_CREATE_SKIN, readyToCreateSkinHandler);
		}
		else
		{
			addPopUp(window, modal);
		}
	}

	private function readyToCreateSkinHandler(event:ComponentEvent):void
	{
		addPopUp(Window(event.currentTarget), true, false);
	}

	private function addPopUp(window:Window, modal:Boolean = true, dispatchInjectorEvent:Boolean = true):void
	{
		var skin:Skin = window.skin;
		if (skin == null)
		{
			window.laf = LookAndFeelProvider(FlexGlobals.topLevelApplication).laf;
			skin = window.createView(window.laf);
			if (dispatchInjectorEvent)
			{
				skin.dispatchEvent(new InjectorEvent(window));
			}
		}

		//		skin.addEventListener(ResizeEvent.RESIZE, dialogCreationCompleteHandler);
		PopUpManager.addPopUp(skin, DisplayObject(FlexGlobals.topLevelApplication), modal);
		PopUpManager.centerPopUp(skin);
		skin.setFocus();
	}

//	private function dialogCreationCompleteHandler(event:ResizeEvent):void
//	{
//		PopUpManager.centerPopUp(Skin(event.currentTarget));
//	}

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