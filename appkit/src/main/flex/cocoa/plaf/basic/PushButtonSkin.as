package cocoa.plaf.basic {
import cocoa.AbstractButton;
import cocoa.Border;
import cocoa.Cell;
import cocoa.CellState;
import cocoa.Component;
import cocoa.Insets;
import cocoa.TextInsets;
import cocoa.plaf.ButtonSkinInteraction;
import cocoa.plaf.LookAndFeel;

import flash.display.Graphics;
import flash.events.Event;
import flash.events.MouseEvent;

import mx.managers.IFocusManagerComponent;

public class PushButtonSkin extends TitledComponentSkin implements IFocusManagerComponent, ButtonSkinInteraction {
  protected var border:Border;
  protected var myComponent:Cell;

  public function PushButtonSkin() {
    mouseChildren = false;
  }

  private var responsibleForInteraction:Boolean = true;
  public function deletegateInteraction():void {
    responsibleForInteraction = false;
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

    if (responsibleForInteraction) {
      addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
    }
    else {
      mouseEnabled = false;
    }

    if (bordered) {
      border = getBorder();
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
      if (myComponent.state == CellState.MIXED) {
        if (labelHelper.textLine != null && labelHelper.textLine.parent != null) {
          removeDisplayObject(labelHelper.textLine);
        }
      }
      else {
        if (labelHelper.textLine != null && labelHelper.textLine.parent == null) {
          addDisplayObject(labelHelper.textLine);
        }

        if (border != null && (!isNaN(explicitWidth) || !isNaN(percentWidth))) {
          var titleInsets:Insets = border.contentInsets;
          labelHelper.adjustWidth(w - titleInsets.left - (titleInsets is TextInsets ? TextInsets(titleInsets).truncatedTailMargin : titleInsets.right));
        }

        labelHelper.validate();
        labelHelper.textLine.alpha = enabled ? 1 : 0.5;
        labelHelper.moveByInsets(h, border.contentInsets);
      }
    }

    drawBorder2(w, h);
  }

  protected function drawBorder2(w:Number, h:Number):void {
    var g:Graphics = graphics;
    g.clear();
    border.draw(g, w, h, 0, 0, this);
  }

  protected function drawBorder():void {
    drawBorder2(width, height);
  }

  override public function set enabled(value:Boolean):void {
    super.enabled = value;

    if (responsibleForInteraction) {
      mouseEnabled = value;
    }
  }

  public function drawFocus(isFocused:Boolean):void {
  }

  public function mouseDownHandler(event:MouseEvent):void {
    if (responsibleForInteraction) {
      stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
      addHoverHandlers();
    }
    
    mouseOverHandler(event);
  }

  private function stageMouseUpHandler(event:MouseEvent):void {
    stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

    removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
    removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);

    if (event.target == this) {
      mouseUpHandler(event);
    }
  }

  public function mouseUpHandler(event:MouseEvent):void {
    var state:int = CellState.OFF;
    if (toggled) {
      state = myComponent.state == CellState.OFF ? CellState.ON : CellState.OFF;
    }

    if (component.hasEventListener("selectedChanged")) {
      component.dispatchEvent(new Event("selectedChanged"));
    }

    AbstractButton(component).setStateAndCallUserInitiatedActionHandler(state);

    mouseUp();
    drawBorder();
    event.updateAfterEvent();
  }

  protected function mouseUp():void {

  }

  public function mouseOverHandler(event:MouseEvent):void {
    drawBorder();
    event.updateAfterEvent();
  }

  public function mouseOutHandler(event:MouseEvent):void {
    drawBorder();
    event.updateAfterEvent();
  }

  protected function get toggled():Boolean {
    return false;
  }

  private function addHoverHandlers():void {
    addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
    addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
  }
}
}