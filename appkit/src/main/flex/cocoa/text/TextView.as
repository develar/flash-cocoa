package cocoa.text {
import flash.display.Sprite;
import flash.geom.Rectangle;

import flashx.textLayout.edit.SelectionManager;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.CompositionCompleteEvent;

/**
 * Not editable text view, only display
 */
public class TextView extends AbstractTextView {
  private var container:Sprite;
  private var containerController:ContainerController;

  override protected function get scrollController():ScrollController {
    return containerController;
  }

  public function set maxDisplayedLines(value:int):void {

  }

  public function set textFlow(value:TextFlow):void {
    if (_textFlow == value) {
      return;
    }

    if (_textFlow != null) {
      _textFlow.removeEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, textFlowCompositionCompleteHandler);
      if (_textFlow.flowComposer != null) {
        _textFlow.flowComposer.removeAllControllers();
      }
    }

    _textFlow = value;
    // add controller immediately to mark that textFlow already in use
    if (_textFlow != null) {
      _textFlow.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, textFlowCompositionCompleteHandler);
      if (containerController == null) {
        createController();
      }
      _textFlow.flowComposer.addController(containerController);
      setSelectionManager();
    }

    //!! invalidateProperties();
    //!! invalidateDisplayList();
  }

  public function set selectable(value:Boolean):void {
    if (value != _selectable) {
      _selectable = value;
      if (_textFlow != null) {
        setSelectionManager();
        //!! invalidateDisplayList();
      }
    }
  }

  private function setSelectionManager():void {
    if (_selectable && _textFlow.interactionManager == null) {
      _textFlow.interactionManager = new SelectionManager();
    }
    else if (!_selectable && _textFlow.interactionManager != null) {
      _textFlow.interactionManager = null;
    }
  }

  private function createController():void {
    container = new Sprite();
    //addDisplayObject(container);
    containerController = new ContainerController(container, 0, 0);
  }

  private function textFlowCompositionCompleteHandler(event:CompositionCompleteEvent):void {
    var oldContentWidth:Number = _contentWidth;
    var oldContentHeight:Number = _contentHeight;

    var newContentBounds:Rectangle = containerController.getContentBounds();

    var newContentWidth:Number = newContentBounds.width;
    var newContentHeight:Number = newContentBounds.height;

    if (newContentWidth != oldContentWidth) {
      _contentWidth = newContentWidth;

      //trace("composeWidth", containerController.compositionWidth, "contentWidth", oldContentWidth, newContentWidth);

      // If there is a scroller, this triggers the scroller layout.
      //!! dispatchPropertyChangeEvent("contentWidth", oldContentWidth, newContentWidth);
    }

    if (newContentHeight != oldContentHeight) {
      _contentHeight = newContentHeight;
      //trace("composeHeight", containerController.compositionHeight, "contentHeight", oldContentHeight, newContentHeight);

      // If there is a scroller, this triggers the scroller layout.
      //dispatchPropertyChangeEvent("contentHeight", oldContentHeight, newContentHeight);
    }
  }

  //override protected function measure():void {
  //  super.measure();
  //
  //  if (!isNaN(explicitWidth)) {
  //    measuredWidth = explicitWidth;
  //  } else if (_textFlow != null) {
  //    measuredWidth = containerController.compositionWidth;
  //  }
  //
  //  if (!isNaN(explicitHeight)) {
  //    measuredHeight = explicitHeight;
  //  } else if (_textFlow != null) {
  //    measuredHeight = containerController.compositionHeight;
  //  }
  //}
  //
  //override protected function updateDisplayList(w:Number, h:Number):void {
  //  if (_textFlow != null) {
  //    containerController.setCompositionSize(w, h);
  //    _textFlow.flowComposer.updateToController();
  //  }

  //}
}
}