package cocoa.renderer {
import cocoa.Border;
import cocoa.TextLineInsets;
import cocoa.border.BorderStateIndex;
import cocoa.border.StatefulBorder;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.TextFormatId;

import flash.display.Graphics;
import flash.display.Shape;
import flash.text.engine.TextLine;
import flash.text.engine.TextRotation;

public class InteractiveBorderRendererManager extends InteractiveGraphicsRendererManager {
  private var border:Border;
  private var textLineInsets:TextLineInsets;
  private var selectingItemIndex:int;

  public function InteractiveBorderRendererManager(laf:LookAndFeel, lafKey:String) {
    border = laf.getBorder(lafKey + ".b");
    textLineInsets = TextLineInsets(laf.getObject(lafKey + ".textLineInsets"));
    if (textLineInsets != null) {
      textRotation = textLineInsets.rotation;
    }
  }

  override protected function layoutTextLine(line:TextLine, x:Number, y:Number, h:Number):void {
    if (textLineInsets == null) {
      super.layoutTextLine(line, x, y, h);
      return;
    }

    switch (textLineInsets.rotation) {
      case TextRotation.ROTATE_90:
        line.x = x + textLineInsets.baseline;
        line.y = y + textLineInsets.lineStartPadding;
        break;

      case null:
      case TextRotation.ROTATE_0:
        line.x = x + textLineInsets.lineStartPadding;
        line.y = y + textLineInsets.baseline;
        break;

      default:
        throw new ArgumentError("unsupported rotation: " + textLineInsets.rotation);
    }
  }

  override protected function computeCreatingRendererSize(w:Number, h:Number, line:TextLine):void {
    if (w != w) {
      _lastCreatedRendererWidth = Math.round(line.textWidth) + textLineInsets.lineStartPadding + textLineInsets.lineEndPadding;
    }
    else {
      _lastCreatedRendererHeigth = Math.round(line.height);
      if (textRotation == TextRotation.ROTATE_90) {
        _lastCreatedRendererHeigth += textLineInsets.lineStartPadding + textLineInsets.lineEndPadding;
      }
    }
  }

  override protected function drawEntry(itemIndex:int, g:Graphics, w:Number, h:Number, x:Number, y:Number):void {
    if (border is StatefulBorder) {
      StatefulBorder(border).stateIndex = _selectionModel.isItemSelected(itemIndex) ? BorderStateIndex.ON : BorderStateIndex.OFF;
    }

    border.draw(g, w != w ? _lastCreatedRendererWidth : w, h != h ? _lastCreatedRendererHeigth : h);
  }

  override public function setSelecting(itemIndex:int, value:Boolean):void {
    if (!(border is StatefulBorder)) {
      return;
    }

    if (selectingItemIndex == itemIndex && value) {
      return;
    }

    selectingItemIndex = value ? itemIndex : -1;

    if (_selectionModel.isItemSelected(itemIndex) && !value) {
      return;
    }

    StatefulBorder(border).stateIndex = value ? BorderStateIndex.ON : BorderStateIndex.OFF;

    drawOnInteract(itemIndex);
  }

  private function drawOnInteract(itemIndex:int):void {
    var shape:Shape = Shape(TextLineAndDisplayObjectEntry(findEntry(itemIndex)).displayObject);
    var g:Graphics = shape.graphics;
    g.clear();
    border.draw(g, shape.width, shape.height);
  }

  override public function setSelected(itemIndex:int, value:Boolean):void {
    if (!(border is StatefulBorder)) {
      return;
    }

    if (selectingItemIndex == itemIndex && value) {
      return;
    }

    selectingItemIndex = -1;
    StatefulBorder(border).stateIndex = value ? BorderStateIndex.ON : BorderStateIndex.OFF;
    drawOnInteract(itemIndex);
  }
}
}
