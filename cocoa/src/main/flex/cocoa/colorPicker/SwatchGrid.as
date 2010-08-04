package cocoa.colorPicker
{
import flash.display.Graphics;
import flash.display.Shape;

public class SwatchGrid extends Shape
{
    public function drawGrid(list:Vector.<uint>):void
    {
		var g:Graphics = graphics;
		g.clear();

		var columnCount:int = 20 - 1;
        var horizontalGap:Number = 0;
//        var previewWidth:Number = 45;
//        var swatchGridBackgroundColor:uint = 0;
        var swatchHeight:Number = 12;
        var swatchWidth:Number = 12;
//        var textFieldWidth:Number = 72;
        var verticalGap:Number = 0;

		var swatchBorderColor:uint = 0;
		var swatchBorderSize:Number = 1;

        // Adjust for dataProviders that are less than the columnCount.
		var length:int = list.length;
		if (columnCount > length)
		{
			columnCount = length;
		}

		if (swatchBorderSize > 0)
		{
			g.lineStyle(swatchBorderSize, swatchBorderColor);
		}

		const xStep:Number = swatchWidth + horizontalGap;
		const yStep:Number = swatchHeight + verticalGap;

        // Draw the swatches
        var cNum:int = 0;
		var rNum:int = 0;
		for (var n:int = 0; n < length; n++)
        {
			g.beginFill(list[n]);
			g.drawRect(cNum * xStep, rNum * yStep, swatchWidth, swatchHeight);
			g.endFill();

			if (cNum < columnCount)
            {
                cNum++;
            }
            else
            {
                cNum = 0;
                rNum++;
            }
        }
    }
}
}
