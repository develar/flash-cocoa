package cocoa {
import flash.display.Graphics;

/**
 * Терминология frame/layout взята из Cocoa.
 * У объекта два rect — frame и layout. примерно то же самое, что и DisplayObject.getBounds() и DisplayObject.getRect()
 * frame rect включает в себя весь контент объекта + весь хром, который может отрисовываться вне (0, 0, w, h)
 * layout rect это только размер объекта без хрома.
 *
 * layoutWidth/layoutHeight могут быть указаны как отрицательные — некий компонент может интерпретировать это как в процентах (то есть -50 это 50%), а не в px
 */
public interface Border {
  /**
   * frameInsets — border может отрисовывать себя вне layout rect, к примеру тень будет вне layout rect
   */
  function get frameInsets():FrameInsets;

  /**
   * Отступ контента объекта от layout rect edge. К примеру, Button использует bottom как y для textLine, а ListView как именно отступы.
   */
  function get contentInsets():Insets;

  /**
   * border может определять высоту — практически все кнопки в Aqua имеют фиксированную высоту
   */
  function get layoutHeight():Number;

  function get layoutWidth():Number;

  /**
   * View — ability to get some information like enabled
   * w и h can be NaN, in this case x/y = frameInsets.left/top и w/h = bitmap.width/height
   */
  function draw(g:Graphics, w:Number = NaN, h:Number = NaN, x:Number = 0, y:Number = 0, view:View = null):void;
}
}