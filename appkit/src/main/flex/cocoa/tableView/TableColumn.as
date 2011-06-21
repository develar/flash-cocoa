package cocoa.tableView {
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

  function get rendererManager():RendererManager;
}
}
