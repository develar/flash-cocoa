package cocoa.text {
import flash.text.engine.ElementFormat;

public class TextFormat {
  public var swfContext:SwfContext;
  public var format:ElementFormat;
  // auto calculated
  public var charMetrics:CharMetrics;

  public function TextFormat(textFormat:ElementFormat) {
    this.format = textFormat;
  }
}
}