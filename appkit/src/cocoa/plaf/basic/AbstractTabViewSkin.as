package cocoa.plaf.basic {
import cocoa.Insets;
import cocoa.SegmentedControl;
import cocoa.Toolbar;
import cocoa.View;
import cocoa.plaf.Placement;
import cocoa.plaf.TabViewSkin;
import cocoa.tabView.TabView;

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
    var pw:int = contentInsets.height;
    if (contentView != null) {
      pw = contentView.getPreferredHeight(wHint);
    }
    var toolbar:Toolbar = TabView(component).toolbar;
    if (toolbar != null) {
      pw += toolbar.getPreferredHeight(wHint);
    }
    return pw;
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
      const tabBarLafKey:String = component.lafKey + ".tabBar";
      tabBar.lafKey = tabBarLafKey;

      tabBarPlacement = laf.getInt(tabBarLafKey + ".placement");
      tabBar.addToSuperview(this, laf, this);
      component.uiPartAdded("segmentedControl", tabBar);
    }

    var toolbar:Toolbar = TabView(component).toolbar;
    if (toolbar != null) {
      toolbar.addToSuperview(this, laf, this);
    }
  }

  public function show(view:View):void {
    hide();

    contentView = view;
    contentView.addToSuperview(this, laf, this);
    invalidate(true);
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
    const tabBarPreferredHeight:int = tabBar.getPreferredHeight();
    if (tabBarPlacement == Placement.PAGE_START_LINE_CENTER) {
      const tabBarPreferredWidth:int = tabBar.getPreferredWidth();
      tabBar.setBounds(Math.round((w - tabBarPreferredWidth) / 2), 0, tabBarPreferredWidth, tabBarPreferredHeight);
    }
    else {
      tabBar.setSize(w, tabBarPreferredHeight);
    }
    tabBar.validate();

    var toolbar:Toolbar = TabView(component).toolbar;
    var toolbarHeight:int = 0;
    if (toolbar != null) {
      toolbarHeight = toolbar.getPreferredHeight();
      toolbar.setBounds(contentInsets.left, contentInsets.top, w - contentInsets.width, toolbarHeight);
      toolbar.validate();
    }

    if (contentView != null) {
      contentView.setBounds(contentInsets.left, contentInsets.top + toolbarHeight, w - contentInsets.width, h - contentInsets.height - toolbarHeight);
      contentView.validate();
    }
  }

  public function toolbarChanged(oldToolbar:Toolbar, newToolbar:Toolbar):void {
    if (oldToolbar != null) {
      oldToolbar.removeFromSuperview();
    }
    if (newToolbar != null) {
      newToolbar.addToSuperview(this, laf, this);
    }

    invalidate(true);
  }
}
}