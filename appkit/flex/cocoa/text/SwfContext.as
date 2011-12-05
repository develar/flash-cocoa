package cocoa.text {
public interface SwfContext {
  function callInContext(fn:Function, thisArg:Object, argArray:Array):*;
}
}
