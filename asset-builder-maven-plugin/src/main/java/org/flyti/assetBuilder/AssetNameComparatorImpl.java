package org.flyti.assetBuilder;

class AssetNameComparatorImpl implements AssetNameComparator {
  private int start;

  @Override
  public void setPrefixLength(int prefixLength) {
    start = prefixLength == 0 ? 1 /* o(ff|n|ver)*/ : (prefixLength + 2/* . + o(ff|n|ver)*/);
  }

  @Override
  public int compare(String s1, String s2) {
    return getWeight(s1) - getWeight(s2);
  }

  private int getWeight(String s) {
    final int weight;
    final int stateIndex;

    switch (s.charAt(start)) {
      case 'f':
        stateIndex = 2;
        weight = 100;
        break;

      case 'n':
        stateIndex = 1;
        weight = 200;
        break;

      case 'v':
        return 300;

      default:
        throw new IllegalArgumentException("unknown " + s);
    }

    switch (s.charAt(start + stateIndex)) {
      case '.':
        return weight;

      case 'H':
        return weight + 10;

      case 'O':
        return weight + 20;

      default:
        throw new IllegalArgumentException("unknown " + s);
    }
  }
}
