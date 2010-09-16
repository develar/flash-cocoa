package cocoa.plaf.aqua.assetBuilder {
import flash.desktop.NativeApplication;
import flash.display.Sprite;

public class Main extends Sprite {
  public function Main() {
    build();
  }

  private function build():void {
    new Builder().build(this);
    NativeApplication.nativeApplication.exit();
  }
}
}