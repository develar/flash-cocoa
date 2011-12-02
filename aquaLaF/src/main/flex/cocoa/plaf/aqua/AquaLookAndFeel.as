package cocoa.plaf.aqua {
import cocoa.ClassFactory;
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.SingletonClassFactory;
import cocoa.border.LinearGradientBorder;
import cocoa.layout.ListLayoutFactory;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelUtil;
import cocoa.plaf.Placement;
import cocoa.plaf.RendererManagerFactory;
import cocoa.plaf.TextFormatId;
import cocoa.plaf.basic.AbstractLookAndFeel;
import cocoa.plaf.basic.BasicTableViewSkin;
import cocoa.plaf.basic.BoxSkin;
import cocoa.plaf.basic.CollectionViewSkin;
import cocoa.plaf.basic.ColorPickerMenuController;
import cocoa.plaf.basic.IconButtonSkin;
import cocoa.plaf.basic.MenuSkin;
import cocoa.plaf.basic.SegmentedControlInteractor;
import cocoa.plaf.basic.SeparatorSkin;
import cocoa.plaf.basic.SidebarSkin;
import cocoa.plaf.basic.SliderNumericStepperSkin;
import cocoa.plaf.basic.scrollbar.HScrollBarSkin;
import cocoa.plaf.basic.scrollbar.VScrollBarSkin;
import cocoa.text.SimpleTextLayoutFormat;

import flash.display.BlendMode;
import flash.geom.Point;
import flash.text.engine.FontDescription;

import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.formats.LineBreak;

public class AquaLookAndFeel extends AbstractLookAndFeel {
  [Embed(source="/borders", mimeType="application/octet-stream")]
  private static var assetsDataClass:Class;

  private var windowFrameLookAndFeel:WindowFrameLookAndFeel;
  private var windowFrameSmalLookAndFeel:WindowFrameSmallLookAndFeel;
  private var panelLookAndFeel:PanelLookAndFeel;

  public function AquaLookAndFeel() {
    initialize();
  }
  
  protected static function get fontDescription():FontDescription {
    return AquaFonts.FONT_DESCRIPTION;
  }
  
  protected static function get fontBoldDescription():FontDescription {
    return AquaFonts.FONT_BOLD_DESCRIPTION;
  }

  protected function initialize():void {
    LookAndFeelUtil.initAssets(data, assetsDataClass);
    assetsDataClass = null;

    data[TextFormatId.SYSTEM] = AquaFonts.SYSTEM_FONT;
    data[TextFormatId.SYSTEM_HIGHLIGHTED] = AquaFonts.SYSTEM_FONT_HIGHLIGHTED;

    data[TextFormatId.SMALL_SYSTEM] = AquaFonts.SMALL_SYSTEM_FONT;
    data[TextFormatId.SMALL_SYSTEM_EMPHASIZED] = AquaFonts.SMALL_EMPHASIZED_SYSTEM_FONT;
    data[TextFormatId.SMALL_SYSTEM_HIGHLIGHTED] = AquaFonts.SMALL_SYSTEM_FONT_HIGHLIGHTED;

    data[TextFormatId.VIEW] = AquaFonts.VIEW_FONT;
    data[TextFormatId.VIEW_HIGHLIGHTED] = AquaFonts.VIEW_FONT_HIGHLIGHTED;

    data[TextFormatId.MENU] = AquaFonts.SYSTEM_FONT;
    data[TextFormatId.MENU_HIGHLIGHTED] = AquaFonts.SYSTEM_FONT_HIGHLIGHTED;

    data["SelectionFormat"] = new SelectionFormat(0xb5d5fd, 1.0, BlendMode.NORMAL, 0x000000, 1, BlendMode.INVERT);

    data["Box"] = BoxSkin;

    data["CollectionView"] = data["small.CollectionView"] = CollectionViewSkin;
    
    data["TableView"] = data["small.TableView"] = BasicTableViewSkin;
    data["TableView.rowHeight"] = 17;
    data["small.TableView.rowHeight"] = 14;
    data["TableView.intercellSpacing"] = data["small.TableView.intercellSpacing"] = new Point(3, 2); // height (y) must be even
    data["TableView.bg"] = data["small.TableView.bg"] = new <uint>[0xffffff, 0xedf3fe];

    data["Toolbar"] = ToolbarSkin;
    data["Toolbar.b"] = LinearGradientBorder.createV([0xd0d0d0, 0xa7a7a7], NaN, null, new FrameInsets(0, -17));

    data["Dialog"] = WindowSkin;
    data["HUDWindow"] = HUDWindowSkin;

    data["SwatchGrid.b"] = data["ListView.b"] = data["TextArea.b"] = data["TableView.b"] = data["small.TableView.b"] = new BezelBorder();

    data["SegmentedControl.rendererManager"] = data["TabView.tabBar.rendererManager"] = new RendererManagerFactory(SegmentRendererManager, this, "SegmentItem");

    data["TabView"] = TabViewSkin;
    data["TabView.borderless"] = BorderlessTabViewSkin;
    data["Sidebar.tabBar.interactor"] = data["SegmentedControl.interactor"] = data["TabView.tabBar.interactor"] = data["SegmentedControl.segmentedControlController"] = new SingletonClassFactory(SegmentedControlInteractor);
    data["TabView.tabBar.layout"] = data["SegmentedControl.layout"] = new ListLayoutFactory(20, 1);
    data["TabView.tabBar.placement"] = Placement.PAGE_START_LINE_CENTER;

    data["Sidebar"] = SidebarSkin;
    data["Sidebar.tabBar.layout"] = new ListLayoutFactory(20, 6, false);

    data["PushButton"] = PushButtonSkin;
    data["IconButton"] = IconButtonSkin;

    data["PopUpButton"] = PushButtonSkin;
    data["PopUpButton.menuController"] = new SingletonClassFactory(PopUpMenuInteractor);

    data["ColorPicker"] = PushButtonSkin;
    data["ColorPicker.b"] = data["PopUpButton.b"];

    data["ColorPicker.menuController"] = new SingletonClassFactory(ColorPickerMenuController);

    data["Menu"] = MenuSkin;
    data["Menu.iR"] = new ClassFactory(MenuItemRenderer);

    data["MenuItem.b"] = new MenuItemBorder(data["MenuItem.b.highlighted"]);
    data["MenuItem.separatorBorder"] = new SeparatorMenuItemBorder();

    //data["SliderNumericStepper"] = SliderNumericStepperSkin;

    data["ScrollBar.h"] = HScrollBarSkin;
    data["ScrollBar.v"] = VScrollBarSkin;

    data["VSeparator"] = data["HSeparator"] = SeparatorSkin;

    data["NumericStepper"] = NumericStepperSkin;
    data["CheckBox"] = data["small.CheckBox"] = CheckBoxSkin;
    data["HSlider"] = HSliderSkin;

    data["TextInput"] = TextInputSkin;
    data["TextInput.SystemTextFormat"] = createDefaultTextFormat(false);

    data["small.TextInput"] = data["TextInput"];
    data["small.TextInput.b"] = data["TextInput.b"];
    data["small.TextInput.SystemTextFormat"] = createDefaultTextFormat(true);

    data["TextArea"] = TextAreaSkin;

    var textFormat:SimpleTextLayoutFormat = new SimpleTextLayoutFormat(AquaFonts.SYSTEM_FONT, new Insets(5, 2, 5));
    textFormat.$lineBreak = LineBreak.TO_FIT;
    data["TextArea.SystemTextFormat"] = textFormat;

    data["NumericStepper.TextInput"] = TextInputSkin;

    data["HSeparator.b"] = new SeparatorBorder();

    data["Tree.defaults"] = {paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, indentation: 16, useRollOver: false};
  }

  public function createWindowFrameLookAndFeel(small:Boolean = false):LookAndFeel {
    if (windowFrameLookAndFeel == null) {
      windowFrameLookAndFeel = new WindowFrameLookAndFeel(this, small);
    }

    if (small) {
      if (windowFrameSmalLookAndFeel == null) {
        windowFrameSmalLookAndFeel = new WindowFrameSmallLookAndFeel(windowFrameLookAndFeel);
      }
      return windowFrameSmalLookAndFeel;
    }

    return windowFrameLookAndFeel;
  }
  
  public function createPanelLookAndFeel():PanelLookAndFeel {
    if (panelLookAndFeel == null) {
      panelLookAndFeel = new PanelLookAndFeel(this);
    }
    return panelLookAndFeel;
  }

  private var hudLookAndFeel:HUDLookAndFeel;

  public function createHUDLookAndFeel():HUDLookAndFeel {
    if (hudLookAndFeel == null) {
      hudLookAndFeel = new HUDLookAndFeel(this);
    }
    return hudLookAndFeel;
  }

  private static function createDefaultTextFormat(small:Boolean):SimpleTextLayoutFormat {
    var textFormat:SimpleTextLayoutFormat = new SimpleTextLayoutFormat(small ? AquaFonts.SMALL_SYSTEM_FONT : AquaFonts.SYSTEM_FONT, new Insets(0, 2));
    textFormat.$lineBreak = LineBreak.EXPLICIT;
    return textFormat;
  }
}
}

