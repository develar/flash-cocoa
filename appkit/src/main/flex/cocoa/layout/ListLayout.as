package cocoa.layout {
import cocoa.AbstractView;
import cocoa.ListViewDataSource;
import cocoa.renderer.RendererManager;

[Abstract]
internal class ListLayout {
  protected var visibleItemCount:int = -1;

  protected var _container:AbstractView;
  public function set container(value:AbstractView):void {
    _container = value;
  }

  protected var _rendererManager:RendererManager;
  public function set rendererManager(value:RendererManager):void {
    _rendererManager = value;
  }

  protected var _dataSource:ListViewDataSource;
  public function set dataSource(value:ListViewDataSource):void {
    if (_dataSource == value) {
      return;
    }

    if (_dataSource != null) {
      _dataSource.reset.remove(dataSourceResetHandler);
    }

    _dataSource = value;

    if (_dataSource != null) {
      _dataSource.reset.add(dataSourceResetHandler);
    }
  }

  protected var _gap:Number = 0;
  public function set gap(value:Number):void {
    _gap = value;
  }

  private function dataSourceResetHandler():void {
    if (visibleItemCount != -1) {
      visibleItemCount = -visibleItemCount - 1;
    }

    _container.invalidateSize();
    _container.invalidateDisplayList();
  }
}
}
