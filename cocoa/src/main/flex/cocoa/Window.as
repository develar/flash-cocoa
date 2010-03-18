package cocoa
{
import cocoa.pane.TitledPane;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.WindowSkin;

import flash.events.IEventDispatcher;

import org.flyti.plexus.Injectable;

[DefaultProperty("mxmlContent")]
public class Window extends AbstractComponent implements TitledPane, LookAndFeelProvider, Injectable, IEventDispatcher
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

	private var _mxmlContent:Array;
	public function set mxmlContent(value:Array):void
	{
		_mxmlContent = value;
	}

	protected var _resourceBundle:String;
	public function set resourceBundle(value:String):void
	{
		_resourceBundle = value;
	}

	override protected function viewAttachedHandler():void
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

		if (_mxmlContent != null)
		{
			if (_mxmlContent.length > 1)
			{
				var container:Container = new Container();
				container.subviews = _mxmlContent;
				mySkin.contentView = container;
			}
			else
			{
				var view:Viewable = _mxmlContent[0];
				if (view is Component)
				{
					setContentView(Component(view));
				}
				else
				{
					mySkin.contentView = View(view);
				}
			}
			_mxmlContent = null;
		}
		
		super.viewAttachedHandler();
	}

	protected function setContentView(component:Component):void
	{
		mySkin.contentView = component.skin == null ? component.createView(laf) : component.skin;
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