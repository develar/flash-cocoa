package cocoa {
import cocoa.text.TextAreaUIModel;
import cocoa.text.TextUIModel;

use namespace ui;

public class TextArea extends TextInput {
  override protected function get primaryLaFKey():String {
    return "TextArea";
  }

  override protected function createDefaultUIModel():TextUIModel {
    return TextAreaUIModel.getDefault();
  }
}
}