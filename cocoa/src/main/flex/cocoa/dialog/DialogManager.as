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

	public function open(window:Window, modal:Boolean = true, autoCenter:Boolean = true):void
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
			addPopUp(window, modal, true, autoCenter);
		}
	}

	private function readyToCreateSkinHandler(event:ComponentEvent):void
	{
		addPopUp(Window(event.currentTarget), true, false);
	}

	private function addPopUp(window:Window, modal:Boolean = true, dispatchInjectorEvent:Boolean = true, autoCenter:Boolean = true):void
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
		if (autoCenter)
		{
			PopUpManager.centerPopUp(skin);
		}
		skin.setFocus();
	}

//	private function dialogCreationCompleteHandler(event:ResizeEvent):void
//	{
//		PopUpManager.centerPopUp(Skin(event.currentTarget));
//	}

	public function close(window:Window):void
	{
		window.removeEventListener(DialogEvent.OK, okOrCancelHandler);
		window.removeEventListener(DialogEvent.CANCEL, okOrCancelHandler);

		window.dispatchEvent(new DialogEvent(DialogEvent.CLOSING));

		if (modalBoxExists)
		{
			modalBoxExists = false;
		}
		PopUpManager.removePopUp(window.skin);
	}

	private function okOrCancelHandler(event:DialogEvent):void
	{
		close(Window(event.currentTarget));
	}
}
}