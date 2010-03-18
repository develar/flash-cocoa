package cocoa
{
import flash.display.Graphics;

/**
 * Терминология frame/layout взята из Cocoa.
 * У объекта два rect — frame и layout. примерно то же самое, что и DisplayObject.getBounds() и DisplayObject.getRect()
 * frame rect включает в себя весь контент объекта + весь хром, который может отрисовываться вне (0, 0, w, h)
 * layout rect это только размер объекта без хрома.
 */
public interface Border
{
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

	/**
	 * View для добавления детей
	 */
	function draw(view:View, g:Graphics, w:Number, h:Number):void;
}
}