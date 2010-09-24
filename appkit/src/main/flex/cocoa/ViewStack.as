package cocoa {
import cocoa.layout.AdvancedLayout;

import mx.core.ILayoutElement;
import mx.core.IUIComponent;

[DefaultProperty("mxmlContent")]
public class ViewStack extends LayoutlessContainer implements AdvancedLayout {
  private var currentView:IUIComponent;

  private var _subviews:Array;

  public function set mxmlContent(value:Array):void {
    _subviews = value;
  }

  override protected function createChildren():void {
    super.createChildren();

    if (_subviews != null) {
      show(_subviews[0]);
    }
  }

  public function show(viewable:Viewable):void {
    if (currentView != null) {
      currentView.visible = false;
    }

    if (viewable is Component) {
      currentView = Component(viewable).skin;
      if (currentView == null) {
        addSubview(viewable);
        currentView = Component(viewable).skin;
      }
    }
    else {
      currentView = IUIComponent(viewable);
      if (currentView.parent == null) {
        addSubview(viewable);
      }
    }

    currentView.visible = true;

    invalidateSize();
    invalidateDisplayList();
  }

  public function hide():void {
    currentView.visible = false;
    currentView = null;
  }

  override protected function measure():void {
    measuredMinWidth = currentView.minWidth;
    measuredMinHeight = currentView.minHeight;
    measuredWidth = currentView.getExplicitOrMeasuredWidth();
    measuredHeight = currentView.getExplicitOrMeasuredHeight();
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    currentView.setActualSize(w, h);
  }

  public function childCanSkipMeasurement(element:ILayoutElement):Boolean {
    return (!isNaN(explicitWidth) || !isNaN(percentWidth)) && (!isNaN(explicitHeight) || !isNaN(percentHeight));
  }
}
}