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

  override protected function doInit():void {
    super.doInit();

    border = getBorder();

    textDisplay = new EditableTextView();
    if (!enabled) {
      textDisplay.enabled = false;
    }
    textDisplay.textFormat = ITextLayoutFormat(getObject("SystemTextFormat"));
    textDisplay.selectionFormat = SelectionFormat(_laf.getObject("SelectionFormat"));
    configureAndAddTextDisplay();

    documentView.setLocation(border.contentInsets.left, border.contentInsets.top);
    component.uiPartAdded("textDisplay", textDisplay);
  }

  protected function configureAndAddTextDisplay():void {
    textDisplay.height = getPreferredHeight() - border.contentInsets.height;
    textDisplay.addToSuperview(this, laf, superview);
  }

  protected function get documentView():View {
    return textDisplay;
  }

  override public function getMinimumWidth(hHint:int = -1):int {
    return border.contentInsets.width;
  }

  override public function getMinimumHeight(wHint:int = -1):int {
    return getPreferredHeight();
  }

  override public function getPreferredWidth(hHint:int = -1):int {
    // 96 default cocoa "Text Field" width
    return 96 + border.contentInsets.width;
  }

  override public function getPreferredHeight(wHint:int = -1):int {
    if (isNaN(border.layoutHeight)) {
      // Regular size: 22 pixels high, Small size: 19
      return laf.controlSize == null ? 22 : 19;
    }
    else {
      return border.layoutHeight;
    }
  }

  override protected function draw(w:int, h:int):void {
    var g:Graphics = graphics;
    g.clear();
    border.draw(g, w, h, 0, 0, this);
    
    g.lineStyle(1);
    g.drawRect(0, 0, w, h);

    documentView.setSize(w - border.contentInsets.width, h - border.contentInsets.height);
    documentView.validate();
  }

  override public function set enabled(value:Boolean):void {
    if (value != enabled) {
      super.enabled = value;
      if (documentView != null) {
        documentView.enabled = value;
      }
    }
  }

  public function get focusObject():InteractiveObject {
    return textDisplay;
  }
}
}