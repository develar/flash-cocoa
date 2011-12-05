package cocoa.plaf {
import cocoa.ClassFactory;

public final class RendererManagerFactory extends ClassFactory {
  private var laf:LookAndFeel;
  private var lafKey:String;

  function RendererManagerFactory(clazz:Class, laf:LookAndFeel, lafKey:String) {
    super(clazz);

    this.laf = laf;
    this.lafKey = lafKey;
  }

  override public function newInstance():* {
    return new clazz(laf, lafKey);
  }
}
}
