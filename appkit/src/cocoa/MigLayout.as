package cocoa {
import flash.events.Event;

import net.miginfocom.layout.AbstractMigLayout;
import net.miginfocom.layout.CC;
import net.miginfocom.layout.Grid;
import net.miginfocom.layout.LayoutUtil;
import net.miginfocom.layout.PlatformDefaults;

public class MigLayout extends AbstractMigLayout {
  private static const VALIDATE_LISTENERS_ATTACHED:uint = 1 << 1;
  private static const SOME_SUBVIEW_SIZE_INVALID:uint = 1 << 2;
  private static const CONTAINER_SIZE_INVALID:uint = 1 << 3;

  public function MigLayout(layoutConstraints:String = null, colConstraints:String = null, rowConstraints:String = null) {
    super(layoutConstraints, colConstraints, rowConstraints);
  }
  
  private var _container:Container;
  public function set container(value:Container):void {
    if (_container != value) {
      _container = value;
      flags |= INVALID;
    }
  }

  public function validate():void {
    if ((flags & VALIDATE_LISTENERS_ATTACHED) != 0) {
      flags &= ~VALIDATE_LISTENERS_ATTACHED;
      _container.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
    }

    if (checkCache()) {
      var insets:Insets = _container.insets;
      const w:int = _container.actualWidth - insets.width;
      const h:int = _container.actualHeight - insets.height;
      if (grid.layout(insets.left, insets.top, w, h, lc != null && lc.debugMillis > 0, true)) {
        grid = new Grid(_container, lc, rowSpecs, colSpecs, null);
        grid.layout(insets.left, insets.top, w, h, lc != null && lc.debugMillis > 0, false);
      }
    }

    for each (var view:View in _container.components) {
      var cc:CC = view.constraints;
      if (cc == null || !cc.external) {
        view.validate();
      }
    }
  }

  public function preferredLayoutWidth(sizeType:int):Number {
    checkCache();

    return LayoutUtil.getSizeSafe(grid != null ? grid.width : null, sizeType) + _container.insets.width;
  }

  public function preferredLayoutHeight(sizeType:int):Number {
    checkCache();

    return LayoutUtil.getSizeSafe(grid != null ? grid.height : null, sizeType) + _container.insets.height;
  }

  /** Check if something has changed and if so recreate it to the cached objects.
   */
  private function checkCache():Boolean {
    var layoutInvalid:Boolean;
    if ((flags & INVALID) != 0) {
      grid = null;
    }
    else if ((flags & SOME_SUBVIEW_SIZE_INVALID) == 0 && (flags & CONTAINER_SIZE_INVALID) == 0) {
      return false;
    }

    // Check if the grid is valid
    var mc:int = PlatformDefaults.modCount;
    if (lastModCount != mc) {
      grid = null;
      lastModCount = mc;
    }

    for each (var componentWrapper:View in _container.components) {
      if ((componentWrapper.layoutHashCode & LayoutState.SIZE_INVALID) != 0) {
        grid = null;
        break;
      }
    }

    if (grid == null) {
      layoutInvalid = true;
      grid = new Grid(_container, lc, rowSpecs, colSpecs);
    }
    else {
      layoutInvalid = (flags & CONTAINER_SIZE_INVALID) != 0;
    }

    flags &= ~INVALID;
    flags &= ~SOME_SUBVIEW_SIZE_INVALID;
    flags &= ~CONTAINER_SIZE_INVALID;
    return layoutInvalid;
  }

  //private function calculateSize(container:FlashContainerWrapper, sizeType:int) {
  //  checkCache(container);
  //  var w:Number = LayoutUtil.getSizeSafe(grid != null ? grid.width : null, sizeType);
  //  var h:Number = LayoutUtil.getSizeSafe(grid != null ? grid.height : null, sizeType);
  //  return new Dimension(w, h);
  //}

  public function invalidateContainerSize():void {
    if (grid != null) {
      grid.invalidateContainerSize();
      flags |= CONTAINER_SIZE_INVALID;
    }
  }

  public function invalidateSubview(invalidateContainer:Boolean):void {
    if (invalidateContainer && (flags & SOME_SUBVIEW_SIZE_INVALID) == 0) {
      flags |= SOME_SUBVIEW_SIZE_INVALID;
    }

    if ((flags & VALIDATE_LISTENERS_ATTACHED) == 0) {
      flags |= VALIDATE_LISTENERS_ATTACHED;
      _container.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
    }
  }

  private function enterFrameHandler(event:Event):void {
    validate();
  }
}
}