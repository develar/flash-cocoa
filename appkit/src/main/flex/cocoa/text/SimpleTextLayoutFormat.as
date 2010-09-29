package cocoa.text {
import cocoa.Insets;

import flash.text.engine.BreakOpportunity;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;

import flashx.textLayout.formats.BackgroundColor;
import flashx.textLayout.formats.BaselineOffset;
import flashx.textLayout.formats.BlockProgression;
import flashx.textLayout.formats.ClearFloats;
import flashx.textLayout.formats.Direction;
import flashx.textLayout.formats.FormatValue;
import flashx.textLayout.formats.ITextLayoutFormat;
import flashx.textLayout.formats.LeadingModel;
import flashx.textLayout.formats.LineBreak;
import flashx.textLayout.formats.ListStylePosition;
import flashx.textLayout.formats.ListStyleType;
import flashx.textLayout.formats.TextAlign;
import flashx.textLayout.formats.TextDecoration;
import flashx.textLayout.formats.TextJustify;
import flashx.textLayout.formats.VerticalAlign;
import flashx.textLayout.formats.WhiteSpaceCollapse;

public class SimpleTextLayoutFormat implements ITextLayoutFormat {
  private var fontDescription:FontDescription;
  private var elementFormat:ElementFormat;

  public function SimpleTextLayoutFormat(textFormat:TextFormat, insets:Insets = null) {
    _textFormat = textFormat;
    elementFormat = _textFormat.format;
    fontDescription = textFormat.format.fontDescription;

    this.insets = insets == null ? Insets.EMPTY : insets;
  }

  private var _textFormat:TextFormat;
  public function get textFormat():TextFormat {
    return _textFormat;
  }

  public function get color():* {
    return elementFormat.color;
  }

  public function get backgroundColor():* {
    return BackgroundColor.TRANSPARENT;
  }

  public function get lineThrough():* {
    return false;
  }

  public function get textAlpha():* {
    return elementFormat.alpha;
  }

  public function get backgroundAlpha():* {
    return 1;
  }

  public function get fontSize():* {
    return elementFormat.fontSize;
  }

  public function get baselineShift():* {
    return elementFormat.baselineShift;
  }

  public function get trackingLeft():* {
    return elementFormat.trackingLeft;
  }

  public function get trackingRight():* {
    return elementFormat.trackingRight;
  }

  public function get lineHeight():* {
    return "120%";
  }

  public function get breakOpportunity():* {
    return BreakOpportunity.AUTO;
  }

  public function get digitCase():* {
    return elementFormat.digitCase;
  }

  public function get digitWidth():* {
    return elementFormat.digitWidth;
  }

  public function get dominantBaseline():* {
    return elementFormat.dominantBaseline;
  }

  public function get kerning():* {
    return elementFormat.kerning;
  }

  public function get ligatureLevel():* {
    return elementFormat.ligatureLevel;
  }

  public function get alignmentBaseline():* {
    return elementFormat.alignmentBaseline;
  }

  public function get locale():* {
    return elementFormat.locale;
  }

  public function get typographicCase():* {
    return elementFormat.typographicCase;
  }

  public function get fontFamily():* {
    return fontDescription.fontName;
  }

  public function get textDecoration():* {
    return TextDecoration.NONE;
  }

  public function get fontWeight():* {
    return fontDescription.fontWeight;
  }

  public function get fontStyle():* {
    return fontDescription.fontPosture;
  }

  public function get whiteSpaceCollapse():* {
    return WhiteSpaceCollapse.COLLAPSE;
  }

  public function get renderingMode():* {
    return fontDescription.renderingMode;
  }

  public function get cffHinting():* {
    return fontDescription.cffHinting;
  }

  public function get fontLookup():* {
    return fontDescription.fontLookup;
  }

  public function get textRotation():* {
    return elementFormat.textRotation;
  }

  public function get textIndent():* {
    return 0;
  }

  public function get paragraphStartIndent():* {
    return 0;
  }

  public function get paragraphEndIndent():* {
    return 0;
  }

  public function get paragraphSpaceBefore():* {
    return 0;
  }

  public function get paragraphSpaceAfter():* {
    return 0;
  }

  private var _textAlign:String = TextAlign.START;
  public function get textAlign():* {
    return _textAlign;
  }

  public function set $textAlign(value:String):void {
    _textAlign = value;
  }

  public function get textAlignLast():* {
    return TextAlign.START;
  }

  public function get textJustify():* {
    return TextJustify.INTER_WORD;
  }

  public function get justificationRule():* {
    return FormatValue.AUTO;
  }

  public function get justificationStyle():* {
    return FormatValue.AUTO;
  }

  public function get direction():* {
    return Direction.LTR;
  }

  public function get tabStops():* {
    return null;
  }

  public function get leadingModel():* {
    return LeadingModel.AUTO;
  }

  public function get columnGap():* {
    return 20;
  }

//  private var insets:Insets = Insets.EMPTY;
  private var insets:Insets;

  public function get paddingLeft():* {
    return insets.left;
  }

  public function get paddingTop():* {
    return insets.top;
  }

  public function get paddingRight():* {
    return insets.right;
  }

  public function get paddingBottom():* {
    return insets.bottom;
  }

  public function get columnCount():* {
    return FormatValue.AUTO;
  }

  public function get columnWidth():* {
    return FormatValue.AUTO;
  }

  public function get firstBaselineOffset():* {
    return BaselineOffset.AUTO;
  }

  private var _verticalAlign:String = VerticalAlign.TOP;
  public function get verticalAlign():* {
    return _verticalAlign;
  }

  public function set $verticalAlign(value:String):void {
    _verticalAlign = value;
  }

  public function get blockProgression():* {
    return BlockProgression.TB;
  }

  private var _lineBreak:String = LineBreak.TO_FIT;
  public function get lineBreak():* {
    return _lineBreak;
  }

  public function set $lineBreak(value:String):void {
    _lineBreak = value;
  }

  public function get listStyleType():* {
    return ListStyleType.DISC;
  }

  public function get listStylePosition():* {
    return ListStylePosition.OUTSIDE;
  }

  public function get listAutoPadding():* {
    return 40;
  }

  public function get clearFloats():* {
    return ClearFloats.NONE;
  }
}
}