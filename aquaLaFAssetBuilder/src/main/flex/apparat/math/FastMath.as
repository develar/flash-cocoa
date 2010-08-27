package apparat.math {
// @todo
public class FastMath {
  /**
   * Returns the smallest value of the given parameters.
   *
   * @param value0 A number.
   * @param value1 A number.
   * @return The smallest of the parameters <code>value0</code> and <code>value1</code>.
   */
  public static function min(value0:Number, value1:Number):Number {
    return (value0 < value1) ? value0 : value1
  }

  /**
   * Returns the largest value of the given parameters.
   *
   * @param value0 A number.
   * @param value1 A number.
   * @return The largest of the parameters <code>value0</code> and <code>value1</code>.
   */
  public static function max(value0:Number, value1:Number):Number {
    return (value0 > value1) ? value0 : value1
  }
}
}