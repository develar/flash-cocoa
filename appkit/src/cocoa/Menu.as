package cocoa {
import flash.events.Event;

import mx.events.CollectionEvent;

import org.flyti.util.List;

public class Menu extends AbstractSkinnableView {
  private var pendingIndex:int = -1;

  private var itemGroup:SegmentedControl;

  override public function uiPartAdded(id:String, instance:Object):void {
    itemGroup = SegmentedControl(instance);
//    itemGroup.mouseSelectionMode = ItemMouseSelectionMode.NONE; // delegate to MenuController (see PopUpMenuController)
    if (pendingIndex != -1) {
      itemGroup.selectedIndex = pendingIndex;
      pendingIndex = -1;
    }
  }

  public function set selectedIndex(value:int):void {
    if (itemGroup == null) {
      pendingIndex = value;
    }
    else {
     itemGroup.selectedIndex = value;
    }
  }

  public function getItemAt(index:int):Object {
    return (_items.empty || (index == ListSelection.NO_SELECTION)) ? null : _items.getItemAt(index);
  }

  public function getItemIndex(value:Object):int {
    return _items.getItemIndex(value);
  }

  private var _labelFunction:Function;
  public function get labelFunction():Function {
    return _labelFunction;
  }

  public function set labelFunction(labelFunction:Function):void {
    _labelFunction = labelFunction;
  }

  private var itemsChanged:Boolean;
  protected var _items:List;
  public function set items(value:List):void {
    if (value != _items) {
      var dispatchChangeEvent:Boolean = _items != null;
      if (_items != null) {
        _items.removeEventListener(CollectionEvent.COLLECTION_CHANGE, itemsChangeHandler);
      }
      _items = value;
      itemsChanged = true;
      invalidateProperties();

      if (dispatchChangeEvent) {
        itemsChangeHandler();
      }
    }
  }

  private function itemsChangeHandler(event:CollectionEvent = null):void {
    //AbstractView(skin).callLater(dispatchChangeEvent);
  }

  private function dispatchChangeEvent():void {
    dispatchEvent(new Event(Event.CHANGE));
  }

  public function get numberOfItems():int {
    return _items.length;
  }

  override protected function get primaryLaFKey():String {
    return "Menu";
  }

  //override public function commitProperties():void {
  //  super.commitProperties();
  //
  //  if (itemsChanged) {
  //    itemsChanged = false;
  //    itemGroup.dataProvider = _items;
  //
  //    _items.addEventListener(CollectionEvent.COLLECTION_CHANGE, itemsChangeHandler, false, -1 /* after itemGroup handler */);
  //  }
  //}
}
}