import cocoa.Insets;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelUtil;
import cocoa.plaf.TextFormatId;
import cocoa.plaf.aqua.AquaLookAndFeel;
import cocoa.plaf.aqua.HUDPushButtonSkin;
import cocoa.plaf.aqua.HUDTextInputBorder;
import cocoa.plaf.aqua.MenuItemBorder;
import cocoa.plaf.aqua.NumericStepperTextInputBorder;
import cocoa.plaf.aqua.SeparatorBorder;
import cocoa.plaf.aqua.TextInputSkin;
import cocoa.plaf.basic.AbstractLookAndFeel;
import cocoa.text.SimpleTextLayoutFormat;
import cocoa.text.TextFormat;

import flash.display.BlendMode;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.FontWeight;

import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.formats.LineBreak;
import flashx.textLayout.formats.TextAlign;

final class PanelLookAndFeel extends AbstractLookAndFeel {
  public function PanelLookAndFeel(parent:AquaLookAndFeel) {
    this.parent = parent;
    data["small.TableView.b"] = null;
  }

  override public function get controlSize():String {
    return "small";
  }
}

final class WindowFrameLookAndFeel extends AbstractLookAndFeel {
  [Embed(source="/frameAssets", mimeType="application/octet-stream")]
  private static var assetsDataClass:Class;

