package cocoa.text {
import cocoa.Insets;

import flash.text.engine.BreakOpportunity;

import flashx.textLayout.formats.BackgroundColor;
import flashx.textLayout.formats.TextDecoration;

/**
 * text color and text alpha my be set via argb — elementFormat relevant only for measure char metrics
 */
public class FullTextLayoutFormat extends SimpleTextLayoutFormat {
  public var backgroundARGB:uint;
  public var argb:uint = 0xff000000;

  public function FullTextLayoutFormat(textFormat:TextFormat, insets:Insets = null) {
    super(textFormat, insets);
  }

  override public function get color():* {
    return argb & 0x00ffffff;
  }

  override public function get textAlpha():* {
    return ((argb >>> 24) & 0xff) / 0xff;
  }

  override public function get backgroundColor():* {
    return backgroundARGB == 0 ? BackgroundColor.TRANSPARENT : (backgroundARGB & 0x00ffffff);
  }

  override public function get backgroundAlpha():* {
    return backgroundARGB == 0 ? 1 : (((backgroundARGB >>> 24) & 0xff) / 0xff);
  }
}
}