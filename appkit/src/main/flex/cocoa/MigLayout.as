package cocoa {
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.IEventDispatcher;

import net.miginfocom.layout.AbstractMigLayout;
import net.miginfocom.layout.ComponentWrapper;
import net.miginfocom.layout.Grid;
import net.miginfocom.layout.LayoutUtil;
import net.miginfocom.layout.PlatformDefaults;

public class MigLayout extends AbstractMigLayout {
  private var lastHash:int = -1;
  private var lastInvalidW:int;
  private var lastInvalidH:int;

  public function MigLayout(layoutConstraints:String = null, colConstraints:String = null, rowConstraints:String = null) {
    super(layoutConstraints, colConstraints, rowConstraints);
  }

  public function preferredLayoutWidth(container:Container, sizeType:int):Number {
    if ((flags & INVALID) != 0) {
      checkCache(container);
    }

    return LayoutUtil.getSizeSafe(grid != null ? grid.width : null, sizeType);
  }

  public function preferredLayoutHeight(container:Container, sizeType:int):Number {
    if ((flags & INVALID) != 0) {
      checkCache(container);
    }

    return LayoutUtil.getSizeSafe(grid != null ? grid.width : null, sizeType);
  }

  public function layoutContainer(container:Container):void {
    checkCache(container);

    const w:int = container.getPreferredWidth(-1);
    const h:int = container.getPreferredHeight(-1);
    if (grid.layout(0, 0, w, h, lc.alignX, lc.alignY, _debug, true)) {
      grid = null;
      checkCache(container);
      grid.layout(0, 0, w, h, lc.alignX, lc.alignY, _debug, false);
    }
  }

  /** Check if something has changed and if so recreate it to the cached objects.
   * @param container The container that is the target for this layout manager.
   */
  private function checkCache(container:Container):void {
    if ((flags & INVALID) != 0) {
      grid = null;
    }

    // Check if the grid is valid
    var mc:int = PlatformDefaults.modCount;
    if (lastModCount != mc) {
      grid = null;
      lastModCount = mc;
    }

    var hash:int = 0;
    for each (var componentWrapper:ComponentWrapper in container.components) {
      hash ^= componentWrapper.layoutHashCode;
      hash += 285134905;
    }

    if (hash != lastHash) {
      grid = null;
      lastHash = hash;
    }

    if (lastInvalidW != container.actualWidth || lastInvalidH != container.actualHeight) {
      if (grid != null) {
        grid.invalidateContainerSize();
      }

      lastInvalidW = container.actualWidth;
      lastInvalidH = container.actualHeight;
    }

    if (grid == null) {
      grid = new Grid(container, lc, rowSpecs, colSpecs, null);
    }

    flags &= ~INVALID;
  }

  //private function calculateSize(container:FlashContainerWrapper, sizeType:int) {
  //  checkCache(container);
  //  var w:Number = LayoutUtil.getSizeSafe(grid != null ? grid.width : null, sizeType);
  //  var h:Number = LayoutUtil.getSizeSafe(grid != null ? grid.height : null, sizeType);
  //  return new Dimension(w, h);
  //}

  public function invalidateSubview(invalidateContainer:Boolean, dispatcher:DisplayObject):void {

  }

  private function enterFrameHandler(event:Event):void {
    IEventDispatcher(event.currentTarget).removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
    if ((flags & SOME_SUBVIEW_INVALID) == 0) {
      checkCache();
    }

    if (controls.length > 0) {
      var oldControls:Vector.<View> = controls;
      controls = new Vector.<View>();
      for each (var control:View in oldControls) {
        control.validate();
      }
    }
  }
}
}