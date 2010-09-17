package cocoa.plaf.aqua {
import cocoa.ClassFactory;
import cocoa.FrameInsets;
import cocoa.SingletonClassFactory;
import cocoa.border.LinearGradientBorder;
import cocoa.plaf.LookAndFeelUtil;
import cocoa.plaf.TextFormatID;
import cocoa.plaf.basic.AbstractLookAndFeel;
import cocoa.plaf.basic.BoxSkin;
import cocoa.plaf.basic.ColorPickerMenuController;
import cocoa.plaf.basic.IconButtonSkin;
import cocoa.plaf.basic.ListViewSkin;
import cocoa.plaf.basic.MenuSkin;
import cocoa.plaf.basic.SegmentedControlController;
import cocoa.plaf.basic.SeparatorSkin;
import cocoa.plaf.basic.SliderNumericStepperSkin;
import cocoa.plaf.basic.scrollbar.HScrollBarSkin;
import cocoa.plaf.basic.scrollbar.VScrollBarSkin;
import cocoa.text.TextLayoutFormatImpl;

import flash.display.BlendMode;

import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.formats.LineBreak;

public class AquaLookAndFeel extends AbstractLookAndFeel {
  [Embed(source="/borders", mimeType="application/octet-stream")]
  private static var assetsDataClass:Class;

  public function AquaLookAndFeel() {
    initialize();
  }

  protected function initialize():void {
    LookAndFeelUtil.initAssets(data, assetsDataClass);
    assetsDataClass = null;

    data[TextFormatID.SYSTEM] = AquaFonts.SYSTEM_FONT;
    data[TextFormatID.SYSTEM_HIGHLIGHTED] = AquaFonts.SYSTEM_FONT_HIGHLIGHTED;

    data[TextFormatID.SMALL_SYSTEM] = AquaFonts.SMALL_SYSTEM_FONT;
    data[TextFormatID.SMALL_SYSTEM_EMPHASIZED] = AquaFonts.SMALL_EMPHASIZED_SYSTEM_FONT;
    data[TextFormatID.SMALL_SYSTEM_HIGHLIGHTED] = AquaFonts.SMALL_SYSTEM_FONT_HIGHLIGHTED;

    data[TextFormatID.VIEW] = AquaFonts.VIEW_FONT;
    data[TextFormatID.VIEW_HIGHLIGHTED] = AquaFonts.VIEW_FONT_HIGHLIGHTED;

    data[TextFormatID.MENU] = AquaFonts.SYSTEM_FONT;
    data[TextFormatID.MENU_HIGHLIGHTED] = AquaFonts.SYSTEM_FONT_HIGHLIGHTED;

    data["SelectionFormat"] = new SelectionFormat(0xb5d5fd, 1.0, BlendMode.NORMAL, 0x000000, 1, BlendMode.INVERT);

    data["Box"] = BoxSkin;

    data["Toolbar"] = ToolbarSkin;
    data["Toolbar.b"] = new LinearGradientBorder([0xd0d0d0, 0xa7a7a7], new FrameInsets(0, -17));

    data["Dialog"] = WindowSkin;
    data["HUDWindow"] = HUDWindowSkin;

    data["SourceListView"] = SourceListViewSkin;
    data["ListView"] = ListViewSkin;
    data["SwatchGrid.b"] = data["ListView.b"] = new ListViewBorder();

    data["TabView"] = TabViewSkin;
    data["TabView.borderless"] = BorderlessTabViewSkin;
    data["TabView.segmentedControlController"] = new SingletonClassFactory(SegmentedControlController);

    data["PushButton"] = PushButtonSkin;

    data["IconButton"] = IconButtonSkin;

    data["PopUpButton"] = PushButtonSkin;
    data["PopUpButton.menuController"] = new SingletonClassFactory(PopUpMenuController);

    data["ColorPicker"] = PushButtonSkin;
    data["ColorPicker.b"] = data["PopUpButton.b"];
    data["ColorPicker.menuController"] = new SingletonClassFactory(ColorPickerMenuController);

    data["Menu"] = MenuSkin;
    data["Menu.itemRenderer"] = new ClassFactory(MenuItemRenderer);

    data["MenuItem.b"] = new MenuItemBorder(data["MenuItem.b.highlighted"]);
    data["MenuItem.separatorBorder"] = new SeparatorMenuItemBorder();

    data["SliderNumericStepper"] = SliderNumericStepperSkin;

    data["ScrollBar.h"] = HScrollBarSkin;
    data["ScrollBar.v"] = VScrollBarSkin;

//    data["ScrollBar.h"] = MiniScrollBarSkin;
//    data["ScrollBar.v"] = MiniScrollBarSkin;
//    data["ScrollBar.thumb"] = borders[BorderPosition.scrollbar + 10];

    data["VSeparator"] = SeparatorSkin;
    data["HSeparator"] = SeparatorSkin;

    data["NumericStepper"] = NumericStepperSkin;
    data["CheckBox"] = CheckBoxSkin;
    data["CheckBox.b"] = data["PushButton.b"];
    data["HSlider"] = HSliderSkin;

    data["TextInput"] = TextInputSkin;
    data["TextInput.SystemTextFormat"] = createDefaultTextFormat();

    data["TextArea"] = TextAreaSkin;
    data["TextArea.b"] = data["TextInput.b"];
    data["TextArea.SystemTextFormat"] = createDefaultTextFormat();
    TextLayoutFormatImpl(data["TextArea.SystemTextFormat"]).$lineBreak = LineBreak.TO_FIT;

    data["NumericStepper.TextInput"] = TextInputSkin;

    data["HSeparator.b"] = new SeparatorBorder();

    data["Tree.defaults"] = {paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, indentation: 16, useRollOver: false};
  }

  private var windowFrameLookAndFeel:WindowFrameLookAndFeel;

  public function createWindowFrameLookAndFeel():WindowFrameLookAndFeel {
    if (windowFrameLookAndFeel == null) {
      windowFrameLookAndFeel = new WindowFrameLookAndFeel(this);
    }
    return windowFrameLookAndFeel;
  }

  private var hudLookAndFeel:HUDLookAndFeel;

  public function createHUDLookAndFeel():HUDLookAndFeel {
    if (hudLookAndFeel == null) {
      hudLookAndFeel = new HUDLookAndFeel(this);
    }
    return hudLookAndFeel;
  }

  private function createDefaultTextFormat():TextLayoutFormatImpl {
    var textInputTextFormat:TextLayoutFormatImpl = new TextLayoutFormatImpl(AquaFonts.SYSTEM_FONT);
    textInputTextFormat.$paddingTop = 2;
    textInputTextFormat.$lineBreak = LineBreak.EXPLICIT;
    return textInputTextFormat;
  }
}
}

