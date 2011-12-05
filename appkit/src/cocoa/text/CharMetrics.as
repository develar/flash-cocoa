package cocoa.text {
import flash.text.engine.TextLine;

public final class CharMetrics {
  public var ascent:Number;
  public var descent:Number;
  public var width:Number;
  public var height:Number;

  public function CharMetrics(textLine:TextLine) {
    ascent = textLine.ascent;
    descent = textLine.descent;
    width = textLine.textWidth;
    height = textLine.textHeight;
  }
}
}