package cocoa.colorPicker {
import cocoa.Border;

import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.GraphicsPathCommand;
import flash.display.LineScaleMode;
import flash.display.Sprite;

public class SwatchGrid extends Sprite {
//  private var highlightIndicator:Shape;

  private static var gridCommands:Vector.<int> = new <int>[GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO];
  private static var gridPathData:Vector.<Number> = new Vector.<Number>(4, true);

  private static const horizontalGap:Number = 1;
  private static const verticalGap:Number = 1;
  private static const swatchHeight:Number = 10;
  private static const swatchWidth:Number = 10;

  private static const swatchBorderThickness:Number = 1;
  private static const swatchBorderColor:uint = 0xb8b8b8;

  private static const columnCount:int = 19;

  private static const cellPadding:Number = 1;

  private static const xStep:Number = swatchWidth + horizontalGap + (cellPadding * 2);
  private static const yStep:Number = swatchHeight + verticalGap + (cellPadding * 2);

  public function drawGrid(list:Vector.<uint>, border:Border):void {
    var g:Graphics = graphics;
    g.clear();

    const size:int = list.length;
    const rowCount:int = Math.ceil(size / columnCount);

    const gridWidth:Number = (columnCount * xStep) - horizontalGap + (cellPadding * 2);
    const gridHeight:Number = (rowCount * yStep) - verticalGap + (cellPadding * 2);

    border.draw(null, g, gridWidth + border.contentInsets.width, gridHeight + border.contentInsets.height);

    g.lineStyle(1, swatchBorderColor, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE);
    var i:int;

    gridPathData[1] = border.contentInsets.top + swatchBorderThickness;
    gridPathData[3] = border.contentInsets.top + gridHeight - swatchBorderThickness;
    var gx:Number = border.contentInsets.left;
    for (i = -1; i < columnCount; i++) {
      gridPathData[0] = gridPathData[2] = gx;
      g.drawPath(gridCommands, gridPathData);

      gx += xStep;
    }

    gridPathData[0] = border.contentInsets.left;
    gridPathData[2] = border.contentInsets.left + gridWidth;
    var gy:Number = border.contentInsets.top;
    gridPathData[1] = gridPathData[3] = gy;
    g.drawPath(gridCommands, gridPathData);
    gridPathData[1] = gridPathData[3] = gy + gridHeight - swatchBorderThickness;
    g.drawPath(gridCommands, gridPathData);
    gridPathData[0] += swatchBorderThickness;
    gridPathData[2] -= swatchBorderThickness;

    for (i = 1; i < rowCount; i++) {
      gridPathData[1] = gridPathData[3] = gy += yStep;
      g.drawPath(gridCommands, gridPathData);
    }

    g.lineStyle();
    const leftCellX:Number = border.contentInsets.left + swatchBorderThickness + cellPadding;
    const maxCellX:Number = leftCellX + ((columnCount - 1) * xStep);
    var cellX:Number = leftCellX;
    var cellY:Number = border.contentInsets.top + swatchBorderThickness + cellPadding;
    i = 0;
    while (true) {
      g.beginFill(list[i++]);
      g.drawRect(cellX, cellY, swatchWidth, swatchHeight);
      g.endFill();

      if (cellX < maxCellX) {
        cellX += xStep;
      }
      else if (i == size) {
        break;
      }
      else {
        cellY += yStep;
        cellX = leftCellX;
      }
    }
  }
}
}
