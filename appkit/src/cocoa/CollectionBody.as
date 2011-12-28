package cocoa {
import flash.display.InteractiveObject;
import flash.errors.IllegalOperationError;
import flash.geom.Rectangle;

import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

import spark.core.NavigationUnit;

[Abstract]
public class CollectionBody extends ControlView implements Focusable, Viewport {
  protected var rowHeightWithSpacing:int;
  protected var oldHeight:Number = 0;

  protected var _clipAndEnableScrolling:Boolean;
  public function get clipAndEnableScrolling():Boolean {
    return _clipAndEnableScrolling;
  }
  public function set clipAndEnableScrolling(value:Boolean):void {
    if (_clipAndEnableScrolling == value) {
      return;
    }

    _clipAndEnableScrolling = value;

    if (!_clipAndEnableScrolling) {
      scrollRect = null;
    }
  }

  public function get contentWidth():int {
    return getPreferredWidth();
  }

  public function get contentHeight():int {
    return getPreferredHeight();
  }

  protected var _horizontalScrollPosition:int = 0;
  public function get horizontalScrollPosition():int {
    return _horizontalScrollPosition;
  }

  public function set horizontalScrollPosition(value:int):void {
    if (value == _horizontalScrollPosition) {
      return;
    }

    _horizontalScrollPosition = value;
  }

  protected var _verticalScrollPosition:int = 0;
  public function get verticalScrollPosition():int {
    return _verticalScrollPosition;
  }

  public function set verticalScrollPosition(value:int):void {
    if (_verticalScrollPosition == value) {
      return;
    }

    var oldVerticalScrollPosition:Number = _verticalScrollPosition;
    var delta:Number = value - oldVerticalScrollPosition;
    _verticalScrollPosition = value;

    if ((flags & LayoutState.DISPLAY_INVALID) == 0) {
      scrollRect = new Rectangle(_horizontalScrollPosition, _verticalScrollPosition, width, height);
    }
    verticalScrollPositionChanged(delta, oldVerticalScrollPosition);
  }

  protected function verticalScrollPositionChanged(delta:Number, oldVerticalScrollPosition:Number):void {
    throw new IllegalOperationError();
  }

  public function getHorizontalScrollPositionDelta(navigationUnit:uint):Number {
    return 0;
  }

  public function getVerticalScrollPositionDelta(navigationUnit:uint):Number {
    if (_verticalScrollPosition == 0 && contentHeight <= height) {
      return 0;
    }

    switch (navigationUnit) {
      case NavigationUnit.DOWN:
      case NavigationUnit.PAGE_DOWN:
        return rowHeightWithSpacing;

      case NavigationUnit.UP:
      case NavigationUnit.PAGE_UP:
        return -rowHeightWithSpacing;

      default:
        return 0;
    }
  }

  public function get focusObject():InteractiveObject {
    return this;
  }

  protected var _contentSizeChanged:Signal;
  public function get contentSizeChanged():ISignal {
    if (_contentSizeChanged == null) {
      _contentSizeChanged = new Signal();
    }
    return _contentSizeChanged;
  }

  protected var _scrollPositionReset:Signal;
  public function get scrollPositionReset():ISignal {
    if (_scrollPositionReset == null) {
      _scrollPositionReset = new Signal();
    }
    return _scrollPositionReset;
  }
}
}
