package cocoa.text {
import flashx.textLayout.formats.ITextLayoutFormat;

public class LinkSimpleTextLayoutFormat extends SimpleTextLayoutFormat {
  private var _linkNormal:ITextLayoutFormat;
  private var _linkHover:ITextLayoutFormat;

  public function LinkSimpleTextLayoutFormat(linkNormal:SimpleTextLayoutFormat, linkHover:ITextLayoutFormat) {
    super(linkNormal.textFormat);

    _linkNormal = linkNormal;
    _linkHover = linkHover;
  }

  override public function get linkHoverFormat():* {
    return _linkHover;
  }

  override public function get linkNormalFormat():* {
    return _linkNormal;
  }

  override public function get linkActiveFormat():* {
    return _linkHover;
  }
}
}