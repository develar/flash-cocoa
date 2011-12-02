package cocoa {
import cocoa.pane.TitledPane;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.WindowSkin;

import org.flyti.plexus.Injectable;

public class Window extends TitledComponent implements TitledPane, LookAndFeelProvider, Injectable {
  protected var mySkin:WindowSkin;
  protected var flags:uint = RESIZABLE | CLOSABLE;

  protected static const RESIZABLE:uint = 1 << 0;
  protected static const CLOSABLE:uint = 1 << 1;

  protected var toolbar:Toolbar;

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

  public function close():void {
    //!! dispatchEvent(new Event(Event.CLOSE));
  }

  override protected function skinAttached():void {
    super.skinAttached();

    mySkin = WindowSkin(skin);

    //if (title == null && _resourceBundle != null) {
    //  title = resourceManager.getNullableString(_resourceBundle, "windowTitle");
    //}

    if (toolbar != null) {
      mySkin.toolbar = toolbar;
    }

    if (_contentView != null) {
      mySkin.contentView = _contentView;
    }

    super.skinAttached();
  }

  private var _contentView:View;
  public function get contentView():View {
    return _contentView;
  }

  public function set contentView(view:View):void {
    _contentView = view;
  }

  private var _laf:LookAndFeel;
  public function get laf():LookAndFeel {
    return _laf;
  }

  public function set laf(value:LookAndFeel):void {
    _laf = value;
  }

  override protected function preSkinCreate(laf:LookAndFeel):void {
    if (_laf == null) {
      _laf = laf;
    }
  }
}
}