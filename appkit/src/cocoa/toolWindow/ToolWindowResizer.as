package cocoa.toolWindow {
import cocoa.MigLayout;
import cocoa.Panel;
import cocoa.RootContentView;
import cocoa.cursor.Cursor;
import cocoa.util.SharedPoint;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import flash.ui.MouseCursorData;

import net.miginfocom.layout.BoundSize;
import net.miginfocom.layout.CellConstraint;
import net.miginfocom.layout.ComponentWrapper;
import net.miginfocom.layout.MigConstants;
import net.miginfocom.layout.UnitValue;

internal final class ToolWindowResizer {
  [Embed("resizeLeftRight.png")]
  private static var resizeLeftRightCursorClass:Class;

  private var minSideWidth:int = int.MAX_VALUE;
  private var resizeHandleDragged:Boolean;

  private var panelOffset:Number;

  private var mouseOffset:Number;
  private var handle:Sprite;

  private var container:RootContentView;
  private var toolWindowManager:ToolWindowManager;

  function ToolWindowResizer(layout:MigLayout, container:RootContentView, toolWindowManager:ToolWindowManager) {
    this.container = container;
    this.toolWindowManager = toolWindowManager;
    layout.layouted.add(layouted);
  }

  private function layouted():void {
    var c:DisplayObjectContainer = container.displayObject;
    if (!resizeHandleDragged) {
      if (handle == null) {
        handle = new Sprite();
        handle.addEventListener(MouseEvent.MOUSE_OVER, mouseOverOrOutHandler);
        handle.addEventListener(MouseEvent.MOUSE_OUT, mouseOverOrOutHandler);
        handle.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
      }
      if (handle.parent != c) {
        c.addChild(handle);
      }
      else if (c.numChildren != 0 && c.getChildIndex(handle) != c.numChildren - 1) {
        c.setChildIndex(handle, c.numChildren - 1);
      }
    }

    var x:int = -1;
    var y:int = int.MAX_VALUE;
    var h:int = 0;
    for each (var component:ComponentWrapper in container.components) {
      if (component is Panel && component.visible) {
        x = component.x;
        if (y > component.y) {
          y = component.y;
        }

        h += component.actualHeight;
        minSideWidth = Math.min(minSideWidth, component.getMinimumWidth());

        panelOffset = component.x - (container.actualWidth - component.actualWidth);
      }
    }

    // todo
    minSideWidth = Math.max(minSideWidth, 180);

    // like idea — 7px (3px left 1px border line 3px right)
    handle.x = x - 3;
    handle.y = y;

    if (resizeHandleDragged || !(handle.visible = x != -1)) {
      return;
    }

    var g:Graphics = handle.graphics;
    g.clear();
    g.beginFill(0, 0);
    g.drawRect(0, 0, 7, h);
    g.endFill();
  }

  private function mouseDown(event:MouseEvent):void {
    if (minSideWidth == int.MAX_VALUE) {
      return;
    }

    resizeHandleDragged = true;
    mouseOffset = event.localX - 3;
    handle.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
    handle.stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
  }

  private function stageMouseMoveHandler(event:MouseEvent):void {
    var mouseLocal:Point = container.displayObject.globalToLocal(SharedPoint.mouseGlobal(event));
    if (mouseLocal.x < 0) {
      return;
    }

    const newValue:Number = Math.max((container.actualWidth - mouseLocal.x) + mouseOffset + panelOffset, minSideWidth);
    var columnConstraint:CellConstraint = toolWindowManager.getColumnConstraint(MigConstants.RIGHT);
    if (columnConstraint.size != null) {
      var preferred:UnitValue = columnConstraint.size.preferred;
      if (preferred != null && preferred.unit == UnitValue.PIXEL && preferred.value == newValue) {
        return;
      }
    }

    columnConstraint.size = BoundSize.createSame(new UnitValue(newValue));

    container.subviewVisibleChanged();
  }

  private function stageMouseUpHandler(event:MouseEvent):void {
    handle.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
    handle.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
    Mouse.cursor = MouseCursor.AUTO;
    resizeHandleDragged = false;
  }

  private function mouseOverOrOutHandler(event:MouseEvent):void {
    if (resizeHandleDragged) {
      return;
    }

    if (resizeLeftRightCursorClass != null) {
      registerCursors();
    }

    Mouse.cursor = event.type == MouseEvent.MOUSE_OVER ? Cursor.resizeLeftRight : MouseCursor.AUTO;
  }

  private static function registerCursors():void {
    var mouseCursorData:MouseCursorData = new MouseCursorData();
    mouseCursorData.data = new <BitmapData>[Bitmap(new resizeLeftRightCursorClass()).bitmapData];
    mouseCursorData.hotSpot = new Point(12, 12);

    Mouse.registerCursor(Cursor.resizeLeftRight, mouseCursorData);

    resizeLeftRightCursorClass = null;
  }
}
}
