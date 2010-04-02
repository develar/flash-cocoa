package cocoa.plaf
{
import cocoa.FrameInsets;
import cocoa.Insets;

import flash.utils.ByteArray;

internal class AbstractScale3BitmapBorder extends AbstractControlBitmapBorder
{
	/**
	 * Фиксированное значение ширины/высоты каждого кусочка (в зависимости от ориентации — h: height, v: width)
	 */
	protected var size:Number;
	protected var lastSize:Number;

	protected function init(frameInsets:FrameInsets, contentInsets:Insets = null):void
	{
		_frameInsets = frameInsets;
		if (contentInsets != null)
		{
			_contentInsets = contentInsets;
		}
	}

	override public function readExternal(input:ByteArray):void
	{
		super.readExternal(input);

		_frameInsets = readFrameInsets(input);
	}

	override public function writeExternal(output:ByteArray):void
	{
		output.writeByte(0);
		super.writeExternal(output);

		writeFrameInsets(output);
	}
}
}