package cocoa.plaf
{
import cocoa.FrameInsets;
import cocoa.Insets;

import flash.display.BitmapData;
import flash.utils.ByteArray;

internal class AbstractScale3BitmapBorder extends AbstractControlBitmapBorder
{
	/**
	 * Фиксированное значение ширины/высоты каждого кусочка (в зависимости от ориентации — h: height, v: width)
	 */
	protected var size:Number;
	protected var lastSize:Number;

	protected function get serialTypeId():int
	{
		throw new Error("Abstract");
	}

	protected function init(frameInsets:FrameInsets, contentInsets:Insets = null):void
	{
		if (_frameInsets != null)
		{
			_frameInsets = frameInsets;
		}
		if (contentInsets != null)
		{
			_contentInsets = contentInsets;
		}
	}

	public function configure(bitmaps:Vector.<BitmapData>):AbstractScale3BitmapBorder
	{
		this.bitmaps = bitmaps;
		initTransient();
		return this;
	}

	protected function initTransient():void
	{
		throw new Error("Abstract");
	}

	override public function readExternal(input:ByteArray):void
	{
		super.readExternal(input);

		lazyReadFrameInsets(input);
		initTransient();
	}

	override public function writeExternal(output:ByteArray):void
	{
		output.writeByte(serialTypeId);
		super.writeExternal(output);

		lazyWriteFrameInsets(output);
	}
}
}