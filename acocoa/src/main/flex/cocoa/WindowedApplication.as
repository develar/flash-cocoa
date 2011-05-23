package cocoa {
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;

import mx.core.IUIComponent;
import mx.core.UIComponent;

[DefaultProperty("mxmlContent")]
public class WindowedApplication extends WindowedSystemManager implements LookAndFeelProvider {
  private var _laf:LookAndFeel;
  public function get laf():LookAndFeel {
    return _laf;
  }

  public function set laf(value:LookAndFeel):void {
    _laf = value;
    if (_mxmlContent != null) {
      initialized();
    }
  }

  private var _mxmlContent:Array;
  public function set mxmlContent(value:Array):void {
    _mxmlContent = value;
    if (_laf != null) {
      initialized();
    }
  }

  public function initialized():void {
    var contentView:UIComponent;
    if (_mxmlContent.length > 1) {
      var container:Container = new Container();
      container.laf = _laf;
      container.subviews = _mxmlContent;
      contentView = container;
    }
    else {
      contentView = _mxmlContent[0];
    }

    _mxmlContent = null;
    WindowInitUtil.initStage(stage);

    init(contentView);
    contentView.setActualSize(stage.stageWidth, stage.stageHeight);
    contentView.validateNow();

    stage.nativeWindow.activate();
  }

  override public function init(contentView:IUIComponent):void {
    WindowInitUtil.initMainSystemManager(this);
    preInitialize();
    super.init(contentView);
  }

  protected function preInitialize():void {

  }
}
}
