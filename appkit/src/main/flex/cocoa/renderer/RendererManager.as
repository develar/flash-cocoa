package cocoa.renderer {
import cocoa.ListViewDataSource;

import flash.display.DisplayObjectContainer;

public interface RendererManager {
  function createAndLayoutRenderer(itemIndex:int, x:Number, y:Number, w:Number, h:Number):void;

  /**
   * @param itemCountDelta delta, greater than 0 if removed from top, less than 0 if removed from bottom
   * @param finalPass will be createAndLayoutRenderer called (false) after or not (true)
   */
  function reuse(itemCountDelta:int, finalPass:Boolean):void;

  function postLayout(finalPass:Boolean):void;

  function set container(container:DisplayObjectContainer):void;

  function preLayout(head:Boolean):void;

  function get lastCreatedRendererWidth():Number;

  function set dataSource(value:ListViewDataSource):void;
}
}
