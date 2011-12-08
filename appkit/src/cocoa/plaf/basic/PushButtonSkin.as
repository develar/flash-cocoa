package cocoa.plaf.basic {
import cocoa.AbstractButton;
import cocoa.Border;
import cocoa.Cell;
import cocoa.CellState;
import cocoa.SkinnableView;
import cocoa.Focusable;
import cocoa.Insets;
import cocoa.TextInsets;
import cocoa.plaf.ButtonSkinInteraction;

import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.events.MouseEvent;

public class PushButtonSkin extends TitledComponentSkin implements Focusable, ButtonSkinInteraction {
  protected var border:Border;
  protected var myComponent:Cell;

  public function PushButtonSkin() {
    mouseChildren = false;

    flags |= HAS_BASELINE;
  }

  //noinspection JSMethodCanBeStatic
  protected function get hoverable():Boolean {
    return false;
  }

  private var responsibleForInteraction:Boolean = true;
  public function delegateInteraction():void {
    responsibleForInteraction = false;
  }

  protected function get bordered():Boolean {
    return true;
  }

  override public function attach(component:SkinnableView):void {
    super.attach(component);

    myComponent = Cell(component);
  }

  override public function getBaseline(width:int, height:int):int {
    return border.layoutHeight - border.contentInsets.bottom;
  }

  public function get labelLeftMargin():Number {
    return border.contentInsets.left;
  }

  override public function getMinimumWidth(hHint:int = -1):int {
    return getPreferredWidth();
  }

  override public function getMinimumHeight(wHint:int = -1):int {
    return getPreferredHeight();
  }

  override public function getPreferredWidth(hHint:int = -1):int {
    if (labelHelper == null || !labelHelper.hasText) {
      return border.layoutWidth;
    }
    else {
      labelHelper.validate();
      return Math.round(labelHelper.textWidth) + border.contentInsets.width;
    }
  }

  override public function getPreferredHeight(wHint:int = -1):int {
    return border.layoutHeight;
  }

  override public function getMaximumWidth(hHint:int = -1):int {
    return getPreferredWidth();
  }

  override public function getMaximumHeight(wHint:int = -1):int {
    return getPreferredHeight();
  }

  override protected function doInit():void {
    super.doInit();

    if (responsibleForInteraction) {
      addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
      if (hoverable) {
        addHoverHandlers();
      }
    }
    else {
      mouseEnabled = false;
    }

    if (bordered) {
      border = getBorder();
    }
  }

  override protected function draw(w:int, h:int):void {
    if (labelHelper != null && labelHelper.hasText) {
      if (myComponent.state == CellState.MIXED) {
        if (labelHelper.textLine != null && labelHelper.textLine.parent != null) {
          removeChild(labelHelper.textLine);
        }
      }
      else {
        if (labelHelper.textLine != null && labelHelper.textLine.parent == null) {
          addChild(labelHelper.textLine);
        }

        if (border != null) {
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

  public function set enabled(value:Boolean):void {
    //!! super.enabled = value;

    if (responsibleForInteraction) {
      mouseEnabled = value;
    }
  }

  public function mouseDownHandler(event:MouseEvent):void {
    if (responsibleForInteraction) {
      stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
      if (!hoverable) {
        addHoverHandlers();
      }
    }

    if (!hoverable) {
      mouseOverHandler(event);
    }
  }

  private function stageMouseUpHandler(event:MouseEvent):void {
    stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

    if (!hoverable) {
      removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
      removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
    }

    if (event.target == this) {
      mouseUpHandler(event);
    }
  }

  public function mouseUpHandler(event:MouseEvent):void {
    var state:int = CellState.OFF;
    if (toggled) {
      state = myComponent.state == CellState.OFF ? CellState.ON : CellState.OFF;
    }

    AbstractButton(hostComponent).setStateAndCallUserInitiatedActionHandler(state);

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

  public function get focusObject():InteractiveObject {
    return this;
  }
}
}