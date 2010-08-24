package cocoa.colorPicker {
import flash.display.CapsStyle;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.events.MouseEvent;

public class SwatchGridWithHighlightIndicator extends SwatchGrid {
  private var highlightIndicator:Shape;

  private var colorIndex:int = -1;

  public function SwatchGridWithHighlightIndicator() {
    super();

    addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
    addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
    addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
  }

  private function mouseOutHandler(event:MouseEvent):void {
    if (highlightIndicator != null) {
      highlightIndicator.visible = false;
    }

    colorIndex = -1;
  }

  private function mouseMoveHandler(event:MouseEvent):void {
    const xOffset:Number = border.contentInsets.left + swatchBorderThickness;
    const yOffset:Number = border.contentInsets.top + swatchBorderThickness;
    if (event.localX > (width - xOffset) || event.localY > (height - yOffset)) {
      mouseOutHandler(null);
      return;
    }
    
    if (highlightIndicator == null) {
      createHighlightIndicator();
    }

    var cellX:Number = event.localX;
    cellX -= (cellX - xOffset) % xStep;

    var cellY:Number = event.localY;
    cellY -= (cellY - yOffset) % yStep;

    colorIndex = (((cellY - yOffset) / yStep) * columnCount) + ((cellX - xOffset) / xStep);
    if (colorIndex >= list.length) {
      mouseOutHandler(null);
      return;
    }

    highlightIndicator.x = cellX;
    highlightIndicator.y = cellY;
    highlightIndicator.visible = true;
  }

  private function createHighlightIndicator():void {
    highlightIndicator = new Shape();
    highlightIndicator.graphics.lineStyle(1, 0xb4d4ff, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
    highlightIndicator.graphics.drawRect(0.5, 0.5, swatchWidth + (cellPadding * 2) - 1, swatchHeight + (cellPadding * 2) - 1);
    addChild(highlightIndicator);
  }

  private function mouseUpHandler(event:MouseEvent):void {
    if (colorIndex != -1) {
      dispatchEvent(new ColorEvent(list[colorIndex]));
    }
  }
}
}