  private var small:Boolean;

  public function WindowFrameLookAndFeel(parent:AquaLookAndFeel, small:Boolean) {
    this.small = small;
    initialize();
    this.parent = parent;
  }

  private function initialize():void {
    LookAndFeelUtil.initAssets(data, assetsDataClass);
    assetsDataClass = null;
  }

  override public function get controlSize():String {
    return small ? "small" : null;
  }
}

final class WindowFrameSmallLookAndFeel extends AbstractLookAndFeel {
  public function WindowFrameSmallLookAndFeel(parent:LookAndFeel) {
    this.parent = parent;
  }

  override public function get controlSize():String {
    return "small";
  }
}


final class HUDLookAndFeel extends AbstractLookAndFeel {
  [Embed(source="../../../../../../target/hudAssets", mimeType="application/octet-stream")]
  private static var assetsDataClass:Class;

  public function HUDLookAndFeel(parent:AquaLookAndFeel) {
    this.parent = parent;
    initialize();
  }

  private function initialize():void {
    data[TextFormatId.SYSTEM] = AquaFonts.SYSTEM_FONT_HUD;
    data[TextFormatId.SYSTEM_HIGHLIGHTED] = AquaFonts.SYSTEM_FONT_HUD_HIGHLIGHTED;
    data[TextFormatId.VIEW] = AquaFonts.VIEW_FONT_HUD;

    data[TextFormatId.MENU] = AquaFonts.SMALL_SYSTEM_FONT;
    data[TextFormatId.MENU_HIGHLIGHTED] = AquaFonts.SMALL_SYSTEM_FONT_HIGHLIGHTED;

    LookAndFeelUtil.initAssets(data, assetsDataClass);
    assetsDataClass = null;

    data["SelectionFormat"] = new SelectionFormat(0xb5b5b5, 1.0, BlendMode.NORMAL, 0x000000, 1, BlendMode.INVERT);

    data["TextInput.b"] = new HUDTextInputBorder();
    data["TextInput.SystemTextFormat"] = createDefaultTextFormat();

    data["HSeparator.b"] = new SeparatorBorder();

    data["PushButton"] = HUDPushButtonSkin;

    data["MenuItem.b"] = new MenuItemBorder(data["MenuItem.b.highlighted"]);

    data["NumericStepper.TextInput"] = TextInputSkin;
    data["NumericStepper.TextInput.b"] = new NumericStepperTextInputBorder();

    var numericStepperTextFormat:SimpleTextLayoutFormat = createDefaultTextFormat();
    numericStepperTextFormat.$textAlign = TextAlign.END;
    data["NumericStepper.TextInput.SystemTextFormat"] = numericStepperTextFormat;

    data["TitleBar.PushButton"] = _parent.getClass("PushButton");
  }

