package org.flyti.assetBuilder;

class AppleAssetNameComparator implements AssetNameComparator {
  private int prefixLength;
  private int start = -1;

  public void setPrefixLength(int prefixLength) {
    start = -1;
    this.prefixLength = prefixLength;
  }

  @Override
  public int compare(String s1, String s2) {
    if (start == -1) {
      final char testChar = s1.charAt(prefixLength);
      start = testChar == '_' || testChar == '-' ? prefixLength + 1 : prefixLength;
    }
    return getWeight(s1) - getWeight(s2);
  }

  private int getWeight(String s) {
    final int weight;
    final int stateIndex;
    switch (s.charAt(start)) {
      case 'L': // Left
        if (s.charAt(start + 4) == 'C') {
          return 1;
        }
        else {
          weight = 10;
          stateIndex = 5;
        }
        break;

      case 'F': // Fill
        if (s.charAt(start + 4) == '.') {
          return 2;
        }
        else {
          weight = 20;
          stateIndex = 5;
        }
        break;

      case 'R':
        if (s.charAt(start + 1) == 'i') {
          if (s.charAt(start + 5) == 'C') {
            return 3;
          }
          else {
            weight = 30; // Right
            stateIndex = 6;
          }
        }
        else {
          return 4; // Rollover
        }
        break;

      case 'N': // Normal
        return 1;
      case 'P': // Pressed
        return 2;
      case 'D': // Disabled
        return 3;

      case 'O': // Off/On
        if (s.charAt(start + 1) == 'f') {
          weight = 1000;
          stateIndex = 4;
        }
        else {
          weight = 2000;
          stateIndex = 3;
        }
        break;

      // -top, -fill, -bottom
      case 't': return 0;
      case 'f': return 1;
      case 'b': return 2;

      default:
        throw new IllegalArgumentException("unknown " + s);
    }

    switch (s.charAt(start + stateIndex)) {
      case 'N':
        return weight + 100;

      case 'P':
        return weight + 200;

      case 'D':
        return weight + 300;

      default:
        throw new IllegalArgumentException("unknown " + s);
    }
  }
}