import cocoa.plaf.LookAndFeelUtil;
import cocoa.plaf.TextFormatID;
import cocoa.plaf.aqua.AquaLookAndFeel;
import cocoa.plaf.aqua.HUDPushButtonSkin;
import cocoa.plaf.aqua.HUDTextInputBorder;
import cocoa.plaf.aqua.MenuItemBorder;
import cocoa.plaf.aqua.NumericStepperTextInputBorder;
import cocoa.plaf.aqua.SeparatorBorder;
import cocoa.plaf.aqua.TextInputSkin;
import cocoa.plaf.basic.AbstractLookAndFeel;
import cocoa.text.TextFormat;
import cocoa.text.TextLayoutFormatImpl;

import flash.display.BlendMode;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.FontWeight;

import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.formats.LineBreak;
import flashx.textLayout.formats.TextAlign;

final class WindowFrameLookAndFeel extends AbstractLookAndFeel {
  [Embed(source="/frameAssets", mimeType="application/octet-stream")]
  private static var assetsDataClass:Class;

  public function WindowFrameLookAndFeel(parent:AquaLookAndFeel) {
    initialize();
    this.parent = parent;
  }

  private function initialize():void {
    LookAndFeelUtil.initAssets(data, assetsDataClass);
    assetsDataClass = null;
  }
}

final class HUDLookAndFeel extends AbstractLookAndFeel {
  [Embed(source="../../../../../../target/assets", mimeType="application/octet-stream")]
  private static var assetsDataClass:Class;

  public function HUDLookAndFeel(parent:AquaLookAndFeel) {
    this.parent = parent;
    initialize();
  }

  private function initialize():void {
    data[TextFormatID.SYSTEM] = AquaFonts.SYSTEM_FONT_HUD;
    data[TextFormatID.SYSTEM_HIGHLIGHTED] = AquaFonts.SYSTEM_FONT_HUD_HIGHLIGHTED;
    data[TextFormatID.VIEW] = AquaFonts.VIEW_FONT_HUD;

    data[TextFormatID.MENU] = AquaFonts.SMALL_SYSTEM_FONT;
    data[TextFormatID.MENU_HIGHLIGHTED] = AquaFonts.SMALL_SYSTEM_FONT_HIGHLIGHTED;

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

    var numericStepperTextFormat:TextLayoutFormatImpl = createDefaultTextFormat();
    numericStepperTextFormat.$textAlign = TextAlign.END;
    data["NumericStepper.TextInput.SystemTextFormat"] = numericStepperTextFormat;

    data["TitleBar.PushButton"] = _parent.getClass("PushButton");
  }

  private function createDefaultTextFormat():TextLayoutFormatImpl {
    var textInputTextFormat:TextLayoutFormatImpl = new TextLayoutFormatImpl(AquaFonts.SYSTEM_FONT_HUD);
    textInputTextFormat.$paddingTop = 2;
    textInputTextFormat.$lineBreak = LineBreak.EXPLICIT;
    return textInputTextFormat;
  }
}

/**
 * http://developer.apple.com/mac/library/documentation/userexperience/conceptual/applehiguidelines/XHIGText/XHIGText.html
 */
final class AquaFonts {
  private static const FONT_DESCRIPTION:FontDescription = new FontDescription("Lucida Grande, Segoe UI, Sans");
  private static const FONT_BOLD_DESCRIPTION:FontDescription = new FontDescription("Lucida Grande, Segoe UI, Sans", FontWeight.BOLD);

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