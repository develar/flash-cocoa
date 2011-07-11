package cocoa.renderer {
import cocoa.Border;
import cocoa.TextLineInsets;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.TextFormatId;

import flash.display.Shape;
import flash.text.engine.TextLine;
import flash.text.engine.TextRotation;

public class InteractiveBorderRendererManager extends InteractiveGraphicsRendererManager {
  private var border:Border;
  private var textLineInsets:TextLineInsets;

  public function InteractiveBorderRendererManager(laf:LookAndFeel, lafKey:String) {

    super(laf.getTextFormat(TextFormatId.SYSTEM), null);

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

  override protected function drawEntry(itemIndex:int, shape:Shape, w:Number, h:Number):void {
    border.draw(shape.graphics, w != w ? _lastCreatedRendererWidth : w, h != h ? _lastCreatedRendererHeigth : h);
  }
}
}
