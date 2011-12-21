package cocoa.plaf.aqua.assetBuilder {
import cocoa.plaf.LookAndFeelUtil;
import cocoa.util.Files;

import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.utils.Dictionary;

public class Main extends Sprite {
  public function Main() {
    build();
    
    //var d:Dictionary = new Dictionary();
    //LookAndFeelUtil.initAssets2(d, Files.readBytes("/Users/develar/f"));
  }

  private function build():void {
    new Builder().build(this);
    NativeApplication.nativeApplication.exit();
  }
}
}