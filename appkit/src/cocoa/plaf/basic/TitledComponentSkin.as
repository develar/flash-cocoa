package cocoa.plaf.basic {
import cocoa.LabelHelper;
import cocoa.plaf.TextFormatId;
import cocoa.plaf.TitledComponentSkin;

[Abstract]
public class TitledComponentSkin extends AbstractSkin implements cocoa.plaf.TitledComponentSkin {
  protected var labelHelper:LabelHelper;

  protected function get titleTextFormatId():String {
    return TextFormatId.SYSTEM;
  }

  public function set title(value:String):void {
    if (labelHelper == null) {
      if (value == null) {
        return;
      }

      labelHelper = new LabelHelper(this, superview.laf == null ? null : superview.laf.getTextFormat(titleTextFormatId));
    }
    else if (value == labelHelper.text) {
      return;
    }

    labelHelper.text = value;

    invalidate();
  }

  override protected function doInit():void {
    super.doInit();

    if (labelHelper != null) {
      labelHelper.textFormat = superview.laf.getTextFormat(titleTextFormatId);
    }
  }
}
}