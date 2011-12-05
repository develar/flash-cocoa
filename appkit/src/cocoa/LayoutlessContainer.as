package cocoa {
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.LookAndFeelUtil;

import flash.display.DisplayObject;

import mx.core.ILayoutElement;

import org.flyti.plexus.Injectable;
import org.flyti.plexus.events.InjectorEvent;

import spark.components.supportClasses.GroupBase;
import spark.components.supportClasses.SkinnableComponent;

public class LayoutlessContainer extends AbstractView implements ViewContainer, LookAndFeelProvider {
  private var _laf:LookAndFeel;
  public function get laf():LookAndFeel {
    return _laf;
  }

  public function set laf(value:LookAndFeel):void {
    _laf = value;
  }

  override protected function createChildren():void {
    if (_laf == null) {
      _laf = LookAndFeelUtil.find(parent);
    }
  }

  public function addSubview(viewable:View, index:int = -1):void {
    if (viewable is Component) {
      var component:Component = Component(viewable);
      addChildAt(DisplayObject(component.skin == null ? component.createView(laf) : component.skin), index == -1 ? numChildren : index);
    }
    else {
      if (viewable is Injectable || viewable is SkinnableComponent || (viewable is GroupBase && GroupBase(viewable).id != null)) {
        dispatchEvent(new InjectorEvent(viewable));
      }

      addChildAt(DisplayObject(viewable), index == -1 ? numChildren : index);
    }
  }

  public function removeSubview(view:View):void {
    removeChild(DisplayObject(view is Component ? Component(view).skin : view));
  }

  public function getSubviewIndex(view:View):int {
    return getChildIndex(DisplayObject(view is Component ? Component(view).skin : view));
  }

  public function getSubviewAt(index:int):View {
    return View(getChildAt(index));
  }

  public function get numSubviews():int {
    return numChildren;
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    var n:int = numChildren;
    while (n-- > 0) {
      ILayoutElement(getChildAt(n)).setLayoutBoundsSize(w, h);
    }
  }
}
}