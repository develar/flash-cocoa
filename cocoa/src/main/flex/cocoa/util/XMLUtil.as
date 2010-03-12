package cocoa.util
{
public class XMLUtil
{
	public static function cdata(name:String, data:String):XML
	{
		return new XML("<" + name + "><![CDATA[" + data + "]]></" + name + ">");
	}
}
}