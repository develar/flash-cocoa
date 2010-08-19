package org.flyti.util
{
import flash.utils.ByteArray;

import mx.utils.StringUtil;

public class StringUtil
{
	private static const ALTERNATE_MULTIPLICATION_SIGN:Array = ['\u25CF', '\u2020'];

	private static const MAX_PATHNAME_LENGTH:uint = 20;
	private static const SUMMARY_LENGTH:uint = 150;

	private static const RUSSIAN_TRANSLIT_TABLE:Object = {'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ё': 'e', 'ж': 'zh', 'з': 'z', 'и': 'i', 'й': 'jj', 'к': 'k', 'л': 'l', 'м': 'm', 'н': 'n', 'о': 'o', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u', 'ф': 'f', 'х': 'kh', 'ц': 'c', 'ч': 'ch', 'ш': 'sh', 'щ': 'shh', 'ъ': '', 'ы': 'y', 'ь': '', 'э': 'eh', 'ю': 'ju', 'я': 'ja'};
	private static const FORBIDDEN_CHARACTERS:Object = {'\\': '', '/': '', ':': '', '*': '', '?': '', '"': '', '<': '', '>': '', '|': ''};

	public static function startsWith(string:String, prefix:String, offset:int = 0):Boolean
	{
		var prefixCount:int = prefix.length;
		if ((offset < 0) || (offset > (string.length - prefixCount)))
		{
			return false;
		}

		var thisOffset:int = offset;
		var prefixOffset:int = 0;
		while (--prefixCount >= 0)
		{
			if (string.charCodeAt(thisOffset++) != prefix.charCodeAt(prefixOffset++))
			{
				return false;
			}
		}
		return true;
	}

	public static function replace(string:String, map:Object):String
	{
		for (var from:String in map)
		{
			string = string.replace(new RegExp(from.replace('$', '\\$'), 'g'), map[from]);
		}
		return string;
	}

	public static function cut(string:String, limit:uint):String
	{
		return string.split(/\s+/, limit).join(' ');
	}

	public static function stripTags(string:String):String
	{
		return mx.utils.StringUtil.trim(string.replace(/<\/?[^>]+>/g, ''));
	}

	public static function toByteArray(data:String):ByteArray
	{
		var byteArray:ByteArray = new ByteArray();
		byteArray.writeUTFBytes(data);
		return byteArray;
	}

	/**
	 * Специальные символы HTML представленные как код заменяются на соответствующий символ UTF-8. Не все, только часто используемые.
	 */
	public static function htmlCodeToUtf8(string:String):String
	{
		return replace(string, {'&ndash;': '-', '&mdash;': '—', '&laquo;': '«', '&raquo;': '»', '&copy;': '©', '&reg;': '®', '&hellip;': '…'});
	}

	/**
	 * summary для новости, статьи и т. п. из текста
	 */
	public static function summarize(text:String):String
	{
		return stripTags(text).substr(0, SUMMARY_LENGTH);
	}

	public static function translit(string:String, spaceAsHyphen:Boolean = false):String
	{
		string = string.toLowerCase();
		var result:String = '';
		var character:String;
		for (var i:uint = 0; i < string.length; i++)
		{
			character = string.charAt(i);
			if (character == ' ')
			{
				result += spaceAsHyphen ? '-' : '_';
			}
			else if (character in RUSSIAN_TRANSLIT_TABLE)
			{
				result += RUSSIAN_TRANSLIT_TABLE[character];
			}
			else if (!(character in FORBIDDEN_CHARACTERS))
				{
					result += character;
				}
		}
		return result;
	}

	public static function truncatePathname(pathname:String, max:uint = MAX_PATHNAME_LENGTH):String
	{
		if (pathname.length > max)
		{
			var fileName:String = '';
			var directorySeparator:String;
			for (var i:uint = pathname.length - 1; i > 1; i--)
			{
				directorySeparator = pathname.charAt(i);
				if (directorySeparator == '/' || directorySeparator == '\\')
				{
					break;
				}
				else
				{
					fileName = directorySeparator + fileName;
				}
			}
			var path:String = pathname.substr(0, i);
			var length:Number = (path.length / 2) - ((path.length - max) / 2);
			return path.substr(0, length) + '…' + path.substr(-length) + directorySeparator + fileName;
		}
		else
		{
			return pathname;
		}
	}

	public static function repeat(string:String, multiplier:int):String
	{
		var result:String = '';
		while (multiplier--)
		{
			result += string;
		}
		return result;
	}

	public static function isUint(string:String):Boolean
	{
		return string.match(/^\d+$/) != null;
	}

	/**
	 * http://en.wikipedia.org/wiki/ASCII
	 * http://ru.wikipedia.org/wiki/Пробел
	 * http://en.wikipedia.org/wiki/Space_(punctuation)
	 */
	public static function isWhitespace(aChar:String):Boolean
	{
		var charCode:Number = aChar.charCodeAt(0);
		return charCode == 32 || (charCode > 8 && charCode < 14) || (charCode > 8191 && charCode < 8288) || charCode == 12288;
	}

	public static function isWordEnding(aChar:String):Boolean
	{
		switch (aChar)
		{
			case '.':
			case ',':
			case '?':
			case '!':
			case ')':
			case ']':
			case '…':
			{
				return true;
			}

			default:
			{
				return false;
			}
		}
	}

	public static function isWordStarting(aChar:String):Boolean
	{
		switch (aChar)
				{
			case '(':
			case '[':
			// spanish
			case '¿':
			case '¡':
			{
				return true;
			}

			default:
			{
				return false;
			}
		}
	}

//	public static function removeInitialZero(input:TextInput):void
//	{
//		var text:String = input.text;
//		if (text != '0')
//		{
//			var startIndex:int = 0;
//			while (text.charAt(startIndex) == '0')
//			{
//				startIndex++;
//			}
//
//			if (startIndex > 0)
//			{
//				if (startIndex == text.length)
//				{
//					startIndex -= 1;
//				}
//				input.text = text.slice(startIndex);
//			}
//		}
//	}

	public static function operationCodeToText(code:String, small:Boolean = false):String
	{
		switch (code)
		{
			case '-': return '−'; // 8722
			case ArithmeticOperation.MULTIPLICATION: return /*'×'*//*String.fromCharCode(0x25CF)*/ small ? '\u00B7' : '\u2022';
			case ArithmeticOperation.DIVISION: return small ? ':' : '/';
			default: return code;
		}
	}
}
}