package cocoa.renderer {
import flash.display.DisplayObject;
import flash.text.engine.TextLine;

public class TextLineAndDisplayObjectEntry extends TextLineEntry {
  public var displayObject:DisplayObject;
  private var factory:TextLineAndDisplayObjectEntryFactory;

  function TextLineAndDisplayObjectEntry(line:TextLine, displayObject:DisplayObject, factory:TextLineAndDisplayObjectEntryFactory) {
    super(line);
    this.displayObject = displayObject;
    this.factory = factory;
  }

  override public function addToPool():void {
    factory.addToPool(this);
  }

  override public function getY(textLineYAdjustment:Number):Number {
    return displayObject.y;
  }

  override public function moveX(increment:Number):void {
    if (line != null) {
      super.moveX(increment);
    }

    displayObject.x += increment;
  }

  override public function moveY(increment:Number):void {
    if (line != null) {
      super.moveY(increment);
    }

    displayObject.y += increment;
  }
}
}
