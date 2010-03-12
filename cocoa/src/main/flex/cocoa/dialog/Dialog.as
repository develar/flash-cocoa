package cocoa.dialog
{
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import cocoa.PushButton;
import org.flyti.view.ViewContainer;
import org.flyti.view.Window;
import cocoa.dialog.events.DialogEvent;
import org.flyti.resources.ResourceManager;
import org.flyti.ui.KeyCode;
import org.flyti.util.Assert;
import org.flyti.view;

use namespace view;

[Event(name="ok", type="cocoa.dialog.events.DialogEvent")]
[Event(name="cancel", type="cocoa.dialog.events.DialogEvent")]

/**
 * Настройки controlBar после полного создания компонента изменить нельзя
 */
[ResourceBundle("Dialog")]
public class Dialog extends Window
{
	private static const RESOURCE_BUNDLE:String = "Dialog";

	private var controlBarInitialized:Boolean;

	view var controlBar:ViewContainer;

	private var okButton:PushButton;
	private var cancelButton:PushButton;

	public function Dialog()
	{
		super();
		
		skinParts.controlBar = HANDLER_NOT_EXISTS;
	}

	private var _valid:Boolean;
	public function set valid(value:Boolean):void
	{
		if (value != _valid)
		{
			_valid = value;
			if (okButton != null)
			{
				okButton.enabled = _valid;
			}
		}
	}

	private var _cancelVisible:Boolean = true;
	public function set cancelVisible(value:Boolean):void
	{
		if (value != _cancelVisible)
		{
			_cancelVisible = value;
			invalidateProperties();
		}
	}

	private var _okLabel:String = "okLabel";
	public function set okLabel(value:String):void
	{
		if (value != _okLabel)
		{
			_okLabel = value;
			invalidateProperties();
		}
	}

	override public function commitProperties():void
	{
		if (!controlBarInitialized)
		{
			controlBarInitialized = true;

			skin.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);

			if (_cancelVisible)
			{
				cancelButton = createControlButton(resourceManager.getString(RESOURCE_BUNDLE, "cancel"), cancelClickHandler);
				controlBar.addElement(cancelButton);
			}

			okButton = createControlButton(getOkLocalizedLabel(), okClickHandler);
			okButton.enabled = _valid;
			controlBar.addElement(okButton);
		}

		super.commitProperties();
	}

	private function cancelClickHandler(event:MouseEvent):void
	{
		cancel();
	}

	private function okClickHandler(event:MouseEvent):void
	{
		Assert.assert(_valid);
		ok();
	}

	protected function cancel():void
	{
		dispatchEvent(new DialogEvent(DialogEvent.CANCEL));
	}

	protected function ok():void
	{
		dispatchEvent(new DialogEvent(DialogEvent.OK));
	}

	private function createControlButton(label:String, clickHandler:Function):PushButton
	{
		var button:PushButton = new PushButton();
		button.label = label;
		button.addEventListener(MouseEvent.CLICK, clickHandler);

		return button;
	}

	override protected function resourcesChanged():void
	{
		super.resourcesChanged();

		if (okButton != null)
		{
			okButton.label = getOkLocalizedLabel();
		}
		if (cancelButton != null)
		{
			cancelButton.label = resourceManager.getString(RESOURCE_BUNDLE, "cancel");
		}
	}

	protected function getOkLocalizedLabel():String
	{
		return ResourceManager(resourceManager).getStringWithDefault(_resourceBundle, _okLabel, RESOURCE_BUNDLE, "ok");
	}

	private function keyDownHandler(event:KeyboardEvent):void
	{
		// Safari перехватывает cmd + period
		if (event.keyCode == Keyboard.ESCAPE || (event.ctrlKey && event.keyCode == KeyCode.PERIOD))
		{
			cancel();
		}
		else if (event.keyCode == Keyboard.ENTER && _valid)
		{
			ok();
		}
	}
}
}