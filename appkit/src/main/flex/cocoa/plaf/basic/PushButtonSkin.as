package cocoa.plaf.basic {
import cocoa.Border;
import cocoa.Cell;
import cocoa.Component;
import cocoa.Insets;
import cocoa.TextInsets;
import cocoa.plaf.LookAndFeel;

import flash.display.Graphics;

import mx.managers.IFocusManagerComponent;

public class PushButtonSkin extends TitledComponentSkin implements IFocusManagerComponent {
  protected var border:Border;
  protected var myComponent:Cell;

  public function PushButtonSkin() {
    super();

    mouseChildren = false;
  }

  protected function get bordered():Boolean {
    return true;
  }

  override public function attach(component:Component, laf:LookAndFeel):void {
    super.attach(component, laf);

    myComponent = Cell(component);
  }

  override public function get baselinePosition():Number {
    return border.layoutHeight - border.contentInsets.bottom;
  }

  public function get labelLeftMargin():Number {
    return border.contentInsets.left;
  }

  override protected function createChildren():void {
    super.createChildren();

    if (bordered) {
      border = getBorder("border");
    }
  }

  override protected function measure():void {
    if (labelHelper == null || !labelHelper.hasText) {
      measuredWidth = border.layoutWidth;
      measuredHeight = border.layoutHeight;
    }
    else {
      labelHelper.validate();

      measuredWidth = Math.round(labelHelper.textWidth) + border.contentInsets.width;
      measuredHeight = border.layoutHeight;
    }
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    if (labelHelper != null && labelHelper.hasText) {
      if (border != null && (!isNaN(explicitWidth) || !isNaN(percentWidth))) {
        var titleInsets:Insets = border.contentInsets;
        labelHelper.adjustWidth(w - titleInsets.left - (titleInsets is TextInsets ? TextInsets(titleInsets).truncatedTailMargin : titleInsets.right));
      }

      labelHelper.validate();
      labelHelper.alpha = enabled ? 1 : 0.5;
      labelHelper.moveByInsets(h, border.contentInsets);
    }

    var g:Graphics = graphics;
    g.clear();
    border.draw(this, g, w, h);
  }

  override public function set enabled(value:Boolean):void {
    super.enabled = value;

    mouseEnabled = value;
  }

  public function drawFocus(isFocused:Boolean):void {
  }
}
}