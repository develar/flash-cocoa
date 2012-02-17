package cocoa.toolWindow {
import cocoa.MigLayout;
import cocoa.Panel;
import cocoa.RootContentView;
import cocoa.cursor.Cursor;
import cocoa.util.SharedPoint;
import cocoa.util.Vectors;

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
import net.miginfocom.layout.ComponentDimensionConstraint;
import net.miginfocom.layout.ComponentWrapper;
import net.miginfocom.layout.MigConstants;
import net.miginfocom.layout.UnitValue;

internal final class ToolWindowResizer {
  private static const HOT_AREA_SIZE:int = 7;
  // 1 — border size
  private static const HANDLE_OFFSET:int = (HOT_AREA_SIZE - 1) / 2;

  [Embed("resizeLeftRight.png")]
  private static var resizeLeftRightCursorClass:Class;

  [Embed("resizeUpDown.png")]
  private static var resizeUpDownClass:Class;

  private var minSideWidth:int = int.MAX_VALUE;
  private var resizing:Boolean;

  private var panelOffset:Number;

  private var mouseOffset:Number;
  private var handle:Sprite;

  private var container:RootContentView;
  private var toolWindowManager:ToolWindowManager;

  private var heightResizingPanel:Panel;

  function ToolWindowResizer(layout:MigLayout, container:RootContentView, toolWindowManager:ToolWindowManager) {
    this.container = container;
    this.toolWindowManager = toolWindowManager;
    layout.layouted.add(layouted);
  }

  private function layouted():void {
    if (resizing) {
      return;
    }

    var c:DisplayObjectContainer = container.displayObject;
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

    drawSplitters();
  }

  private function drawSplitters():void {
    var g:Graphics = handle.graphics;
    g.clear();

    var x:int = -1;
    var y:int = int.MAX_VALUE;
    var h:int = 0;

    var horizontalSplitterPositionsIndex:int = 0;
    var horizontalSplitterY:Vector.<int> = new Vector.<int>();
    var horizontalSplitterH:Vector.<int> = new Vector.<int>();
    var horizontalSplitterWidth:int = -1;

    for each (var component:ComponentWrapper in container.components) {
      if (component is Panel && component.visible) {
        x = component.x;
        if (y > component.y) {
          y = component.y;
        }

        horizontalSplitterY[horizontalSplitterPositionsIndex] = component.y;
        horizontalSplitterH[horizontalSplitterPositionsIndex++] = component.actualHeight;

        h += component.actualHeight;
        minSideWidth = Math.min(minSideWidth, component.getMinimumWidth());

        if (horizontalSplitterWidth == -1) {
          horizontalSplitterWidth = (component.actualWidth + HANDLE_OFFSET) - HOT_AREA_SIZE;
          panelOffset = component.x - (container.actualWidth - component.actualWidth);
        }
      }
    }

    // todo
    minSideWidth = Math.max(minSideWidth, 180);

    // like idea — 7px (3px left 1px border line 3px right)
    handle.x = x - HANDLE_OFFSET;
    handle.y = y;

    if (resizing || !(handle.visible = x != -1)) {
      return;
    }

    g.beginFill(0, 0);
    g.drawRect(0, 0, HOT_AREA_SIZE, h);
    g.endFill();

    if (horizontalSplitterPositionsIndex < 1) {
      return;
    }

    horizontalSplitterY.sort(Vectors.sortAscending);
    for (var i:int = 1; i < horizontalSplitterPositionsIndex; i++) {
      g.beginFill(0, 0);
      const splitterH:int = horizontalSplitterY[i] - (horizontalSplitterY[i - 1] + horizontalSplitterH[i - 1]);
      g.drawRect(HOT_AREA_SIZE, horizontalSplitterY[i] - splitterH, horizontalSplitterWidth, splitterH);
      g.endFill();
    }
  }

  private function mouseDown(event:MouseEvent):void {
    if (minSideWidth == int.MAX_VALUE) {
      return;
    }

    resizing = true;
    const widthResizing:Boolean = Mouse.cursor == Cursor.resizeLeftRight;
    mouseOffset = widthResizing ? event.localX - HANDLE_OFFSET : event.localY;
    handle.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
    handle.stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);

    if (widthResizing) {
      return;
    }

    for each (var component:ComponentWrapper in container.components) {
      if (component is Panel && component.visible) {
        mouseOffset = component.y - event.localY;
        if (mouseOffset >= 0 && mouseOffset <= HOT_AREA_SIZE) {
          heightResizingPanel = Panel(component);
        }
      }
    }
  }

  private function stageMouseMoveHandler(event:MouseEvent):void {
    var mouseLocal:Point = container.displayObject.globalToLocal(SharedPoint.mouseGlobal(event));
    var newValue:Number;
    var preferred:UnitValue;
    var columnConstraint:CellConstraint = toolWindowManager.getColumnConstraint(MigConstants.RIGHT);
    if (heightResizingPanel == null) {
      if (mouseLocal.x < 0) {
        return;
      }

      newValue = Math.max((container.actualWidth - mouseLocal.x) + mouseOffset + panelOffset, minSideWidth);

      if (columnConstraint.size != null) {
        preferred = columnConstraint.size.preferred;
        if (preferred != null && preferred.unit == UnitValue.PIXEL && preferred.value == newValue) {
          return;
        }
      }

      columnConstraint.size = BoundSize.createSame(new UnitValue(newValue));
    }
    else {
      if (mouseLocal.y < handle.y) {
        return;
      }

      newValue = container.actualHeight - (mouseLocal.y + mouseOffset);
      newValue = newValue / ((container.actualHeight - handle.y) - newValue - columnConstraint.componentGap.preferred.value);
      var dimensionConstraint:ComponentDimensionConstraint = heightResizingPanel.constraints.vertical;
      if (dimensionConstraint.grow == newValue) {
        return;
      }

      dimensionConstraint.grow = newValue;
    }

    container.subviewVisibleChanged();
  }

  private function stageMouseUpHandler(event:MouseEvent):void {
    handle.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
    handle.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
    Mouse.cursor = MouseCursor.AUTO;
    resizing = false;
    heightResizingPanel = null;
    drawSplitters();
  }

  private static function isLeftRightResize(event:MouseEvent):Boolean {
    return event.localX <= HOT_AREA_SIZE;
  }

  private function mouseOverOrOutHandler(event:MouseEvent):void {
    if (resizing) {
      return;
    }

    if (resizeLeftRightCursorClass != null) {
      registerCursors();
    }

    if (event.type == MouseEvent.MOUSE_OVER) {
      Mouse.cursor = isLeftRightResize(event) ? Cursor.resizeLeftRight : Cursor.resizeUpDown;
    }
    else {
      Mouse.cursor = MouseCursor.AUTO;
    }
  }

  private static function registerCursors():void {
    Mouse.registerCursor(Cursor.resizeLeftRight, createMouseCursorData(resizeLeftRightCursorClass));
    Mouse.registerCursor(Cursor.resizeUpDown, createMouseCursorData(resizeUpDownClass));

    resizeLeftRightCursorClass = null;
    resizeUpDownClass = null;
  }

  private static function createMouseCursorData(clazz:Class):MouseCursorData {
    var mouseCursorData:MouseCursorData = new MouseCursorData();
    mouseCursorData.data = new <BitmapData>[Bitmap(new clazz()).bitmapData];
    mouseCursorData.hotSpot = new Point(12, 12);
    return mouseCursorData;
  }
}
}
