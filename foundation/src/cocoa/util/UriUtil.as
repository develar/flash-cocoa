package cocoa.util {
public final class UriUtil {
  public static function trim(uri:String, deleteWWW:Boolean = false):String {
    uri = Strings.trim(uri);
    if (Strings.startsWith(uri, "http://")) {
      uri = uri.substr(7);
    }
    if (deleteWWW && Strings.startsWith(uri, "www.")) {
      uri = uri.substr(4);
    }
    if (uri.charAt(uri.length - 1) == '/') {
      uri = uri.substr(0, -1);
    }
    return uri;
  }

  public static function isOnlyHost(string:String):Boolean {
    return string.match('/') == null;
  }
}
}