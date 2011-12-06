package cocoa.renderer {
import cocoa.SkinnableView;

import flash.display.Shape;
import flash.text.engine.TextLine;

import mx.core.IVisualElement;

public class CompositeEntry extends TextLineAndDisplayObjectEntry {
  public var components:Vector.<SkinnableView>;

  public function CompositeEntry(additionalSize:int, line:TextLine, shape:Shape, factory:CompositeEntryFactory) {
    super(line, shape, factory);

    components = new Vector.<SkinnableView>(additionalSize, true);
  }

  override public function moveX(increment:Number):void {
    super.moveX(increment);

    for each (var component:SkinnableView in components) {
      IVisualElement(component.skin).x += increment;
    }
  }

  override public function moveY(increment:Number):void {
    super.moveY(increment);

    for each (var component:SkinnableView in components) {
      IVisualElement(component.skin).y += increment;
    }
  }
}
}
