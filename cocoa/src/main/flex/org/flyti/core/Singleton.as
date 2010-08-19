package org.flyti.core {
import flash.utils.Dictionary;

public class Singleton {
  private static const classMap:Dictionary = new Dictionary();

  /**
   * Если вы хотите переопределить Singleton, то зарегистрируйте ваш класс под именем интерфейса, который реализует переопределяемый Singleton.
   * Не все используют интерфейс, а просто подразумевают, что при переопределении вы будете наследовать, а не создавать отдельный самостоятельный класс реализующий интерфейс.
   * Скажем, org.flyti.flyf.managers.typeManager.TypeManager так и делает.
   */
  public static function registerClass(name:String, clazz:Class):void {
    if (!('name' in classMap)) {
      classMap[name] = clazz;
    }
  }

  public static function checkInstantiation(instance:ISingleton):void {
    if (instance != null) {
      throw new Error('You can not created instance directly');
    }
  }

  public static function getInstance(name:String, defaultClass:Class):Object {
    if (!(name in classMap)) {
      classMap[name] = defaultClass;
    }
    return new classMap[name]();
  }
}
}