package cocoa.util {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

public final class Files {
  public static const SEPARATOR:String = "/";

  private static const OPEN_MACRO:String = "{";
  private static const CLOSE_MACRO:String = "}";

  public static function writeBytes(filename:String, bytes:ByteArray):void {
    var fileStream:FileStream = new FileStream();
    fileStream.open(new File(filename), FileMode.WRITE);
    fileStream.writeBytes(bytes);
    fileStream.close();
  }

  public static function readBytesByFile(file:File):ByteArray {
    var fileStream:FileStream = new FileStream();
    fileStream.open(file, FileMode.READ);
    var bytes:ByteArray = new ByteArray();
    fileStream.readBytes(bytes);
    fileStream.close();
    return bytes;
  }

  public static function readObject(file:File):Object {
    var fileStream:FileStream = new FileStream();
    fileStream.open(file, FileMode.READ);
    var object:Object = fileStream.readObject();
    fileStream.close();
    return object;
  }

  public static function readBytes(filename:String):ByteArray {
    return readBytesByFile(new File(filename));
  }

  public static function writeString(filename:String, string:String):void {
    var fileStream:FileStream = new FileStream();
    fileStream.open(new File(filename), FileMode.WRITE);
    fileStream.writeUTFBytes(string);
    fileStream.close();
  }

  public static function getCanonicalPath(path:String):String {
    if (Strings.startsWith(path, "file://")) {
      path = path.substr(7);
    }

    if (Strings.startsWith(path, OPEN_MACRO)) {
      var i:int = 1;
      var character:String;
      var propertyName:String = "";
      while ((character = path.charAt(i++)) != CLOSE_MACRO) {
        if (character == "") {
          throw new Error("unclosed macros");
        }
        propertyName += character;
      }
      path = File(File[propertyName]).nativePath + File.separator + path.substr(i);
    }
    else if (!Strings.startsWith(path, SEPARATOR)) {
      path = File.applicationDirectory.nativePath + File.separator + path;
    }

    return path;
  }
}
}