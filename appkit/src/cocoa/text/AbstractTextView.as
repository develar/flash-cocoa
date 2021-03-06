package cocoa.text {
import cocoa.ControlView;

import flash.errors.IllegalOperationError;
import flash.geom.Rectangle;

import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.elements.Configuration;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.formats.ITextLayoutFormat;
import flashx.textLayout.tlf_internal;

import spark.core.NavigationUnit;

use namespace tlf_internal;

[Abstract]
//internal class AbstractTextView extends AbstractView implements IViewport {
internal class AbstractTextView extends ControlView {
  private static var classInitialized:Boolean = false;

  protected static var configuration:Configuration;

  public function AbstractTextView() {
    super();

    if (!classInitialized) {
      initClass();
    }
  }

  /**
   *  This method initializes the static vars of this class.
   *  Rather than calling it at static initialization time, we call it in the constructor to do the class initialization when the first instance is created.
   *  (It does an immediate return if it has already run.)
   *  By doing so, we avoid any static initialization issues related to whether this class or the TLF classes
   *  that it uses are initialized first.
   */
  private static function initClass():void {
    configuration = Configuration(TextContainerManager.defaultConfiguration).clone();
    configuration.manageEnterKey = false;

    classInitialized = true;
  }

  [Abstract]
  protected function get scrollController():ScrollController {
    throw new IllegalOperationError();
  }

  protected var _text:String = "";
  protected var textChanged:Boolean = false;

  protected var sourceIsText:Boolean = true;

  [Bindable("change")]
  /**
   *  The text String displayed by this component.
   *
   *  <p>Setting this property affects the <code>textFlow</code> property
   *  and vice versa.</p>
   *
   *  <p>If you set the <code>text</code> to a String such as
   *  <code>"Hello World"</code> and get the <code>textFlow</code>,
   *  it will be a TextFlow containing a single ParagraphElement
   *  with a single SpanElement.</p>
   *
   *  <p>If the text contains explicit line breaks --
   *  CR ("\r"), LF ("\n"), or CR+LF ("\r\n") --
   *  then the content will be set to a TextFlow
   *  which contains multiple paragraphs, each with one span.</p>
   *
   *  <p>Setting this property also affects the properties
   *  specifying the control's scroll position and the text selection.
   *  It resets the <code>horizontalScrollPosition</code>
   *  and <code>verticalScrollPosition</code> to 0,
   *  and it sets the <code>selectionAnchorPosition</code>
   *  and <code>selectionActivePosition</code>
   *  to -1 to clear the selection.</p>
   *
   *  @default ""
   *
   *  @see #textFlow
   *  @see #horizontalScrollPosition
   *  @see #verticalScrollPosition
   */
  public function get text():String {
    if (_text == null) {
      _text = _textFlow.getText();
    }
    return _text;
  }

  /**
   * This will create a TextFlow with a single paragraph with a single span with exactly the text specified.
   * If there is whitespace and line breaks in the text, they will remain, regardless of the settings of
   * the lineBreak and whiteSpaceCollapse styles.
   */
  public function set text(value:String):void {
    // Treat setting the 'text' to null as if it were set to the empty String (which is the default state).
    if (value == null) {
      value = "";
    }

    // If value is the same as _text, make sure if was not produced from setting 'textFlow' or 'content'.  For example, if you set a TextFlow
    // corresponding to "Hello <span color="OxFF0000">World</span>" and then get the 'text', it will be the String "Hello World"
    // But if you then set the 'text' to "Hello World" this represents a change: the "World" should no longer be red.
    // Note: this is needed to stop two-binding from recursing.
    if (sourceIsText && text == value) {
      return;
    }

    _text = value;
    textChanged = true;
    sourceIsText = true;

    // Of 'text', 'textFlow', and 'content', the last one set wins.
    textFlowChanged = false;

    // The other two are now invalid and must be recalculated when needed.
    _textFlow = null;

    //invalidateProperties();
    //invalidateSize();
    //invalidateDisplayList();

    //if (hasEventListener(FlexEvent.VALUE_COMMIT)) {
    //  dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    //}
  }

  protected var _textFlow:TextFlow;
  protected var textFlowChanged:Boolean = false;

  public function get textFlow():TextFlow {
    return _textFlow;
  }

  protected var _textFormat:ITextLayoutFormat;
  public function set textFormat(value:ITextLayoutFormat):void {
    _textFormat = value;
  }

  protected final function get effectiveTextFormat():ITextLayoutFormat {
    return _textFormat == null ? _textFlow.computedFormat : _textFormat;
  }

  protected var _selectable:Boolean = true;
  public function get selectable():Boolean {
    return _selectable;
  }

  private var _clipAndEnableScrolling:Boolean;
  private var clipAndEnableScrollingChanged:Boolean;

  public function get clipAndEnableScrolling():Boolean {
    return _clipAndEnableScrolling;
  }

  public function set clipAndEnableScrolling(value:Boolean):void {
    if (_clipAndEnableScrolling != value) {
      _clipAndEnableScrolling = value;
      clipAndEnableScrollingChanged = true;
      //invalidateProperties();
    }
  }

  protected var _contentWidth:Number = 0;
  [Bindable("propertyChange")]
  public function get contentWidth():Number {
    return _contentWidth;
  }

  protected var _contentHeight:Number = 0;
  [Bindable("propertyChange")]
  public function get contentHeight():Number {
    return _contentHeight;
  }

  protected var _horizontalScrollPosition:Number = 0;
  private var horizontalScrollPositionChanged:Boolean = false;

  [Bindable("propertyChange")]
  public function get horizontalScrollPosition():Number {
    return _horizontalScrollPosition;
  }

  public function set horizontalScrollPosition(value:Number):void {
    if (_horizontalScrollPosition != value) {
      _horizontalScrollPosition = value;
      horizontalScrollPositionChanged = true;

      //invalidateProperties();
    }
  }

  protected var _verticalScrollPosition:Number = 0;
  private var verticalScrollPositionChanged:Boolean = false;

  [Bindable("propertyChange")]
  public function get verticalScrollPosition():Number {
    return _verticalScrollPosition;
  }

  public function set verticalScrollPosition(value:Number):void {
    if (_verticalScrollPosition != value) {
      _verticalScrollPosition = value;
      verticalScrollPositionChanged = true;

      //invalidateProperties();
    }
  }

  public function getHorizontalScrollPositionDelta(navigationUnit:uint):Number {
    var scrollR:Rectangle = scrollRect;
    if (!scrollR) {
      return 0;
    }

    // maxDelta is the horizontalScrollPosition delta required to scroll to the RIGHT and minDelta scrolls to LEFT.
    var maxDelta:Number = contentWidth - scrollR.right;
    var minDelta:Number = -scrollR.left;

    switch (navigationUnit) {
      case NavigationUnit.LEFT: return (scrollR.left <= 0) ? 0 : Math.max(minDelta, -effectiveTextFormat.fontSize);
      case NavigationUnit.RIGHT: return (scrollR.right >= contentWidth) ? 0 : Math.min(maxDelta, effectiveTextFormat.fontSize);
      case NavigationUnit.PAGE_LEFT: return Math.max(minDelta, -scrollR.width);
      case NavigationUnit.PAGE_RIGHT: return Math.min(maxDelta, scrollR.width);
      case NavigationUnit.HOME: return minDelta;
      case NavigationUnit.END: return maxDelta;

      default: return 0;
    }
  }

  public function getVerticalScrollPositionDelta(navigationUnit:uint):Number {
    var scrollR:Rectangle = scrollRect;
    if (scrollR == null) {
      return 0;
    }

    // maxDelta is the horizontalScrollPosition delta required to scroll to the END and minDelta scrolls to HOME.
    var maxDelta:Number = contentHeight - scrollR.bottom;
    var minDelta:Number = -scrollR.top;

    switch (navigationUnit) {
      case NavigationUnit.UP: return scrollController.getScrollDelta(-1);
      case NavigationUnit.DOWN: return scrollController.getScrollDelta(1);
      case NavigationUnit.PAGE_UP: return Math.max(minDelta, -scrollR.height);
      case NavigationUnit.PAGE_DOWN: return Math.min(maxDelta, scrollR.height);
      case NavigationUnit.HOME: return minDelta;
      case NavigationUnit.END: return maxDelta;

      default: return 0;
    }
  }

  //override protected function commitProperties():void {
  //  super.commitProperties();
  //
  //  if (clipAndEnableScrollingChanged) {
  //    scrollController.horizontalScrollPolicy = scrollController.verticalScrollPolicy = clipAndEnableScrolling ? ScrollPolicy.AUTO : ScrollPolicy.OFF;
  //
  //    clipAndEnableScrollingChanged = false;
  //  }
  //
  //  if (horizontalScrollPositionChanged) {
  //    var oldHorizontalScrollPosition:Number = scrollController.horizontalScrollPosition;
  //    scrollController.horizontalScrollPosition = horizontalScrollPosition;
  //    dispatchPropertyChangeEvent("horizontalScrollPosition", oldHorizontalScrollPosition, horizontalScrollPosition);
  //    horizontalScrollPositionChanged = false;
  //  }
  //
  //  if (verticalScrollPositionChanged) {
  //    var oldVerticalScrollPosition:Number = scrollController.verticalScrollPosition;
  //    scrollController.verticalScrollPosition = verticalScrollPosition;
  //    dispatchPropertyChangeEvent("verticalScrollPosition", oldVerticalScrollPosition, verticalScrollPosition);
  //    verticalScrollPositionChanged = false;
  //  }
  //}
}
}