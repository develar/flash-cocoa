package cocoa.layout {
import cocoa.Insets;
import cocoa.ListViewDataSource;
import cocoa.SegmentedControl;
import cocoa.renderer.RendererManager;

public interface CollectionLayout {
  function draw(w:int, h:int):void;

  function set rendererManager(rendererManager:RendererManager):void;

  function set dataSource(dataSource:ListViewDataSource):void;

  function set container(value:SegmentedControl):void;

  function set gap(gap:int):void;

  function setSelected(itemIndex:int, relatedIndex:int, value:Boolean):void;

  function set insets(value:Insets):void;

  function getPreferredWidth(hHint:int = -1):int;

  function getPreferredHeight(wHint:int = -1):int;

  function getMinimumHeight(wHint:int = -1):int;

  function getMinimumWidth(hHint:int = -1):int;

  function getMaximumWidth(hHint:int = -1):int;

  function getMaximumHeight(wHint:int = -1):int;
}
}
