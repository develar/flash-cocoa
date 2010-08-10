package cocoa.colorPicker {
import flash.display.CapsStyle;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.events.MouseEvent;

public class SwatchGridWithHighlightIndicator extends SwatchGrid {
  private var highlightIndicator:Shape;

  public function SwatchGridWithHighlightIndicator() {
    super();

    addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
    addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
  }

  private function mouseOutHandler(event:MouseEvent):void {
    if (highlightIndicator != null) {
      highlightIndicator.visible = false;
    }
  }

  private function mouseMoveHandler(event:MouseEvent):void {
    const xOffset:Number = border.contentInsets.left + swatchBorderThickness;
    const yOffset:Number = border.contentInsets.top + swatchBorderThickness;
    if (event.localX > (width - xOffset) || event.localY > (height - yOffset)) {
      mouseOutHandler(null);
      return;
    }
    
    if (highlightIndicator == null) {
      highlightIndicator = new Shape();
      highlightIndicator.graphics.lineStyle(2, 0x0f53ec, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
      highlightIndicator.graphics.drawRect(0, 0, swatchWidth + (cellPadding * 2), swatchHeight + (cellPadding * 2));
      addChild(highlightIndicator);
    }

    var cellX:Number = event.localX;
    cellX -= (cellX - xOffset) % xStep;
    var columnIndex:int = (cellX - xOffset) / xStep;


    var cellY:Number = event.localY;
    cellY -= (cellY - yOffset) % yStep;
    var rowIndex:int = (cellY - yOffset) / yStep;

    var colorIndex:int = (rowIndex * columnCount) + columnIndex;
    if (colorIndex >= list.length) {
      mouseOutHandler(null);
      return;
    }

    highlightIndicator.x = cellX;
    highlightIndicator.y = cellY;
    highlightIndicator.visible = true;
  }
}
}