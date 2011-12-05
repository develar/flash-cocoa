package cocoa {
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;

use namespace ui;

[Abstract]
public class AbstractSkinnableComponent extends ComponentBase implements Component {
  protected var _skinClass:Class;
  public function set skinClass(value:Class):void {
    _skinClass = value;
  }

  private var _skin:Skin;
  public function get skin():Skin {
    return _skin;
  }

  override public function get actualWidth():int {
    return _skin.actualWidth;
  }

  override public function get actualHeight():int {
    return _skin.actualHeight;
  }

  override public function getMinimumWidth(hHint:int = -1):int {
    return _skin.getMinimumWidth(hHint);
  }

  override public function getMinimumHeight(wHint:int = -1):int {
    return _skin.getMinimumHeight(wHint);
  }

  override public function getPreferredWidth(hHint:int = -1):int {
    return _skin.getPreferredWidth(hHint);
  }

  override public function getPreferredHeight(wHint:int = -1):int {
    return _skin.getPreferredHeight(wHint);
  }

  override public function getMaximumWidth(hHint:int = -1):int {
    return _skin.getMaximumWidth(hHint);
  }

  override public function getMaximumHeight(wHint:int = -1):int {
    return _skin.getMaximumHeight(wHint);
  }

  override public final function init(container:Container):void {
    var laf:LookAndFeel = container.laf;
    _lafKey = _lafSubkey == null ? primaryLaFKey : (_lafSubkey + "." + primaryLaFKey);
    if (laf.controlSize != null) {
      _lafKey = laf.controlSize + "." + _lafKey;
    }

    preSkinCreate(laf);

    if (_skinClass == null) {
      _skinClass = laf.getClass(_lafKey);
    }
    _skin = new _skinClass();
    _skinClass = null;
    _skin.init(container);
    _skin.attach(this);
    skinAttached();
    listenSkinParts(_skin);
  }

  private var _lafKey:String;
  public final function get lafKey():String {
    return _lafKey;
  }

  protected var _lafSubkey:String;
  public final function set lafSubkey(value:String):void {
    _lafSubkey = value;
  }

  protected function get primaryLaFKey():String {
    throw new Error("abstract");
  }

  protected function preSkinCreate(laf:LookAndFeel):void {

  }

  protected function skinAttached():void {

  }

  public function commitProperties():void {
  }
}
}