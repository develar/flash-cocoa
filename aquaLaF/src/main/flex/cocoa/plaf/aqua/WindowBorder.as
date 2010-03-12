package cocoa.plaf.aqua
{
import cocoa.AbstractBorder;
import cocoa.Insets;

import flash.display.Graphics;

import mx.core.UIComponent;

public class WindowBorder extends AbstractBorder
{
	[Embed(source="/titleBar-shadow.png")]
	private static var titleBarClass:Class;
	private static const titleSlicedImage:SlicedImage = new SlicedImage();
	titleSlicedImage.slice2(titleBarClass, null, NaN, new Insets(58, 0, 58, 0));
	titleBarClass = null;

	[Embed(source="/body-shadow.png")]
	private static var bodyClass:Class;
	private static const bodySlicedImage:SlicedImage = new SlicedImage();
	bodySlicedImage.slice2(bodyClass, null, NaN, new Insets(58, 0, 58, 0));
	bodyClass = null;

	[Embed(source="/bottomBar-shadow.png")]
	private static var bottomBarClass:Class;
	private static const bottomBarSlicedImage:SlicedImage = new SlicedImage();
	bottomBarSlicedImage.slice2(bottomBarClass, null, NaN, new Insets(58, 0, 58, 0));
	bottomBarClass = null;

	override public function draw(object:UIComponent, g:Graphics, w:Number, h:Number):void
	{
		titleSlicedImage.draw(g, w, 0, -33, -33, -18);
		bodySlicedImage.draw(g, w, 0, -33, -33, 41, h - 41 - 47);
		bottomBarSlicedImage.draw(g, w, 0, -33, -33, h - 47);
	}
}
}