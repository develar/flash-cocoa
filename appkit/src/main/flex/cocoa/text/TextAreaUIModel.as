package cocoa.text {
public class TextAreaUIModel extends TextUIModel {
  /**
   *  The default height of the control, measured in lines.
   *
   *  <p>The control's formatting styles, such as <code>fontSize</code>
   *  and <code>lineHeight</code>, are used to calculate the line height
   *  in pixels.</p>
   *
   *  <p>You would, for example, set this property to 5 if you want
   *  the height of the RichEditableText to be sufficient
   *  to display five lines of text.</p>
   *
   *  <p>If this property is <code>NaN</code> (the default),
   *  then the component's default height will be determined
   *  from the text to be displayed.</p>
   *
   *  <p>This property will be ignored if you specify an explicit height,
   *  a percent height, or both <code>top</code> and <code>bottom</code>
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
   *  it starts out very small if it has no text, grows in width as you
   *  type, and grows in height when you press Enter to start a new line.</p>
   *
   *  @see #widthInChars
   */
  public var heightInLines:int = -1;

  private static var defaultModel:TextAreaUIModel;
  public static function getDefault():TextAreaUIModel {
    if (defaultModel == null) {
      defaultModel = new TextAreaUIModel();
    }
    return defaultModel;
  }
}
}