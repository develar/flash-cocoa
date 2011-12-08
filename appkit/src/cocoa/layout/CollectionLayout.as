package cocoa.layout {
import cocoa.Insets;
import cocoa.ListViewDataSource;
import cocoa.SegmentedControl;
import cocoa.renderer.RendererManager;

public interface CollectionLayout {
  function layout(w:int, h:int):void;

  function set rendererManager(rendererManager:RendererManager):void;

  function set dataSource(dataSource:ListViewDataSource):void;

  function set container(value:SegmentedControl):void;

  function set gap(gap:Number):void;

  function setSelected(itemIndex:int, relatedIndex:int, value:Boolean):void;

  function set insets(value:Insets):void;

  function getPreferredWidth(hHint:int):int;

  function getPreferredHeight(wHint:int):int;
}
}
