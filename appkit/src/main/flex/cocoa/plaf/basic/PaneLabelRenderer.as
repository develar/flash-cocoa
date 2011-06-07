package cocoa.plaf.basic {
import cocoa.SelectableDataGroup;
import cocoa.TextLineInsets;
import cocoa.plaf.LookAndFeel;

import flash.display.Graphics;

public class PaneLabelRenderer extends LabeledItemRenderer {
  override public function set laf(value:LookAndFeel):void {
    super.laf = value;
    labelHelper.textLineInsets = TextLineInsets(_laf.getObject(lafPrefix + ".tLI"));
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    labelHelper.validate();

    var g:Graphics = graphics;
    g.clear();
    getBorder("b." + ((state & SELECTED || state & HIGHLIGHTED) ? "on" : "off")).draw(g, w, h);
  }

  override public function get lafPrefix():String {
    return SelectableDataGroup(parent).lafSubkey + ".iR";
  }

  override protected function measure():void {
    if (labelHelper.textLineInsets.rotation != null) {
      measuredHeight = labelHelper.measureHeight();
    }
    else {
      measuredWidth = labelHelper.measureWidth();
    }
  }
}
}
