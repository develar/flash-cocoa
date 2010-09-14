package cocoa.plaf {
import cocoa.border.AbstractBitmapBorder;
import cocoa.border.CappedSmartBorder;
import cocoa.border.OneBitmapBorder;
import cocoa.border.Scale1BitmapBorder;
import cocoa.border.Scale3EdgeHBitmapBorder;
import cocoa.border.Scale3EdgeHBitmapBorderWithSmartFrameInsets;
import cocoa.border.Scale3HBitmapBorder;
import cocoa.border.Scale3VBitmapBorder;
import cocoa.border.Scale9EdgeBitmapBorder;
import cocoa.plaf.basic.BitmapIcon;

import flash.display.DisplayObjectContainer;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

public final class LookAndFeelUtil {
  public static function find(p:DisplayObjectContainer):LookAndFeel {
    var laf:LookAndFeel;
    while (p != null) {
      if (p is LookAndFeelProvider) {
        laf = LookAndFeelProvider(p).laf;
        if (laf != null) {
          return laf;
        }
      }
      else if (p is Skin && Skin(p).component is LookAndFeelProvider) {
        return LookAndFeelProvider(Skin(p).component).laf;
      }

      p = p.parent;
    }

    throw new Error("LaF not found");
  }

  public static function initAssets(data:Dictionary, assetsDataClass:Class):void {
    var assetsData:ByteArray = new assetsDataClass();
    assetsDataClass = null;

    const n:int = assetsData.readUnsignedByte();
    var border:AbstractBitmapBorder;
    for (var i:int = 0; i < n; i++) {
      const key:String = assetsData.readUTF();
      switch (assetsData.readUnsignedByte()) {
        case 0: border = new Scale3EdgeHBitmapBorder(); break;
        case 1: border = new Scale1BitmapBorder(); break;
        case 2: border = new Scale9EdgeBitmapBorder(); break;
        case 3: border = new OneBitmapBorder(); break;
        case 4: border = new Scale3HBitmapBorder(); break;
        case 5: border = new Scale3VBitmapBorder(); break;
        case 6: border = new Scale3EdgeHBitmapBorderWithSmartFrameInsets(); break;
        case 7: border = new CappedSmartBorder(); break;

        default: throw new Error("unknown border type marker");
      }
      border.readExternal(assetsData);
      data[key] = border;
    }

    var icon:BitmapIcon;
    while (assetsData.bytesAvailable > 0) {
      icon = new BitmapIcon();
      data[assetsData.readUTF()] = icon;
      icon.readExternal(assetsData);
    }
  }
}
}