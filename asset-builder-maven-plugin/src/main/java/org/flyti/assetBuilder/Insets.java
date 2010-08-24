package org.flyti.assetBuilder;

public class Insets {
  public int left;
  public int top;
  public int right;
  public int bottom;

  public byte truncatedTailMargin = -1;

  public Insets(int left, int top, int right, int bottom) {
    this.left = left;
    this.top = top;
    this.right = right;
    this.bottom = bottom;
  }

  @SuppressWarnings({"UnusedDeclaration"})
  public Insets() {
  }

  public int getWidth() {
    return left + right;
  }

  public int getHeight() {
    return top + bottom;
  }
}
