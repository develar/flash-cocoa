package cocoa.preloaders
{
import flash.display.Sprite;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.ProgressEvent;

import mx.events.FlexEvent;
import mx.events.RSLEvent;
import mx.preloaders.IPreloaderDisplay;

public class AbstractPreloaderView extends Sprite implements IPreloaderDisplay
{
	private static const APP_TOTAL_PART:Number = 83;
	private static const RSL_TOTAL_PART:Number = 15;
	private static const INIT_TOTAL_PART:Number = 2;

	private static const INIT_PROGRESS_TOTAL:int = 6;

	private var appLoadingFraction:Number = 0;
	private var rslLoadingFractions:Vector.<Number>;
	private var initFraction:Number = 0; // 0-1

	private var initProgressCounter:int = 0;

	private var _stageHeight:Number;
	public function get stageHeight():Number
	{
		return _stageHeight;
	}
	public function set stageHeight(height:Number):void
	{
		_stageHeight = height;
	}

	protected var _stageWidth:Number;
	public function get stageWidth():Number
	{
		return _stageWidth;
	}
	public function set stageWidth(width:Number):void
	{
		_stageWidth = width;
	}
	
	public function set preloader(value:Sprite):void
	{
		value.addEventListener(ProgressEvent.PROGRESS, progressHandler);
		value.addEventListener(RSLEvent.RSL_PROGRESS, rslProgressHandler);
		value.addEventListener(FlexEvent.INIT_PROGRESS, initProgressHandler);
		value.addEventListener(FlexEvent.INIT_COMPLETE, initCompleteHandler);
	}

	public function initialize():void
	{

	}

	private function progressHandler(event:ProgressEvent):void
	{
		appLoadingFraction = event.bytesLoaded / event.bytesTotal;
		updateTotalFraction();
	}

	private function rslProgressHandler(event:RSLEvent):void
	{
		if (rslLoadingFractions == null)
		{
			rslLoadingFractions = new Vector.<Number>(event.rslTotal, true);
		}
		else
		{
			//  проверяем корректность работы flex preloader
			assert(rslLoadingFractions.length == event.rslTotal);
		}

		rslLoadingFractions[event.rslIndex] = event.bytesLoaded / event.bytesTotal;
		updateTotalFraction();
	}

	private function initProgressHandler(event:Event):void
	{
		initProgressCounter++;

		initFraction = initProgressCounter / INIT_PROGRESS_TOTAL;
		updateTotalFraction();
	}

	private function initCompleteHandler(event:Event):void
	{
		dispatchEvent(new Event(Event.COMPLETE));
	}

	private function updateTotalFraction():void
	{
		var rslLoadingFraction:Number = 0;
		if (rslLoadingFractions != null)
		{
			const n:int = rslLoadingFractions.length;
			var rslTotal:Number = RSL_TOTAL_PART / n;
			for (var i:int = 0; i < n; i++)
			{
				rslLoadingFraction += rslLoadingFractions[i]  * rslTotal;
			}
		}

		update((appLoadingFraction * APP_TOTAL_PART) + rslLoadingFraction + (initFraction * INIT_TOTAL_PART));
	}

	[Abstract]
	protected function update(progress:Number):void
	{
		throw new IllegalOperationError();
	}

	// stupid flex methods
	public function get backgroundAlpha():Number
	{
		return 1;
	}
	public function set backgroundAlpha(alpha:Number):void
	{
	}

	public function get backgroundColor():uint
	{
		return 0;
	}
	public function set backgroundColor(color:uint):void
	{
	}

		public function get backgroundImage():Object
	{
		return null;
	}
	public function set backgroundImage(image:Object):void
	{
	}

	public function get backgroundSize():String
	{
		return null;
	}
	public function set backgroundSize(size:String):void
	{
	}
}
}