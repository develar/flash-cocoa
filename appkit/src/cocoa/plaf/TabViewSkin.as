package cocoa.plaf {
import cocoa.Toolbar;
import cocoa.View;

public interface TabViewSkin {
  function show(view:View):void;
  function hide():void;

  function toolbarChanged(oldToolbar:Toolbar, newToolbar:Toolbar):void;
}
}
