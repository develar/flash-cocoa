package cocoa.plaf.basic {
import cocoa.LabelHelper;
import cocoa.plaf.TextFormatId;
import cocoa.plaf.TitledComponentSkin;

[Abstract]
public class TitledComponentSkin extends AbstractSkin implements cocoa.plaf.TitledComponentSkin {
  protected var labelHelper:LabelHelper;

  protected function get titleTextFormatID():String {
    return TextFormatId.SYSTEM;
  }

  public function set title(value:String):void {
    if (labelHelper == null) {
      if (value == null) {
        return;
      }

      labelHelper = new LabelHelper(this, laf == null ? null : laf.getTextFormat(titleTextFormatID));
    }
    else if (value == labelHelper.text) {
      return;
    }

    labelHelper.text = value;

    invalidateSize();
    invalidateDisplayList();
  }

  override protected function createChildren():void {
    super.createChildren();

    if (labelHelper != null) {
      labelHelper.textFormat = laf.getTextFormat(titleTextFormatID);
    }
  }
}
}