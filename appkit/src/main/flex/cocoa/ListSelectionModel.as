package cocoa {
public interface ListSelectionModel {
  function get isSelectionEmpty():Boolean;

  function isItemSelected(index:int):Boolean;

  function get selectedIndex():int;

  function set selectedIndex(value:int):void;
}
}
