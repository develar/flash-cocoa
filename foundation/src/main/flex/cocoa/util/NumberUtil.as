package cocoa.util {
public final class NumberUtil {
  public static function correctValue(value:Number, min:Number, max:Number):Number {
    if (value > max) {
      return max;
    }
    else if (value < min) {
      return min;
    }
    else {
      return value;
    }
  }

  public static function calculate(operation:String, v1:Number, v2:Number):Number {
    switch (operation) {
      case ArithmeticOperation.ADDITION: return v1 + v2;
      case ArithmeticOperation.SUBTRACTION: return v1 - v2;
      case ArithmeticOperation.MULTIPLICATION: return v1 * v2;
      case ArithmeticOperation.DIVISION: return v1 / v2;
    }

    throw new Error('unknown operation');
  }

  /**
   * number, operator, number, operator,..
   */
  public static function calculateArray(values:Array):Number {
    var result:Number = Number(values[0]);
    var n:int = values.length;
    for (var i:int = 2; i < n; i += 2) {
      result = calculate(String(values[i - 1]), result, Number(values[i]));
    }
    return result;
  }

  public static function calculateMaxResult(operation:String, v1Max:Number, v2Max:Number, v2Min:Number):Number {
    switch (operation) {
      case ArithmeticOperation.DIVISION: return v1Max / v2Min;
      case ArithmeticOperation.SUBTRACTION: return v1Max - v2Min;

      case ArithmeticOperation.MULTIPLICATION: return v1Max * v2Max;
      case ArithmeticOperation.ADDITION: return v1Max + v2Max;

      default: throw new Error('unknown operation');
    }
  }
}
}