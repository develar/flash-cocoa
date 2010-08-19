package cocoa.util {
import cocoa.keyboard.Shortcut;

import flash.system.Capabilities;
import flash.ui.Keyboard;

public final class ShortcutUtil {
  public static function generateLabel(shortcut:Shortcut):String {
    const isMac:Boolean = Capabilities.os.indexOf("Mac OS") != -1;
    var label:String = "";
    if (isMac) {
      if (shortcut.alt) {
        label += "⌥";
      }
      if (shortcut.shift) {
        label += "⇧";
      }
      if (shortcut.command) {
        label += "⌘";
      }
    }
    else {
      if (shortcut.command) {
        label += "Ctrl+";
      }
      if (shortcut.alt) {
        label += "Alt+";
      }
      if (shortcut.shift) {
        label += "Shift+";
      }
    }

    label += keyCodeToText(shortcut.code, isMac);
    return label;
  }

  private static function keyCodeToText(code:uint, isMac:Boolean):String {
    if (code >= 112 && code <= 126) {
      return "F" + (code - 111);
    }
    else {
      switch (code) {
        case Keyboard.DELETE: return isMac ? "⌫" : "Delete";
        case Keyboard.BACKSPACE: return isMac ? "⌫" : "BackSpace";
        case Keyboard.ENTER: return isMac ? "↩" : "Enter"; // TLF не может (18 мая 2009) отобразить ⏎ — для любого шрифта квадратик, так что пока используем этот символ
      }

      return String.fromCharCode(code);
    }
  }
}
}