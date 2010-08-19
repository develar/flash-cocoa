package cocoa.util
{
import mx.utils.StringUtil;
import cocoa.util.StringUtil;

public class UriUtil
{
	public static function trim(uri:String, deleteWWW:Boolean = false):String
	{
		uri = mx.utils.StringUtil.trim(uri);
		if (cocoa.util.StringUtil.startsWith(uri, "http://"))
		{
			uri = uri.substr(7);
		}
		if (deleteWWW && cocoa.util.StringUtil.startsWith(uri, "www."))
		{
			uri = uri.substr(4);
		}
		if (uri.charAt(uri.length - 1) == '/')
		{
			uri = uri.substr(0, -1);
		}
		return uri;
	}

	public static function isOnlyHost(string:String):Boolean
	{
		return string.match('/') == null;
	}
}
}