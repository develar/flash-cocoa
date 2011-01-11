package cocoa {
public final class TextLineInsets {
  public var rotation:String;

  public var baseline:Number;
  public var lineStartPadding:Number;
  public var lineEndPadding:Number;

  /**
   * if rotation == TextRotation.ROTATE_0, baseline is y
   * if rotation == TextRotation.ROTATE_90, baseline is x
   * @see flash.text.engine.TextLine
   */
  public function TextLineInsets(rotation:String, baseline:Number, lineStartPadding:Number, lineEndPadding:Number) {
    this.rotation = rotation;
    this.baseline = baseline;
    this.lineStartPadding = lineStartPadding;
    this.lineEndPadding = lineEndPadding;
  }
}
}