  private static function createDefaultTextFormat():SimpleTextLayoutFormat {
    var textInputTextFormat:SimpleTextLayoutFormat = new SimpleTextLayoutFormat(AquaFonts.SYSTEM_FONT_HUD, new Insets(0, 2));
    textInputTextFormat.$lineBreak = LineBreak.EXPLICIT;
    return textInputTextFormat;
  }
}

/**
 * http://developer.apple.com/mac/library/documentation/userexperience/conceptual/applehiguidelines/XHIGText/XHIGText.html
 */
final class AquaFonts {
  public static const FONT_DESCRIPTION:FontDescription = new FontDescription("Lucida Grande, Segoe UI, Sans");
  public static const FONT_BOLD_DESCRIPTION:FontDescription = new FontDescription("Lucida Grande, Segoe UI, Sans", FontWeight.BOLD);

  public static const SYSTEM_FONT:TextFormat = new TextFormat(new ElementFormat(FONT_DESCRIPTION, 13));
  public static const SYSTEM_FONT_HUD:TextFormat = new TextFormat(new ElementFormat(FONT_DESCRIPTION, 11, 0xffffff));
  public static const SYSTEM_FONT_HIGHLIGHTED:TextFormat = new TextFormat(new ElementFormat(FONT_DESCRIPTION, 13, 0xffffff));
  public static const SYSTEM_FONT_HUD_HIGHLIGHTED:TextFormat = new TextFormat(new ElementFormat(FONT_DESCRIPTION, 11, 0xffffff));

  public static const SMALL_SYSTEM_FONT:TextFormat = new TextFormat(new ElementFormat(FONT_DESCRIPTION, 11));
  public static const SMALL_SYSTEM_FONT_HIGHLIGHTED:TextFormat = new TextFormat(new ElementFormat(FONT_DESCRIPTION, 11, 0xffffff));
  public static const SMALL_EMPHASIZED_SYSTEM_FONT:TextFormat = new TextFormat(new ElementFormat(FONT_BOLD_DESCRIPTION, 11));

  public static const VIEW_FONT:TextFormat = new TextFormat(new ElementFormat(FONT_DESCRIPTION, 12));
  public static const VIEW_FONT_HUD:TextFormat = SYSTEM_FONT_HUD;
  public static const VIEW_FONT_HIGHLIGHTED:TextFormat = new TextFormat(new ElementFormat(FONT_DESCRIPTION, 12, 0xffffff));
}