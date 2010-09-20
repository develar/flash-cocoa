package org.flyti.assetBuilder;

import java.util.Comparator;

public interface AssetNameComparator extends Comparator<String> {
  void setPrefixLength(int prefixLength);
}
