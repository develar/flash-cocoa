package cocoa.plaf.basic {
import cocoa.FlexDataGroup;
import cocoa.HighlightableItemRenderer;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

public class AbstractListInteractor {
  protected static const MOUSE_HIGHLIGHTABLE:uint = 1 << 0;

  protected var itemGroup:FlexDataGroup;

  protected var flags:uint;

  protected var highlightedRenderer:HighlightableItemRenderer;

  protected function addHandlers():void {
    if (flags & MOUSE_HIGHLIGHTABLE) {
      // we cannot use mouse over/mouse out due to:
      // if we change highlighted item via keyboard и при этом мышь по прежнему над некоторым item — то малейшее движение мыши вновь устанавливает highlighted на item под мышью
      itemGroup.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
      itemGroup.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
    }
  }

  protected function rollOutHandler(event:MouseEvent):void {
    if (highlightedRenderer != null) {
      highlightedRenderer.highlighted = false;
      highlightedRenderer = null;
      event.updateAfterEvent();
    }
  }

  protected function mouseMoveHandler(event:MouseEvent):void {
    if (highlightedRenderer == event.target) {
      // skip
    }
    else if (event.target != event.currentTarget) {
      if (highlightedRenderer != null) {
        highlightedRenderer.highlighted = false;
      }

      highlightedRenderer = event.target as HighlightableItemRenderer;
      if (highlightedRenderer != null) {
        highlightedRenderer.highlighted = true;
      }

      event.updateAfterEvent();
    }
    else if (highlightedRenderer != null) {
      highlightedRenderer.highlighted = false;
      highlightedRenderer = null;

      event.updateAfterEvent();
    }
  }

  protected function keyDownHandler(event:KeyboardEvent):void {
    var newHighlightedIndex:int = -1;

    switch (event.keyCode) {
      case Keyboard.UP:
        if (highlightedRenderer == null) {
          newHighlightedIndex = itemGroup.dataProvider.length - 1;
        }
        else if (highlightedRenderer.itemIndex > 0) {
          newHighlightedIndex = highlightedRenderer.itemIndex - 1;
        }
        break;

      case Keyboard.DOWN:
        if (highlightedRenderer == null) {
          newHighlightedIndex = 0;
        }
        else if (highlightedRenderer.itemIndex < (itemGroup.dataProvider.length - 1)) {
          newHighlightedIndex = highlightedRenderer.itemIndex + 1;
        }
        break;

      default:
        return;
    }

    if (newHighlightedIndex != -1) {
      if (highlightedRenderer != null) {
        highlightedRenderer.highlighted = false;
      }
      highlightedRenderer = HighlightableItemRenderer(itemGroup.getElementAt(newHighlightedIndex));

      // disabled or separator menu
      if (!highlightedRenderer.enabled) {
        if (event.keyCode == Keyboard.UP) {
          if (newHighlightedIndex == 0) {
            return;
          }
          else {
            newHighlightedIndex--;
          }
        }
        else if (newHighlightedIndex != (itemGroup.dataProvider.length - 1)) {
          newHighlightedIndex++;
        }
        else {
          return;
        }

        highlightedRenderer = HighlightableItemRenderer(itemGroup.getElementAt(newHighlightedIndex));
      }

      highlightedRenderer.highlighted = true;
      event.preventDefault();
    }
  }
}
}