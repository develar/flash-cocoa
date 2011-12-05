package cocoa.text {
public interface ScrollController {
  function getScrollDelta(numLines:int):Number;

  function set horizontalScrollPolicy(value:String):void;

  function set verticalScrollPolicy(value:String):void;

  function get horizontalScrollPosition():Number;

  function set horizontalScrollPosition(x:Number):void;

  function get verticalScrollPosition():Number;

  function set verticalScrollPosition(value:Number):void;
}
}