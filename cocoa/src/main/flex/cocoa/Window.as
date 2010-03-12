package cocoa
{
import cocoa.plaf.WindowSkin;

import org.flyti.view.pane.TitledPane;

public class Window extends Box implements TitledPane
{
	private var typedSkin:WindowSkin;

	private var _title:String;
	public function set title(value:String):void
	{
		if (value != _title)
		{
			_title = value;
			if (skin != null)
			{
				typedSkin.title = _title;
			}
		}
	}

	override protected function initializeSkin():void
	{
		typedSkin = WindowSkin(skin);

		if (_title == null && _resourceBundle != null)
		{
			_title = resourceManager.getNullableString(_resourceBundle, "windowTitle");
		}

		if (_title != null)
		{
			typedSkin.title = _title;
		}
		
		super.initializeSkin();
	}
}
}