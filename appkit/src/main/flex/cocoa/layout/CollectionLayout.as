package cocoa.layout {
import cocoa.AbstractView;
import cocoa.ListViewDataSource;
import cocoa.renderer.RendererManager;

public interface CollectionLayout {
  function measure():void;

  function updateDisplayList(w:Number, h:Number):void;

  function set rendererManager(rendererManager:RendererManager):void;

  function set dataSource(dataSource:ListViewDataSource):void;

  function set container(value:AbstractView):void;

  function set gap(gap:Number):void;
}
}
