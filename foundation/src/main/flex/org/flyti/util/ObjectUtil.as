package org.flyti.util
{
import flash.utils.ByteArray;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import mx.utils.SHA256;

public class ObjectUtil
{
	public static function typify(object:Object, clazz:Class, excludeProperties:Array = null):*
	{
		var typedObject:* = new clazz;
		for (var name:String in object)
		{
			if (excludeProperties == null || excludeProperties.indexOf(name) == -1)
			{
				if (typedObject[name] is Number && object[name] == null)
				{
					typedObject[name] = NaN;
				}
				else
				{
					try
					{
						typedObject[name] = object[name];
					}
					catch (e:TypeError)
					{
						var definitionName:String = object[name];
						var lastDotPosition:uint = object[name].lastIndexOf('.');
						var charAfterLastDot:String = definitionName.charAt(lastDotPosition + 1);
						if (charAfterLastDot == charAfterLastDot.toLowerCase())
						{
							typedObject[name] = Class(getDefinitionByName(definitionName.substr(0, lastDotPosition)))[definitionName.substr(lastDotPosition + 1)];
						}
						else
						{
							typedObject[name] = Class(getDefinitionByName(definitionName));
						}
					}
				}
			}
		}

		return typedObject;
	}

	public static function getClass(name:String):Class
	{
		return Class(getDefinitionByName(name));
	}

	public static function getClassName(object:Object):String
	{
		return getQualifiedClassName(object).replace("::", ".");
	}

	public static function unqualifyClassName(qualifiedClassName:String):String
	{
		return qualifiedClassName.substr(qualifiedClassName.lastIndexOf(".") + 1);
	}

	public static function hash(object:Object):String
	{
		if (object == null)
		{
			return null;
		}
		else
		{
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeObject(object);
			return SHA256.computeDigest(byteArray);
		}
	}
}
}