package cocoa.colorPicker {
import cocoa.Border;

import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.LineScaleMode;
import flash.display.Shape;

public class SwatchGrid extends Shape {
  public function drawGrid(list:Vector.<uint>, border:Border):void {
    var g:Graphics = graphics;
    g.clear();

    const horizontalGap:Number = 1;
    const verticalGap:Number = 1;
    //        var previewWidth:Number = 45;
    //        var swatchGridBackgroundColor:uint = 0;
    const swatchHeight:Number = 12;
    const swatchWidth:Number = 12;
    //        var textFieldWidth:Number = 72;

    const swatchBorderSize:Number = 1;
    const swatchBorderColor:uint = 0xffffff;

    const size:int = list.length;
    const columnCount:int = 19;
    const rowCount:int = Math.ceil(size / columnCount);

    const xStep:Number = swatchWidth + horizontalGap;
    const yStep:Number = swatchHeight + verticalGap;

    const gridWidth:Number = (columnCount * xStep) - horizontalGap;
    const gridHeight:Number = (rowCount * yStep) - verticalGap;

    border.draw(null, g, gridWidth + border.contentInsets.width, gridHeight + border.contentInsets.height);

    if (swatchBorderSize > 0) {
      g.lineStyle(swatchBorderSize, swatchBorderColor, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
    }
    else {
      g.lineStyle();
    }

    var cellX:Number = border.contentInsets.left + 0.5;
    var cellY:Number = border.contentInsets.top + 0.5;
    const maxCellX:Number = cellX + gridWidth - xStep;
    var i:int;
    while (true) {
      g.beginFill(list[i++]);
      g.drawRect(cellX, cellY, swatchWidth - 1, swatchHeight - 1);
      g.endFill();

      if (cellX < maxCellX) {
        cellX += xStep;
      }
      else if (i == size) {
        break;
      }
      else {
        cellY += yStep;
        cellX = border.contentInsets.left + 0.5;
      }
    }
  }
}
}
