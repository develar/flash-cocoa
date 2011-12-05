package cocoa.plaf.aqua.assetBuilder {
import cocoa.border.AbstractBitmapBorder;

internal class RowInfo {
  public var top:Number;
  public var width:Number;
  public var height:Number;

  public var index:Number;

  public var border:AbstractBitmapBorder;

  public function RowInfo(index:int, border:AbstractBitmapBorder, width:Number = 50, height:Number = 30) {
    this.width = width;
    this.height = height;

    this.border = border;

    this.index = index;
  }
}
}