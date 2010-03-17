package cocoa
{
import cocoa.pane.TitledPane;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.WindowSkin;

[DefaultProperty("contentView")]
public class Window extends AbstractView implements TitledPane, LookAndFeelProvider
{
	protected var mySkin:WindowSkin;

	public function Window()
	{
		super();

		listenResourceChange();
	}

	private var _title:String;
	public function set title(value:String):void
	{
		if (value != _title)
		{
			_title = value;
			if (skin != null)
			{
				mySkin.title = _title;
			}
		}
	}

	private var _contentView:View;
	public function set contentView(value:View):void
	{
		_contentView = value;
	}

	protected var _resourceBundle:String;
	public function set resourceBundle(value:String):void
	{
		_resourceBundle = value;
	}

	override protected function attachSkin():void
	{
		mySkin = WindowSkin(skin);

		if (_title == null && _resourceBundle != null)
		{
			_title = resourceManager.getNullableString(_resourceBundle, "windowTitle");
		}

		if (_title != null)
		{
			mySkin.title = _title;
		}

		if (_contentView != null)
		{
			mySkin.contentView = _contentView;
		}
		
		super.attachSkin();
	}

	private var _laf:LookAndFeel;
	public function get laf():LookAndFeel
	{
		return _laf;
	}
	public function set laf(value:LookAndFeel):void
	{
		_laf = value;
	}
}
}