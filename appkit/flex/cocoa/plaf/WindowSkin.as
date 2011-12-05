package cocoa.plaf {
import cocoa.Toolbar;
import cocoa.View;

public interface WindowSkin extends TitledComponentSkin {
  function set toolbar(value:Toolbar):void;

  function set contentView(value:View):void;
}
}