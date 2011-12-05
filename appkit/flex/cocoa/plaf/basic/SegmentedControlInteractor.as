package cocoa.plaf.basic {
import cocoa.ItemMouseSelectionMode;
import cocoa.SegmentedControl;
import cocoa.SelectionMode;
import cocoa.plaf.Skin;
import cocoa.renderer.InteractiveRendererManager;
import cocoa.util.SharedPoint;

import flash.display.InteractiveObject;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;

public class SegmentedControlInteractor {
  private var rendererManager:InteractiveRendererManager;
  private var itemInteractiveObject:InteractiveObject;
  private var selectingItemIndex:int = -1;

  private var isOver:Boolean;

  public function register(segmentedControl:SegmentedControl):void {
    segmentedControl.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
    segmentedControl.mouseChildren = false;
  }

  private var segmentedControl:SegmentedControl;

  private function mouseDownHandler(event:MouseEvent):void {
    segmentedControl = SegmentedControl(event.currentTarget);

    var x:Number = event.localX;
    var y:Number = event.localY;
    if (event.target != segmentedControl) {
      if (event.target is Skin) {
        // interaction delegated to component
        return;
      }
      else {
        var point:Point = SharedPoint.point;
        point.x = event.stageX;
        point.y = event.stageY;
        point = segmentedControl.globalToLocal(point);
        x = point.x;
        y = point.y;
      }
    }

    const itemIndex:int = InteractiveRendererManager(segmentedControl.rendererManager).getItemIndexAt(x, y);
    if (itemIndex == -1) {
      segmentedControl = null;
      return;
    }

    rendererManager = InteractiveRendererManager(segmentedControl.rendererManager);

    if (rendererManager.mouseSelectionMode == ItemMouseSelectionMode.DOWN) {
      segmentedControl.setSelected(itemIndex, segmentedControl.isItemSelected(itemIndex));
      
      segmentedControl = null;
      rendererManager = null;
    }
    else {
      rendererManager.setSelecting(itemIndex, true);
      selectingItemIndex = itemIndex;
      isOver = true;
      
      segmentedControl.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

      itemInteractiveObject = rendererManager.getItemInteractiveObject(itemIndex);
      if (itemInteractiveObject != null) {
        itemInteractiveObject.addEventListener(MouseEvent.MOUSE_OVER, itemMouseOverHandler);
        itemInteractiveObject.addEventListener(MouseEvent.MOUSE_OUT, itemMouseOutHandler);
      }
      else {
        segmentedControl.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        segmentedControl.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
      }
    }

    event.updateAfterEvent();
  }

  private function stageMouseUpHandler(event:MouseEvent):void {
    IEventDispatcher(event.currentTarget).removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

    if (itemInteractiveObject == null) {
      var itemIndex:int = rendererManager.getItemIndexAt(event.localX, event.localY);
      isOver = itemIndex == selectingItemIndex;
      segmentedControl.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
      segmentedControl.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
    }
    else {
      itemInteractiveObject.removeEventListener(MouseEvent.MOUSE_OVER, itemMouseOverHandler);
      itemInteractiveObject.removeEventListener(MouseEvent.MOUSE_OUT, itemMouseOutHandler);
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
      else {
        segmentedControl.setSelected(selectingItemIndex, segmentedControl.mode == SelectionMode.ONE ? true : !wasSelected);
      }

      event.updateAfterEvent();
    }

    rendererManager = null;
    itemInteractiveObject = null;
    segmentedControl = null;
    selectingItemIndex = -1;
  }

  private function itemMouseOverHandler(event:MouseEvent):void {
    rendererManager.setSelecting(selectingItemIndex, true);
    event.updateAfterEvent();
  }

  private function itemMouseOutHandler(event:MouseEvent):void {
    rendererManager.setSelecting(selectingItemIndex, false);
    event.updateAfterEvent();
  }

  private function rollOutHandler(event:MouseEvent):void {
    if (isOver) {
      isOver = false;
      itemMouseOutHandler(event);
    }
  }

  private function mouseMoveHandler(event:MouseEvent):void {
    var itemIndex:int = rendererManager.getItemIndexAt(event.localX, event.localY);
    if (itemIndex == selectingItemIndex) {
      if (!isOver) {
        isOver = true;
        itemMouseOverHandler(event);
      }
    }
    else if (isOver) {
      isOver = false;
      itemMouseOutHandler(event);
    }
  }
}
}