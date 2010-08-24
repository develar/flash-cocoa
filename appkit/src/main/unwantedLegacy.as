import cocoa.AbstractView;

import flash.errors.IllegalOperationError;

override public function setStyle(styleProp:String, newValue:*):void {
  throw new IllegalOperationError();
}

override public function regenerateStyleCache(recursive:Boolean):void {

}

override public function styleChanged(styleProp:String):void {

}

override protected function resourcesChanged():void {

}

override public function get layoutDirection():String {
  return AbstractView.LAYOUT_DIRECTION_LTR;
}

override public function registerEffects(effects:Array /* of String */):void {

}

override public function notifyStyleChangeInChildren(styleProp:String, recursive:Boolean):void {

}

override mx_internal function initThemeColor():Boolean {
  return true;
}