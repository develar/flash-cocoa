package cocoa.text {
[Abstract]
public class TextUIModel {
  /**
   *  The default width of the control, measured in em units.
   *
   *  <p>An em is a unit of typographic measurement
   *  equal to the point size.
   *  It is not necessarily exactly the width of the "M" character,
   *  but in many fonts the "M" is about one em wide.
   *  The control's <code>fontSize</code> style is used,
   *  to calculate the em unit in pixels.</p>
   *
   *  <p>You would, for example, set this property to 20 if you want
   *  the width of the RichEditableText to be sufficient
   *  to display about 20 characters of text.</p>
   *
   *  <p>If this property is <code>NaN</code> (the default),
   *  then the component's default width will be determined
   *  from the text to be displayed.</p>
   *
   *  <p>This property will be ignored if you specify an explicit width,
   *  a percent width, or both <code>left</code> and <code>right</code>
   *  constraints.</p>
   *
   *  <p>RichEditableText's <code>measure()</code> method uses
   *  <code>widthInChars</code> and <code>heightInLines</code>
   *  to determine the <code>measuredWidth</code>
   *  and <code>measuredHeight</code>.
   *  These are similar to the <code>cols</code> and <code>rows</code>
   *  of an HTML TextArea.</p>
   *
   *  <p>Since both <code>widthInChars</code> and <code>heightInLines</code>
   *  default to <code>NaN</code>, RichTextEditable "autosizes" by default:
   *  it starts out very samll if it has no text, grows in width as you
   *  type, and grows in height when you press Enter to start a new line.</p>
   *
   *  @see spark.primitives.heightInLines
   */
  public var widthInChars:int = -1;

  /**
   *  @copy flash.text.TextField#maxChars
   */
  public var maxChars:int;

  /**
   *  @copy flash.text.TextField#restrict
   */
  public var restrict:String;

  protected var flags:uint;
}
}