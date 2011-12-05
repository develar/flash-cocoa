package cocoa.message {
import flash.events.Event;

import cocoa.resources.ResourceManager;

public class ApplicationErrorEvent extends Event {
  public static const APPLICATION_ERROR:String = "applicationErrorEvent";

  private var localizedMessage:String;

  public function ApplicationErrorEvent(notLocalizedMessage:String, detail:Object = null, bundle:String = null, messageParameters:Array = null) {
    _notLocalizedMessage = notLocalizedMessage;
    if (bundle != null) {
      localizedMessage = ResourceManager.instance.getString(bundle, notLocalizedMessage, messageParameters);
    }
    _detail = detail;

    super(APPLICATION_ERROR);
  }

  public function get message():String {
    return localizedMessage;
  }

  private var _notLocalizedMessage:String;
  public function get notLocalizedMessage():String {
    return _notLocalizedMessage;
  }

  private var _detail:Object;
  public function get detail():Object {
    return _detail;
  }
}
}