package cocoa.plaf.basic {
import cocoa.CellState;
import cocoa.HighlightableItemRenderer;
import cocoa.ListSelection;
import cocoa.Menu;
import cocoa.PopUpButton;
import cocoa.plaf.Skin;
import cocoa.ui;

import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.utils.getTimer;

import mx.core.IVisualElement;
import mx.managers.PopUpManager;

import spark.components.IItemRenderer;

use namespace ui;

[Abstract]
public class PopUpMenuInteractor extends AbstractListInteractor {
  private static const MOUSE_CLICK_INTERVAL:int = 400;

  protected var popUpButton:PopUpButton;
  protected var menu:Menu;

  private var mouseDownTime:int = -1;

  public function PopUpMenuInteractor() {
    super();

    flags |= MOUSE_HIGHLIGHTABLE;
  }

  public function register(popUpButton:PopUpButton):void {
    popUpButton.skin.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
  }

  override protected function keyDownHandler(event:KeyboardEvent):void {
    super.keyDownHandler(event);

    if (event.preventDefault()) {
      return;
    }

    switch (event.keyCode) {
      case Keyboard.ESCAPE:
        if (menu.skin != null && DisplayObject(menu.skin).parent != null) {
          event.preventDefault();
          close();
        }
        break;

      case Keyboard.ENTER:
      case Keyboard.SPACE:
        if (highlightedRenderer != null) {
          setSelectedIndex(highlightedRenderer.itemIndex);
        }
        close();
        break;
    }
  }

  private function mouseDownHandler(event:MouseEvent):void {
    if (popUpButton != null) {
      close();
    }

    popUpButton = PopUpButton(Skin(event.currentTarget).component);
    menu = popUpButton.menu;

    var popUpButtonSkin:DisplayObject = DisplayObject(popUpButton.skin);
    if (!popUpButtonSkin.hitTestPoint(event.stageX, event.stageY)) {
      return;
    }

    var menuSkin:Skin = menu.skin;
    if (menuSkin == null) {
      menuSkin = menu.createView(popUpButton.laf);
    }
    else if (DisplayObject(menuSkin).parent != null) {
      return;
    }

    menu.selectedIndex = popUpButton.selectedIndex;
    popUpButton.state = CellState.ON;

    popUpButton.skin.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);

    PopUpManager.addPopUp(menuSkin, popUpButtonSkin, false);
    menuSkin.validateNow(); // если это datagroup, то оно должно валидировать display list c item render (их y) до setPopUpPosition
    setPopUpPosition();

    itemGroup = menu.itemGroup;
    addHandlers();

    popUpButtonSkin.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
    popUpButtonSkin.stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler);

    mouseDownTime = getTimer();

    if (popUpButton.selectedIndex != ListSelection.NO_SELECTION) {
      highlightedRenderer = itemGroup.getElementAt(popUpButton.selectedIndex) as HighlightableItemRenderer;
      if (highlightedRenderer != null) {
        highlightedRenderer.highlighted = true;
      }
    }
  }

  protected function close():void {
    popUpButton.state = CellState.OFF;

    var stage:Stage = DisplayObject(popUpButton.skin).stage;
    stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
    stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler);
    PopUpManager.removePopUp(menu.skin);

    popUpButton.skin.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);

    menu = null;
    popUpButton = null;
  }

  protected function setPopUpPosition():void {
    throw new Error("abstract");
  }

  private function stageMouseUpHandler(event:MouseEvent):void {
    var proposedSelectedIndex:int = -1;
    // проверка на border (как в Cocoa — можно кликнуть на border, и при этом и меню не будет скрыто, и выделенный item не изменится)
    if (!menu.skin.hitTestPoint(event.stageX, event.stageY)) {
      // для pop up button работает такое же правило щелчка, как и для menu border
      if (!popUpButton.skin.hitTestPoint(event.stageX, event.stageY)) {
        mouseDownTime = -1;
      }
    }
    else if (event.target != menu.skin && event.target != itemGroup) {
      proposedSelectedIndex = highlightedRenderer is IItemRenderer ? IItemRenderer(highlightedRenderer).itemIndex : findItemIndexForEventTarget(DisplayObject(event.target));
    }
    else {
      return;
    }

    if (mouseDownTime == -1 || (getTimer() - mouseDownTime) > MOUSE_CLICK_INTERVAL) {
      if (proposedSelectedIndex != -1) {
        setSelectedIndex(proposedSelectedIndex);
      }
      close();
    }
    else {
      mouseDownTime = -1;
    }
  }

  private function findItemIndexForEventTarget(target:DisplayObject):int {
    while (target.parent != itemGroup) {
      target = target.parent;
    }

    return target is IItemRenderer ? IItemRenderer(target).itemIndex : itemGroup.getElementIndex(IVisualElement(target));
  }

  // данный обработчик будет вызван и в первый раз после mouseDownHandler — событие пойдет вниз до stage —
  // а мы не может ни preventDefault, ни stopPropagation — так как на них завязан FocusManager, поэтому мы делаем проверку на mouseDownTime
  private function stageMouseDownHandler(event:MouseEvent):void {
    if (mouseDownTime == -1 && !menu.skin.hitTestPoint(event.stageX, event.stageY)) {
      close();
    }
  }

  protected function setSelectedIndex(value:int):void {
    popUpButton.setSelectedIndex(value);
  }
}
}