package cocoa.tableView {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

public interface TableColumn {
  function get dataField():String;

  function set dataField(value:String):void;

  function get title():String;

  function set title(value:String):void;

  function get width():Number;

  function set width(value:Number):void;

  function get minWidth():Number;

  function set minWidth(value:Number):void;

  function get actualWidth():Number;

  function set actualWidth(value:Number):void;

  function createAndLayoutRenderer(rowIndex:int, relativeRowIndex:Number, x:Number, y:Number):DisplayObject;

  /**
   * @param rowCountDelta delta, greater than 0 if removed from top, less than 0 if removed from bottom
   * @param finalPass will be createAndLayoutRenderer called (false) after or not (true)
   */
  function reuse(rowCountDelta:int, visibleRowCount:int, finalPass:Boolean):void;

  function postLayout():void;

  function moveValidVisibleRenderersByY(rowCountDelta:int, visibleRowCount:int):void;

  function maxVisibleRowCountChanged(maxVisibleRowCount:int):void;

  function set container(container:DisplayObjectContainer):void;

  function clearLastRenderer():void;
}
}
