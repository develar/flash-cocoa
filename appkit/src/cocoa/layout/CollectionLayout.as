package cocoa.layout {
import cocoa.SpriteBackedView;
import cocoa.Insets;
import cocoa.ListViewDataSource;
import cocoa.renderer.RendererManager;

public interface CollectionLayout {
  function measure():void;

  function layout(w:Number, h:Number):void;

  function set rendererManager(rendererManager:RendererManager):void;

  function set dataSource(dataSource:ListViewDataSource):void;

  function set container(value:SpriteBackedView):void;

  function set gap(gap:Number):void;

  function setSelected(itemIndex:int, relatedIndex:int, value:Boolean):void;

  function set insets(value:Insets):void;
}
}
