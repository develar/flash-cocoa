package cocoa
{
import cocoa.pane.TitledPane;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;
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

	protected var toolbar:Toolbar;

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

	override protected function skinAttachedHandler():void
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

		if (toolbar != null)
		{
			mySkin.toolbar = toolbar;
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
				_contentView = _mxmlContent[0];
			}
			_mxmlContent = null;
		}

		if (_contentView != null)
		{
			if (_contentView is Component)
			{
				mySkin.contentView = Component(_contentView).skin == null ? Component(_contentView).createView(laf) : Component(_contentView).skin;
			}
			else
			{
				mySkin.contentView = View(_contentView);
			}
			_contentView = null;
		}
		
		super.skinAttachedHandler();
	}

	private var _contentView:Viewable;
	public function set contentView(view:Viewable):void
	{
		_contentView = view;
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

	override public function createView(laf:LookAndFeel):Skin
	{
		if (_laf == null)
		{
			_laf = laf;
		}
		
		return super.createView(laf);
	}
}
}