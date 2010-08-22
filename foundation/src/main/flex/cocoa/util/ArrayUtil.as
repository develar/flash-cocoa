package cocoa.util
{
/**
 * splice для удаления не подходит, так как не работает для свойств (при получении через get оригинал не изменяется)
 */
public class ArrayUtil
{
	public static function remove(index:uint, array:Array):Array
	{
		return array.slice(0, index).concat(array.slice(index + 1));
	}

	public static function add(item:Object, array:Array):Array
	{
		array.push(item);
		return array;
	}

	public static function setNumberAt(value:Number, index:int, array:Array):void
	{
		if (array.length <= index)
		{
			for (var i:int = array.length; i < index; i++)
			{
				array.push(NaN);
			}
			array.push(value);
		}
		else
		{
			array[index] = value;
		}
	}

	public static function vectorToArray(vector:*):Array
	{
		var result:Array = new Array();
		for each (var item:* in vector)
		{
			result.push(item);
		}
		return result;
	}

	/**
	 * Use * as type for support Vectors
	 */
	public static function intersect(array1:*, array2:*):*
	{
		return array1.filter(
		function intersectFilter(item:*, index:int, array:*):Boolean
		{
			return this.indexOf(item) !== -1;
		}, array2);
	}

	/**
	 * Returns an array containing all the items from first that are not present in second
	 */
	public static function diff(array1:*, array2:*):*
	{
		return array1.filter(
		function diffFilter(item:*, index:int, array:*):Boolean
		{
			return this.indexOf(item) == -1;
		}, array2);
	}

	public static function random(array:Array):Object
	{
		return array[Math.floor(Math.random() * array.length)];
	}

	public static function removeTrailerNaN(array:Array):Array
	{
		for (var i:int = array.length - 1; i > -1; i--)
		{
			if (!isNaN(array[i]))
			{
				return array.slice(0, i + 1);
			}
		}

		return array;
	}
}
}