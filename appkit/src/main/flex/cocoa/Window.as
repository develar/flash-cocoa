package cocoa {
import cocoa.pane.TitledPane;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;
import cocoa.plaf.WindowSkin;

import flash.events.Event;
import flash.events.IEventDispatcher;

import org.flyti.plexus.Injectable;

[DefaultProperty("mxmlContent")]
public class Window extends TitledComponent implements TitledPane, LookAndFeelProvider, Injectable, IEventDispatcher {
  protected var mySkin:WindowSkin;
  protected var flags:uint = RESIZABLE | CLOSABLE;

  protected static const RESIZABLE:uint = 1 << 0;
  protected static const CLOSABLE:uint = 1 << 1;

  public function Window() {
    super();

    listenResourceChange();
  }

  protected var toolbar:Toolbar;

  protected final function l(key:String):String {
    return resourceManager.getString(_resourceBundle, key);
  }

  public function get resizable():Boolean {
    return (flags & RESIZABLE) != 0;
  }

  public function set resizable(value:Boolean):void {
    if (value == ((flags & RESIZABLE) == 0)) {
      value ? flags |= RESIZABLE : flags &= ~RESIZABLE;
    }
  }

  public function get closable():Boolean {
    return (flags & CLOSABLE) != 0;
  }

  public function set closable(value:Boolean):void {
    if (value == ((flags & CLOSABLE) == 0)) {
      value ? flags |= CLOSABLE : flags &= ~CLOSABLE;
    }
  }

  private var _mxmlContent:Array;
  public function set mxmlContent(value:Array):void {
    _mxmlContent = value;
  }

  protected var _resourceBundle:String;
  public function set resourceBundle(value:String):void {
    _resourceBundle = value;
  }

  public function close():void {
    dispatchEvent(new Event(Event.CLOSE));
  }

  override protected function skinAttachedHandler():void {
    super.skinAttachedHandler();

    mySkin = WindowSkin(skin);

    if (title == null && _resourceBundle != null) {
      title = resourceManager.getNullableString(_resourceBundle, "windowTitle");
    }

    if (toolbar != null) {
      mySkin.toolbar = toolbar;
    }

    if (_mxmlContent != null) {
      if (_mxmlContent.length > 1) {
        var container:Container = new Container();
        container.subviews = _mxmlContent;
        mySkin.contentView = container;
      }
      else {
        _contentView = _mxmlContent[0];
      }
      _mxmlContent = null;
    }

    if (_contentView != null) {
      if (_contentView is Component) {
        mySkin.contentView = Component(_contentView).skin == null ? Component(_contentView).createView(laf) : Component(_contentView).skin;
      }
      else {
        mySkin.contentView = View(_contentView);
      }
    }

    super.skinAttachedHandler();
  }

  private var _contentView:Viewable;
  public function get contentView():Viewable {
    return _contentView;
  }

  public function set contentView(view:Viewable):void {
    _contentView = view;
  }

  private var _laf:LookAndFeel;
  public function get laf():LookAndFeel {
    return _laf;
  }

  public function set laf(value:LookAndFeel):void {
    _laf = value;
  }

  override public function createView(laf:LookAndFeel):Skin {
    if (_laf == null) {
      _laf = laf;
    }

    return super.createView(laf);
  }
}
}