package {
public function assert(value:Boolean, message:String = null):void {
  if (!value) {
    var errorText:String = "assert failed";
    if (message != null) {
      errorText += ": " + message;
    }
    throw new Error(errorText);
  }
}
}