package cocoa.text {
import flash.text.engine.ElementFormat;

import flashx.textLayout.compose.ISWFContext;

public class TextFormat {
  public var swfContext:ISWFContext;
  public var format:ElementFormat;

  public function TextFormat(textFormat:ElementFormat) {
    this.format = textFormat;
  }
}
}