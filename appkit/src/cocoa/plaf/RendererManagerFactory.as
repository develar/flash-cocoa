package cocoa.plaf {
import cocoa.ClassFactory;
import cocoa.renderer.RendererManager;

public final class RendererManagerFactory extends ClassFactory {
  private var laf:LookAndFeel;
  private var lafKey:String;

  function RendererManagerFactory(clazz:Class, lafKey:String, laf:LookAndFeel = null) {
    super(clazz);

    this.laf = laf;
    this.lafKey = lafKey;
  }

  public function create(laf:LookAndFeel = null):RendererManager {
    return new clazz(this.laf || laf, lafKey);
  }
}
}
