package cocoa.layout {
import cocoa.AbstractView;

public interface Layout {
  function measure(target:AbstractView):void;

  function updateDisplayList(target:AbstractView, w:Number, h:Number):void;
}
}
