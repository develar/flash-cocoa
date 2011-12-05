package cocoa.plaf.aqua {
import cocoa.Border;
import cocoa.Focusable;
import cocoa.View;
import cocoa.plaf.basic.AbstractSkin;
import cocoa.text.EditableTextView;

import flash.display.Graphics;
import flash.display.InteractiveObject;

import flashx.textLayout.edit.SelectionFormat;

import flashx.textLayout.formats.ITextLayoutFormat;

/**
 * http://developer.apple.com/mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGControls/XHIGControls.html#//apple_ref/doc/uid/TP30000359-TPXREF225
 */
public class TextInputSkin extends AbstractSkin implements Focusable {
  protected var textDisplay:EditableTextView;

  protected var border:Border;

  override protected function createChildren():void {
    super.createChildren();

    border = getBorder();

    textDisplay = new EditableTextView();
    if (!enabled) {
      //textDisplay.enabled = false;
    }
    textDisplay.textFormat = ITextLayoutFormat(getObject("SystemTextFormat"));
    textDisplay.selectionFormat = SelectionFormat(getObject("SelectionFormat"));
    configureAndAddTextDisplay();
    //documentView.x = border.contentInsets.left;
    //documentView.y = border.contentInsets.top;
    hostComponent.uiPartAdded("textDisplay", textDisplay);
  }

  protected function configureAndAddTextDisplay():void {
    height = isNaN(border.layoutHeight) ? 22 /* Regular size: 22 pixels high */ : border.layoutHeight;
    textDisplay.height = height - border.contentInsets.height;
    addChild(textDisplay);
  }

  protected function get documentView():View {
    return textDisplay;
  }

  //override protected function measure():void {
  //  measuredWidth = Math.ceil(documentView.getExplicitOrMeasuredWidth()) + border.contentInsets.width;
  //}

  override protected function draw(w:int, h:int):void {
    var g:Graphics = graphics;
    g.clear();
    border.draw(g, w, h, 0, 0, this);

    //documentView.setActualSize(w - border.contentInsets.width, h - border.contentInsets.height);
  }

  //override public function set enabled(value:Boolean):void {
  //  if (value != enabled) {
  //    //super.enabled = value;
  //    if (documentView != null) {
  //      //documentView.enabled = value;
  //    }
  //  }
  //}

  public function get focusObject():InteractiveObject {
    return textDisplay;
  }
}
}