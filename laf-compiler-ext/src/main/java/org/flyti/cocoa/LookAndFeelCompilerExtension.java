package org.flyti.cocoa;

import flash.swf.TagValues;
import flash.swf.tags.DefineBitsLossless;
import flex2.compiler.AssetInfo;
import flex2.compiler.CompilationUnit;
import flex2.compiler.Source;
import flex2.compiler.Transcoder;
import flex2.compiler.as3.As3Configuration;
import flex2.compiler.as3.Extension;
import flex2.compiler.as3.reflect.TypeTable;
import flex2.compiler.extensions.IAsCompilerExtension;
import flex2.compiler.io.LocalFile;
import flex2.compiler.util.NameMappings;

import java.util.List;

public class LookAndFeelCompilerExtension implements IAsCompilerExtension, Extension {
  @Override
  public void run(List<Extension> asCompilerExtensions, String gendir, As3Configuration ascConfiguration, NameMappings mappings, Transcoder[] transcoders) {
    asCompilerExtensions.add(this);
  }

  @Override
  public void parse1(CompilationUnit unit, TypeTable typeTable) {
    final Source source = unit.getSource();
    if (!(source.getBackingFile() instanceof LocalFile)) {
      return;
    }

    if (source.getShortName().equals("Main")) {
      unit.getAssets();
      unit.getAssets().add("BT", new AssetInfo(build(new int[]{0, 0, 0, 0}, 2, 2), null, 0, null));
    }
  }

  public static DefineBitsLossless build(int[] pixels, int width, int height) {
    DefineBitsLossless defineBitsLossless = new DefineBitsLossless(TagValues.stagDefineBitsLossless2);
    defineBitsLossless.format = DefineBitsLossless.FORMAT_24_BIT_RGB;
    defineBitsLossless.width = width;
    defineBitsLossless.height = height;
    defineBitsLossless.data = new byte[pixels.length * 4];

    for (int i = 0; i < pixels.length; i++) {
      int offset = i * 4;
      int alpha = (pixels[i] >> 24) & 0xFF;
      defineBitsLossless.data[offset] = (byte) alpha;

      // [preilly] Ignore the other components if alpha is transparent.  This seems
      // to be a bug in the player.  Additionally, premultiply the alpha and the
      // colors, because the player expects this.
      if (defineBitsLossless.data[offset] != 0) {
        int red = (pixels[i] >> 16) & 0xFF;
        defineBitsLossless.data[offset + 1] = (byte) ((red * alpha) / 255);
        int green = (pixels[i] >> 8) & 0xFF;
        defineBitsLossless.data[offset + 2] = (byte) ((green * alpha) / 255);
        int blue = pixels[i] & 0xFF;
        defineBitsLossless.data[offset + 3] = (byte) ((blue * alpha) / 255);
      }
    }

    return defineBitsLossless;
  }

  @Override
  public void parse2(CompilationUnit unit, TypeTable typeTable) {
  }

  @Override
  public void analyze1(CompilationUnit unit, TypeTable typeTable) {
  }

  @Override
  public void analyze2(CompilationUnit unit, TypeTable typeTable) {
  }

  @Override
  public void analyze3(CompilationUnit unit, TypeTable typeTable) {
  }

  @Override
  public void analyze4(CompilationUnit unit, TypeTable typeTable) {
  }

  @Override
  public void generate(CompilationUnit unit, TypeTable typeTable) {
  }
}
