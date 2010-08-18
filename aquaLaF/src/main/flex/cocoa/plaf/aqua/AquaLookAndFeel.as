package cocoa.plaf.aqua {
import cocoa.Border;
import cocoa.FrameInsets;
import cocoa.Icon;
import cocoa.SingletonClassFactory;
import cocoa.border.AbstractBitmapBorder;
import cocoa.border.LinearGradientBorder;
import cocoa.border.OneBitmapBorder;
import cocoa.border.Scale1BitmapBorder;
import cocoa.border.Scale3EdgeHBitmapBorder;
import cocoa.border.Scale3HBitmapBorder;
import cocoa.border.Scale3VBitmapBorder;
import cocoa.border.Scale9BitmapBorder;
import cocoa.plaf.TextFormatID;
import cocoa.plaf.basic.AbstractLookAndFeel;
import cocoa.plaf.basic.BitmapIcon;
import cocoa.plaf.basic.BoxSkin;
import cocoa.plaf.basic.ColorPickerMenuController;
import cocoa.plaf.basic.IconButtonSkin;
import cocoa.plaf.basic.ListViewSkin;
import cocoa.plaf.basic.MenuSkin;
import cocoa.plaf.basic.SegmentedControlController;
import cocoa.plaf.basic.SeparatorSkin;
import cocoa.plaf.basic.SliderNumericStepperSkin;
import cocoa.text.TextLayoutFormatImpl;

import flash.display.BlendMode;
import flash.utils.ByteArray;

import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.formats.LineBreak;

import mx.core.ClassFactory;

public class AquaLookAndFeel extends AbstractLookAndFeel {
  [Embed(source="/borders", mimeType="application/octet-stream")]
  //	[Embed(source="/Users/develar/workspace/XpressPages/client/editor/skins/xpBlue/target/editorSkins/assets", mimeType="application/octet-stream")]
  private static var assetsDataClass:Class;

  private static var borders:Vector.<Border>;
  private static var icons:Vector.<Icon>;

  public function AquaLookAndFeel() {
    initialize();
  }

  protected function initialize():void {
    initAssets();

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

    data["ImageView.border"] = borders[BorderPosition.imageView];

    data["Box"] = BoxSkin;

    data["Toolbar"] = ToolbarSkin;
    data["Toolbar.border"] = new LinearGradientBorder([0xd0d0d0, 0xa7a7a7], new FrameInsets(0, -17));

    data["Dialog"] = WindowSkin;
    data["HUDWindow"] = HUDWindowSkin;
    data["Window.border"] = borders[BorderPosition.window];
    data["Window.border.toolbar"] = borders[BorderPosition.windowWithToolbar];
    data["Window.bottomBar.application"] = borders[BorderPosition.windowApplicationBottomBar];
    data["Window.bottomBar.chooseDialog"] = borders[BorderPosition.windowChooseDialogBottomBar];

    data["SourceListView"] = SourceListViewSkin;
    data["ListView"] = ListViewSkin;
    data["SwatchGrid.border"] = data["ListView.border"] = new ListViewBorder();

    data["TabView"] = TabViewSkin;
    data["TabView.borderless"] = BorderlessTabViewSkin;
    data["TabView.segmentedControlController"] = new SingletonClassFactory(SegmentedControlController);

    data["PushButton"] = PushButtonSkin;
    data["PushButton.border"] = borders[BorderPosition.pushButtonRounded];

    data["IconButton"] = IconButtonSkin;

    data["PopUpButton"] = PushButtonSkin;
    data["PopUpButton.border"] = borders[BorderPosition.popUpButtonTexturedRounded];
    data["PopUpButton.menuController"] = new SingletonClassFactory(PopUpMenuController);

    data["ColorPicker"] = PushButtonSkin;
    data["ColorPicker.border"] = borders[BorderPosition.popUpButtonTexturedRounded];
    data["ColorPicker.menuController"] = new SingletonClassFactory(ColorPickerMenuController);

    data["Menu"] = MenuSkin;
    data["Menu.border"] = borders[BorderPosition.menu];
    data["Menu.itemRenderer"] = new ClassFactory(MenuItemRenderer);

    data["MenuItem.onStateIcon"] = icons[0];
    data["MenuItem.onStateIcon.highlighted"] = icons[1];

    data["MenuItem.border"] = new MenuItemBorder(borders[BorderPosition.menuItem]);
    data["MenuItem.border.highlighted"] = borders[BorderPosition.menuItem];
    data["MenuItem.separatorBorder"] = new SeparatorMenuItemBorder();

    data["SliderNumericStepper"] = SliderNumericStepperSkin;

    data["SegmentItem.border"] = borders[BorderPosition.segmentItem];
    Scale1BitmapBorder(borders[BorderPosition.segmentItem]).frameInsets = new FrameInsets(0, 0, 0, -3);

    data["Scrollbar.track.v"] = borders[BorderPosition.scrollbar];
    data["Scrollbar.track.h"] = borders[BorderPosition.scrollbar + 1];

    data["Scrollbar.decrementButton.h"] = borders[BorderPosition.scrollbar + 2];
    data["Scrollbar.decrementButton.h.highlighted"] = borders[BorderPosition.scrollbar + 3];

    data["Scrollbar.incrementButton.h"] = borders[BorderPosition.scrollbar + 4];
    data["Scrollbar.incrementButton.h.highlighted"] = borders[BorderPosition.scrollbar + 5];

    data["Scrollbar.decrementButton.v"] = borders[BorderPosition.scrollbar + 6];
    data["Scrollbar.decrementButton.v.highlighted"] = borders[BorderPosition.scrollbar + 7];

    data["Scrollbar.incrementButton.v"] = borders[BorderPosition.scrollbar + 8];
    data["Scrollbar.incrementButton.v.highlighted"] = borders[BorderPosition.scrollbar + 9];

    data["Scrollbar.thumb.v"] = borders[BorderPosition.scrollbar + 10];
    data["Scrollbar.thumb.h"] = borders[BorderPosition.scrollbar + 11];

    data["Scrollbar.track.v.off"] = borders[BorderPosition.scrollbar + 12];
    data["Scrollbar.track.h.off"] = borders[BorderPosition.scrollbar + 13];

    data["VSeparator"] = SeparatorSkin;
    data["HSeparator"] = SeparatorSkin;

    data["NumericStepper"] = NumericStepperSkin;
    data["CheckBox"] = CheckBoxSkin;
    data["HSlider"] = HSliderSkin;

    data["TextInput"] = TextInputSkin;
    data["TextInput.border"] = borders[BorderPosition.textField];
    data["TextInput.SystemTextFormat"] = createDefaultTextFormat();

    data["TextArea"] = TextAreaSkin;
    data["TextArea.border"] = borders[BorderPosition.textField];
    data["TextArea.SystemTextFormat"] = createDefaultTextFormat();
    TextLayoutFormatImpl(data["TextArea.SystemTextFormat"]).$lineBreak = LineBreak.TO_FIT;

    data["NumericStepper.TextInput"] = TextInputSkin;

    data["HSeparator.border"] = new SeparatorBorder();

    data["Tree.border"] = borders[BorderPosition.treeItem];
    data["Tree.defaults"] = {paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, indentation: 16, useRollOver: false};
    data["Tree.disclosureIcon.open"] = borders[BorderPosition.treeDisclosureSideBar];
    data["Tree.disclosureIcon.close"] = borders[BorderPosition.treeDisclosureSideBar + 1];
  }

  private static function initAssets():void {
    if (borders != null) {
      return;
    }

    var data:ByteArray = new assetsDataClass();
    assetsDataClass = null;

    var n:int = data.readUnsignedByte();
    borders = new Vector.<Border>(n, true);
    var border:AbstractBitmapBorder;
    for (var i:int = 0; i < n; i++) {
      var typeMarker:int = data.readUnsignedByte();
      switch (typeMarker) {
        case 0: border = new Scale3EdgeHBitmapBorder(); break;
        case 1: border = new Scale1BitmapBorder(); break;
        case 2: border = new Scale9BitmapBorder(); break;
        case 3: border = new OneBitmapBorder(); break;
        case 4: border = new Scale3HBitmapBorder(); break;
        case 5: border = new Scale3VBitmapBorder(); break;

        default: throw new Error("unknown type marker" + typeMarker);
      }
      border.readExternal(data);
      borders[i] = border;
    }

    n = data.readUnsignedByte();
    var icon:BitmapIcon;
    icons = new Vector.<Icon>(n, true);
    for (i = 0; i < n; i++) {
      icon = new BitmapIcon();
      icon.readExternal(data);
      icons[i] = icon;
    }
  }

  public static function _setBordersAndIcons(borders:Vector.<Border>, icons:Vector.<Icon>):void {
    AquaLookAndFeel.borders = borders;
    AquaLookAndFeel.icons = icons;
  }

  private var windowFrameLookAndFeel:WindowFrameLookAndFeel;

  public function createWindowFrameLookAndFeel():WindowFrameLookAndFeel {
    if (windowFrameLookAndFeel == null) {
      windowFrameLookAndFeel = new WindowFrameLookAndFeel(borders, this);
    }
    return windowFrameLookAndFeel;
  }

  private var hudLookAndFeel:HUDLookAndFeel;

  public function createHUDLookAndFeel():HUDLookAndFeel {
    if (hudLookAndFeel == null) {
      hudLookAndFeel = new HUDLookAndFeel(borders, this);
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

import cocoa.Border;
import cocoa.plaf.LookAndFeelUtil;
import cocoa.plaf.TextFormatID;
import cocoa.plaf.aqua.AquaLookAndFeel;
import cocoa.plaf.aqua.BorderPosition;
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
  public function WindowFrameLookAndFeel(borders:Vector.<Border>, parent:AquaLookAndFeel) {
    initialize(borders);
    this.parent = parent;
  }

  private function initialize(borders:Vector.<Border>):void {
    data["PushButton.border"] = borders[BorderPosition.pushButtonTexturedRounded];
  }
}

final class HUDLookAndFeel extends AbstractLookAndFeel {
  [Embed(source="../../../../../../target/assets", mimeType="application/octet-stream")]
  private static var assetsDataClass:Class;

  public function HUDLookAndFeel(borders:Vector.<Border>, parent:AquaLookAndFeel) {
    this.parent = parent;
    initialize(borders);
  }

  private function initialize(borders:Vector.<Border>):void {
    data[TextFormatID.SYSTEM] = AquaFonts.SYSTEM_FONT_HUD;
    data[TextFormatID.SYSTEM_HIGHLIGHTED] = AquaFonts.SYSTEM_FONT_HUD_HIGHLIGHTED;
    data[TextFormatID.VIEW] = AquaFonts.VIEW_FONT_HUD;

    data[TextFormatID.MENU] = AquaFonts.SMALL_SYSTEM_FONT;
    data[TextFormatID.MENU_HIGHLIGHTED] = AquaFonts.SMALL_SYSTEM_FONT_HIGHLIGHTED;

    LookAndFeelUtil.initAssets(data, assetsDataClass);

    data["SelectionFormat"] = new SelectionFormat(0xb5b5b5, 1.0, BlendMode.NORMAL, 0x000000, 1, BlendMode.INVERT);

    data["Window.border"] = borders[BorderPosition.hudWindow];

    data["TextInput.border"] = new HUDTextInputBorder();
    data["TextInput.SystemTextFormat"] = createDefaultTextFormat();

    data["HSeparator.border"] = new SeparatorBorder();

    data["PushButton"] = HUDPushButtonSkin;

    data["MenuItem.border"] = new MenuItemBorder(borders[BorderPosition.hudMenuItem]);
    data["MenuItem.border.highlighted"] = borders[BorderPosition.hudMenuItem];

    data["NumericStepper.TextInput"] = TextInputSkin;
    data["NumericStepper.TextInput.border"] = new NumericStepperTextInputBorder();

    var numericStepperTextFormat:TextLayoutFormatImpl = createDefaultTextFormat();
    numericStepperTextFormat.$textAlign = TextAlign.END;
    data["NumericStepper.TextInput.SystemTextFormat"] = numericStepperTextFormat;

    data["NumericStepper.incrementButton"] = borders[BorderPosition.spinnerButton];
    data["NumericStepper.decrementButton"] = borders[BorderPosition.spinnerButton + 1];

    data["Slider.thumb"] = borders[BorderPosition.sliderThumb];
    data["Slider.track.h"] = borders[BorderPosition.sliderTrack];

    data["CheckBox.border"] = borders[BorderPosition.checkBox];

    data["TitleBar.PushButton"] = _parent.getClass("PushButton");
    data["TitleBar.PushButton.border"] = borders[BorderPosition.hudTitleBarCloseButton];
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