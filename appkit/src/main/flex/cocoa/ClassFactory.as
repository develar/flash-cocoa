package cocoa {
import mx.core.IFactory;

public class ClassFactory implements IFactory {
  private var clazz:Class;

  public function ClassFactory(clazz:Class) {
    this.clazz = clazz;
  }

  public function newInstance():* {
    return new clazz();
  }
}
}