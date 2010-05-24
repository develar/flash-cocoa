package cocoa
{
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;

import flashx.textLayout.formats.BlockProgression;
import flashx.textLayout.formats.ITextLayoutFormat;

import mx.styles.IStyleClient;

internal class TextLayoutFormat implements ITextLayoutFormat
{
	private var elementFormat:ElementFormat;
	private var fontDescription:FontDescription;

	private var client:IStyleClient;

	public function TextLayoutFormat(client:IStyleClient, elementFormat:ElementFormat)
	{
		this.client = client;

		this.elementFormat = elementFormat;
		fontDescription = elementFormat.fontDescription;
	}

	public function get color():*
	{
		return elementFormat.color;
	}

	public function get backgroundColor():*
	{
		return undefined;
	}

	public function get lineThrough():*
	{
		return false;
	}

	public function get textAlpha():*
	{
		return elementFormat.alpha;
	}

	public function get backgroundAlpha():*
	{
		return undefined;
	}

	public function get fontSize():*
	{
		return elementFormat.fontSize;
	}

	public function get baselineShift():*
	{
		return elementFormat.baselineShift;
	}

	public function get trackingLeft():*
	{
		return elementFormat.trackingLeft;
	}

	public function get trackingRight():*
	{
		return elementFormat.trackingRight;
	}

	public function get lineHeight():*
	{
		return undefined;
	}

	public function get breakOpportunity():*
	{
		return null;
	}

	public function get digitCase():*
	{
		return elementFormat.digitCase;
	}

	public function get digitWidth():*
	{
		return elementFormat.digitWidth;
	}

	public function get dominantBaseline():*
	{
		return elementFormat.dominantBaseline;
	}

	public function get kerning():*
	{
		return elementFormat.kerning;
	}

	public function get ligatureLevel():*
	{
		return elementFormat.ligatureLevel;
	}

	public function get alignmentBaseline():*
	{
		return elementFormat.alignmentBaseline;
	}

	public function get locale():*
	{
		return elementFormat.locale;
	}

	public function get typographicCase():*
	{
		return elementFormat.typographicCase;
	}

	public function get fontFamily():*
	{
		return fontDescription.fontName;
	}

	public function get textDecoration():*
	{
		return undefined;
	}

	public function get fontWeight():*
	{
		return fontDescription.fontWeight;
	}

	public function get fontStyle():*
	{
		return fontDescription.fontPosture;
	}

	public function get whiteSpaceCollapse():*
	{
		return undefined;
	}

	public function get renderingMode():*
	{
		return fontDescription.renderingMode;
	}

	public function get cffHinting():*
	{
		return fontDescription.cffHinting;
	}

	public function get fontLookup():*
	{
		return fontDescription.fontLookup;
	}

	public function get textRotation():*
	{
		return elementFormat.textRotation;
	}

	public function get textIndent():*
	{
		return undefined;
	}

	public function get paragraphStartIndent():*
	{
		return undefined;
	}

	public function get paragraphEndIndent():*
	{
		return undefined;
	}

	public function get paragraphSpaceBefore():*
	{
		return undefined;
	}

	public function get paragraphSpaceAfter():*
	{
		return undefined;
	}

	public function get textAlign():*
	{
		return client.getStyle("textAlign");
	}

	public function get textAlignLast():*
	{
		return undefined;
	}

	public function get textJustify():*
	{
		return undefined;
	}

	public function get justificationRule():*
	{
		return undefined;
	}

	public function get justificationStyle():*
	{
		return undefined;
	}

	public function get direction():*
	{
		return undefined;
	}

	public function get tabStops():*
	{
		return undefined;
	}

	public function get leadingModel():*
	{
		return undefined;
	}

	public function get columnGap():*
	{
		return undefined;
	}

	public function get paddingLeft():*
	{
		return client.getStyle("paddingLeft");
	}

	public function get paddingTop():*
	{
		return client.getStyle("paddingTop");
	}

	public function get paddingRight():*
	{
		return client.getStyle("paddingRight");
	}

	public function get paddingBottom():*
	{
		return client.getStyle("paddingBottom");
	}

	public function get columnCount():*
	{
		return undefined;
	}

	public function get columnWidth():*
	{
		return undefined;
	}

	public function get firstBaselineOffset():*
	{
		return undefined;
	}

	public function get verticalAlign():*
	{
		return client.getStyle("verticalAlign");
	}

	public function get blockProgression():*
	{
		return BlockProgression.TB;
	}

	public function get lineBreak():*
	{
		return client.getStyle("lineBreak");
	}
}
}