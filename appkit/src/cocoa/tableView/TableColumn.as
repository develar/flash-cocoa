package cocoa.tableView {
import cocoa.renderer.RendererManager;

public interface TableColumn {
  function get dataField():String;

  function set dataField(value:String):void;

  function get title():String;

  function set title(value:String):void;

  function get preferredWidth():int;

  function set preferredWidth(value:int):void;

  function get minWidth():int;

  function set minWidth(value:int):void;

  function get actualWidth():int;

  function set actualWidth(value:int):void;

  function get rendererManager():RendererManager;
}
}
