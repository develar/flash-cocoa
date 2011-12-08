package cocoa.plaf.basic {
import cocoa.Insets;
import cocoa.SegmentedControl;
import cocoa.View;
import cocoa.plaf.Placement;
import cocoa.plaf.TabViewSkin;

[Abstract]
public class AbstractTabViewSkin extends ContentViewableSkin implements TabViewSkin {
  protected var tabBar:SegmentedControl;
  protected var contentView:View;

  protected var tabBarPlacement:int;

  public function get contentInsets():Insets {
    throw new Error("abstract");
  }

  override public function getMinimumWidth(hHint:int = -1):int {
    return contentView == null ? 0 : contentView.getMinimumWidth(hHint) + contentInsets.width;
  }

  override public function getMinimumHeight(wHint:int = -1):int {
    return contentView == null ? 0 : contentView.getMinimumHeight(wHint) + contentInsets.height;
  }

  override public function getPreferredWidth(hHint:int = -1):int {
    return contentView == null ? 0 : contentView.getPreferredWidth(hHint) + contentInsets.width;
  }

  override public function getPreferredHeight(wHint:int = -1):int {
    return contentView == null ? 0 : contentView.getPreferredHeight(wHint) + contentInsets.height;
  }

  override public function getMaximumWidth(hHint:int = -1):int {
    return contentView == null ? 32767 : contentView.getMaximumWidth(hHint) + contentInsets.width;
  }

  override public function getMaximumHeight(wHint:int = -1):int {
    return contentView == null ? 32767 : contentView.getMaximumHeight(wHint) + contentInsets.height;
  }

  override protected function doInit():void {
    super.doInit();

    if (tabBar == null) {
      tabBar = new SegmentedControl();
      const tabBarLafKey:String = hostComponent.lafKey + ".tabBar";
      tabBar.lafKey = tabBarLafKey;

      tabBarPlacement = superview.laf.getInt(tabBarLafKey + ".placement");
      tabBar.addToSuperview(this);
      hostComponent.uiPartAdded("segmentedControl", tabBar);
    }
  }

  public function show(view:View):void {
    hide();

    contentView = view;
    contentView.addToSuperview(this);
    invalidate(false); // doesn't change superview size
  }
  
  public function hide():void {
    if (contentView != null) {
      contentView.removeFromSuperview();
      contentView = null;
    }
  }

  override protected function subviewsValidate():void {
    if (tabBar != null) {
      tabBar.validate();
    }
    if (contentView != null) {
      contentView.validate();
    }
  }

  override protected function draw(w:int, h:int):void {
    if (contentView != null) {
      contentView.setBounds(contentInsets.left, contentInsets.top, w - contentInsets.width, h - contentInsets.height);
      contentView.validate();
    }

    const tabBarPreferredHeight:int = tabBar.getPreferredHeight();
    if (tabBarPlacement == Placement.PAGE_START_LINE_CENTER) {
      const tabBarPreferredWidth:int = tabBar.getPreferredWidth();
      tabBar.setBounds(Math.round((w - tabBarPreferredWidth) / 2), 0, tabBarPreferredWidth, tabBarPreferredHeight);
    }
    else {
      tabBar.setBounds(0, 0, w, tabBarPreferredHeight);
    }
    tabBar.validate();
  }
}
}