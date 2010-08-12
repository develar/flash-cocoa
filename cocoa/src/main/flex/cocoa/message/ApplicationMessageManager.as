package cocoa.message {
import flash.system.Capabilities;

import mx.utils.ObjectUtil;

/**
 * todo типа как в IntelliJ IDEA сделать, но пока хватит и так
 */
public class ApplicationMessageManager {
  private static const FATAL_ERROR_NOTIFICATION:uint = 1;

  protected var notificationView:ApplicationNotification;

  public function show(event:ApplicationErrorEvent):void {
    var message:String = event.message == null /* if locale chain empty, ResourceManager return null, but not throw error */ ? event.notLocalizedMessage : event.message;
    if (Capabilities.isDebugger && event.detail != null) {
      message += "\n" + ObjectUtil.toString(event.detail);
    }

    trace(message);

    if (notificationView == null) {
      notificationView = new ApplicationNotification();
    }
    notificationView.text = message;

    var messageKind:MessageKind = new MessageKind(FATAL_ERROR_NOTIFICATION);
    messageKind.message = notificationView;
    messageKind.position = MessagePosition.APPLICATION_BOTTOM_RIGHT_CORNER;
    MessageManager.instance.show(messageKind);
  }
}
}