package cocoa.message {

import flash.utils.Dictionary;

public class MessageManager {
  private var messages:Dictionary = new Dictionary(true);

  private static var _instance:MessageManager;

  public static function get instance():MessageManager {
    if (_instance == null) {
      _instance = new MessageManager();
    }

    return _instance;
  }

  /**
   * Может быть сколь угодно много ComplexToolTip, но только один представитель kind - все они должны иметь разный kind
   * (одновременно и подсказка пользователю, и системное сообщение об ошибке)
   */
  public function show(messageKind:MessageKind, hideEvenPrevUnderMouse:Boolean = true):void {
    if (messageKind.id in messages) {
      var existenceManager:MessageExistenceManager = MessageExistenceManager(messages[messageKind.id]);
      if (!hideEvenPrevUnderMouse && existenceManager.underMouse) {
        return;
      }
      existenceManager.hide();
    }

    var complexToolTipExistence:MessageExistenceManager = new MessageExistenceManager(messageKind);
    messages[messageKind.id] = complexToolTipExistence;
    complexToolTipExistence.show();
  }

  public function unregisterExistenceManager(id:uint, instance:MessageExistenceManager):void {
    if (id in messages && instance == messages[id]) {
      delete messages[id];
    }
  }

  public function exist(id:uint = 0):Boolean {
    return getExistenceManager(id) != null;
  }

  public function getExistenceManager(id:uint = 0):MessageExistenceManager {
    return (id in messages) ? MessageExistenceManager(messages[id]) : null;
  }
}
}