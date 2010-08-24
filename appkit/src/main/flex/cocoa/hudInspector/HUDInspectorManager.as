package cocoa.hudInspector {
import cocoa.HUDWindow;
import cocoa.View;
import cocoa.Viewable;
import cocoa.dialog.DialogManager;
import cocoa.pane.PaneItem;
import cocoa.resources.ResourceManager;

import flash.events.Event;
import flash.geom.Point;
import flash.utils.Dictionary;

import mx.core.IUIComponent;
import mx.core.IVisualElement;

public class HUDInspectorManager {
  private static const WINDOW_PADDING:Number = 10;

  private static var sharedPoint:Point = new Point();

  private var inspectorSetMap:Dictionary/*<Class, PaneItem>*/ = new Dictionary();
  private var currentInspector:HUDWindow;

  private var cache:Dictionary/*<PaneItem, HUDWindow>*/;

  public function register(objectClass:Class, inspectorItem:PaneItem):void {
    inspectorSetMap[objectClass] = inspectorItem;
  }

  private var dialogManager:DialogManager;

  public function HUDInspectorManager(dialogManager:DialogManager) {
    this.dialogManager = dialogManager;
  }

  public function changeCurrentVisibility(visible:Boolean):void {
    if (currentInspector != null) {
      IVisualElement(currentInspector.skin).visible = visible;
    }
  }

  public function show(element:Object, elementView:View):void {
    var inspectorContentView:Viewable;
    // такое будет если при hide мы обнаруживаем что новый элемент имеет такой же тип и не скрываем инспектор, а ничего не делаем
    if (currentInspector != null) {
      inspectorContentView = currentInspector.contentView;
    }
    else {
      var clazz:Class = Class(element.constructor);
      var inspectorItem:PaneItem = inspectorSetMap[clazz];
      if (inspectorItem == null) {
        return;
      }

      if (cache == null) {
        cache = new Dictionary();
      }
      else {
        currentInspector = cache[inspectorItem];
      }

      if (currentInspector == null) {
        currentInspector = new HUDWindow();
        currentInspector.resizable = false;
        currentInspector.title = ResourceManager.instance.getStringByRM(inspectorItem.label);
        inspectorItem.view = currentInspector.contentView = inspectorItem.viewFactory.newInstance();
        cache[inspectorItem] = currentInspector;

        currentInspector.addEventListener(Event.CLOSE, userCloseHandler, false, 1);
      }

      inspectorContentView = inspectorItem.view
    }

    if (inspectorContentView is ElementRecipient) {
      ElementRecipient(inspectorContentView).element = element;
    }

    dialogManager.open(currentInspector, false, false);

    sharedPoint.x = elementView.x;
    sharedPoint.y = elementView.y;
    sharedPoint = elementView.parent.localToGlobal(sharedPoint);

    var inspectorView:IUIComponent = currentInspector.skin;
    var windowHeightWithPadding:Number = inspectorView.height + WINDOW_PADDING;
    var y:Number = sharedPoint.y - windowHeightWithPadding;
    if (y < 0) {
      y = sharedPoint.y + elementView.height + windowHeightWithPadding;
    }

    inspectorView.move(Math.round(sharedPoint.x + (elementView.width / 2) - (inspectorView.width / 2)), Math.round(y));
  }

  private function userCloseHandler(event:Event):void {
    event.stopImmediatePropagation();

    close();
  }

  public function hide(element:Object, relatedElement:Object):void {
    if (currentInspector == null || (relatedElement != null && element.constructor == relatedElement.constructor)) {
      return;
    }

    close();
  }

  private function close():void {
    if (currentInspector.contentView is ElementRecipient) {
      ElementRecipient(currentInspector.contentView).element = null;
    }

    dialogManager.close(currentInspector);
    currentInspector = null;
  }
}
}