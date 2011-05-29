package cocoa.plaf.basic {
import cocoa.AbstractView;

import flash.errors.IllegalOperationError;
import flash.geom.Rectangle;

import spark.core.IViewport;
import spark.core.NavigationUnit;

public class ListBody extends AbstractView implements IViewport {
  protected var rowHeightWithSpacing:Number;
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

  public function get contentWidth():Number {
    return 0;
  }

  protected var _contentHeight:Number = 0;
  public function get contentHeight():Number {
    return _contentHeight;
  }

  private var _horizontalScrollPosition:Number = 0;
  public function get horizontalScrollPosition():Number {
    return _horizontalScrollPosition;
  }

  public function set horizontalScrollPosition(value:Number):void {
    if (value == _horizontalScrollPosition) {
      return;
    }

    _horizontalScrollPosition = value;
  }

  protected var _verticalScrollPosition:Number = 0;
  public function get verticalScrollPosition():Number {
    return _verticalScrollPosition;
  }

  public function set verticalScrollPosition(value:Number):void {
    if (_verticalScrollPosition == value) {
      return;
    }

    var oldVerticalScrollPosition:Number = _verticalScrollPosition;
    var delta:Number = value - oldVerticalScrollPosition;
    _verticalScrollPosition = value;

    if (!displayListInvalid) {
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
    if (_verticalScrollPosition == 0 && _contentHeight <= height) {
      return 0;
    }

    switch (navigationUnit) {
      case NavigationUnit.DOWN:
      case NavigationUnit.PAGE_DOWN:
        //return rowHeightWithSpacing;
        return 15;

      case NavigationUnit.UP:
      case NavigationUnit.PAGE_UP:
        //return -rowHeightWithSpacing;
        return -15;

      default:
        return 0;
    }
  }
}
}
