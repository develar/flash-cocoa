package cocoa.plaf.basic {
import cocoa.renderer.InteractiveRendererManager;
import cocoa.ItemMouseSelectionMode;
import cocoa.SegmentedControl;
import cocoa.SelectionMode;

import flash.display.InteractiveObject;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;

public class SegmentedControlInteractor {
  private var rendererManager:InteractiveRendererManager;
  private var itemInteractiveObject:InteractiveObject;
  private var selectingItemIndex:int;

  private var isOver:Boolean;

  public function register(segmentedControl:SegmentedControl):void {
    segmentedControl.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
  }

  private var segmentedControl:SegmentedControl;

  private function mouseDownHandler(event:MouseEvent):void {
    segmentedControl = SegmentedControl(event.currentTarget);

    rendererManager = segmentedControl.rendererManager;
    const itemIndex:int = rendererManager.getItemIndexAt(event.localX);
    if (rendererManager.mouseSelectionMode == ItemMouseSelectionMode.DOWN) {
      segmentedControl.setSelected(itemIndex, segmentedControl.isItemSelected(itemIndex));
      
      segmentedControl = null;
      rendererManager = null;
    }
    else {
      rendererManager.setSelecting(itemIndex, true);
      selectingItemIndex = itemIndex;
      
      segmentedControl.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

      itemInteractiveObject = rendererManager.getItemInteractiveObject(itemIndex);
      if (itemInteractiveObject != null) {
        itemInteractiveObject.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
        itemInteractiveObject.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
      }
      else {
        segmentedControl.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
      }
    }

    event.updateAfterEvent();
  }

  private function stageMouseUpHandler(event:MouseEvent):void {
    IEventDispatcher(event.currentTarget).removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

    if (itemInteractiveObject == null) {
      segmentedControl.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
    }
    else {
      itemInteractiveObject.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
      itemInteractiveObject.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
      isOver = itemInteractiveObject == event.target;
    }

    if (isOver) {
      const wasSelected:Boolean = segmentedControl.isItemSelected(selectingItemIndex);
      if (wasSelected) {
        if (segmentedControl.mode == SelectionMode.ONE) {
          rendererManager.setSelecting(selectingItemIndex, false);
        }
        else {
          segmentedControl.setSelected(selectingItemIndex, false);
        }
      }
      else if (segmentedControl.mode == SelectionMode.ONE) {
        segmentedControl.selectedIndex = selectingItemIndex;
      }
      else {
        segmentedControl.setSelected(selectingItemIndex, true);
      }

      event.updateAfterEvent();
    }

    rendererManager = null;
    itemInteractiveObject = null;
    segmentedControl = null;
    selectingItemIndex = -1;
  }

  private function mouseOverHandler(event:MouseEvent):void {
    rendererManager.setSelecting(selectingItemIndex, true);
    event.updateAfterEvent();
  }

  private function mouseOutHandler(event:MouseEvent):void {
    rendererManager.setSelecting(selectingItemIndex, false);
    event.updateAfterEvent();
  }

  private function mouseMoveHandler(event:MouseEvent):void {
    var itemIndex:int = rendererManager.getItemIndexAt(event.localX);
    if (itemIndex == selectingItemIndex) {
      if (!isOver) {
        isOver = true;
        mouseOverHandler(event);
      }
    }
    else if (isOver) {
      isOver = false;
      mouseOutHandler(event);
    }
  }
}
}