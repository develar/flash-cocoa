package cocoa.preloaders
{
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;
import flash.filters.DropShadowFilter;
import flash.utils.Timer;

import mx.events.FlexEvent;
import mx.events.RSLEvent;
import mx.preloaders.IPreloaderDisplay;

[Abstract]
public class Preloader extends Shape implements IPreloaderDisplay
{
	private var splash:DisplayObject;
	private var fadeOutRate:Number = 0.01;

	private var isInitComplete:Boolean = false;
	private var fractionLoaded:Number = 0;   // 0-1

	private var rslNumber:int = 1; // number of RSLs to download (1 to avoid division by zero)

	private var isInitStarted:Boolean = false;
	private var isRSLLoadingStarted:Boolean = false;

	private var swfLoadingFraction:Number = 0;
	private var rslLoadingFractions:Vector.<Number> = new Vector.<Number>();
	private var initFraction:Number = 0;

	private var totalInitCount:int = 6;
	private var initProgressCounter:int = 0;

	public function Preloader()
	{
		super();

		addEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
	}

	protected function get assetClass():Class
	{
		throw new IllegalOperationError();
	}

	// This function is called whenever the state of the preloader changes.
	// Use the _fractionLoaded variable to draw your progress bar.
	private function draw():void
	{
		splash.alpha = !isInitComplete ? fractionLoaded : 1;
	}

	private function setTotalFraction():void
	{
		var rslLoadingFraction:Number = 0;
		if (rslLoadingFractions.length > 0)
		{
			const n:int = rslLoadingFractions.length;
			for (var i:int = 0; i < n; i++)
			{
				rslLoadingFraction += rslLoadingFractions[i] / rslNumber;
			}
		}
		fractionLoaded = 0.3 * swfLoadingFraction + 0.3 * rslLoadingFraction + 0.4 * initFraction;

		//trace("total: " + fractionLoaded + " = swf: " + swfLoadingFraction + " + rsl: " + rslLoadingFraction + " + init: " + initFraction);
	}

	public function initialize():void
	{
		createAssets();

		var timer:Timer = new Timer(1);
		timer.addEventListener(TimerEvent.TIMER, timerHandler);
		timer.start();
	}

	private function createAssets():void
	{
		splash = new assetClass();

		splash.x = stageWidth / 2 - splash.width / 2;
		splash.y = stageHeight / 2 - splash.height / 2;
		splash.filters = [new DropShadowFilter(2, 45, 0x000000, 0.5)];
		splash.alpha = 0;
		stage.addChild(splash);
	}

	private var _preloader:Sprite;
	/**
	 *  The Preloader class passes in a reference to itself to the display class
	 *  so that it can listen for events from the preloader.
	 */
	public function set preloader(value:Sprite):void
	{
		_preloader = value;

		value.addEventListener(ProgressEvent.PROGRESS, progressHandler);

		value.addEventListener(RSLEvent.RSL_PROGRESS, rslProgressHandler);

		value.addEventListener(FlexEvent.INIT_PROGRESS, initProgressHandler);
		value.addEventListener(FlexEvent.INIT_COMPLETE, initCompleteHandler);
	}

	public function get backgroundAlpha():Number
	{
		return 1;
	}
	public function set backgroundAlpha(alpha:Number):void
	{
	}

	private var _backgroundColor:uint = 0xffffffff;
	public function get backgroundColor():uint
	{
		return _backgroundColor;
	}
	public function set backgroundColor(color:uint):void
	{
		_backgroundColor = color;
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
		return "auto";
	}
	public function set backgroundSize(size:String):void
	{
	}

	private var _stageHeight:Number = 300;
	public function get stageHeight():Number
	{
		return _stageHeight;
	}
	public function set stageHeight(height:Number):void
	{
		_stageHeight = height;
	}

	protected var _stageWidth:Number = 400;
	public function get stageWidth():Number
	{
		return _stageWidth;
	}
	public function set stageWidth(width:Number):void
	{
		_stageWidth = width;
	}

	private function progressHandler(event:ProgressEvent):void
	{
		isInitStarted = true;
		swfLoadingFraction = event.bytesLoaded / event.bytesTotal;
		setTotalFraction();

		draw();
	}

	private function rslProgressHandler(event:RSLEvent):void
	{
		isRSLLoadingStarted = true;
		rslNumber = event.rslTotal;

		if (event)
		{
			rslLoadingFractions[event.rslIndex] = event.bytesLoaded / event.bytesTotal;
			setTotalFraction();
		}
	}

	private function initProgressHandler(event:Event):void
	{
		isInitStarted = true;
		initProgressCounter++;

		initFraction = initProgressCounter / totalInitCount;
		setTotalFraction();
		draw();
	}

	private function initCompleteHandler(event:Event):void
	{
		isInitComplete = true;
	}

	private function timerHandler(event:Event):void
	{
		if (!isInitComplete)
		{
			draw();
		}
		else
		{
			var timer:Timer = Timer(event.currentTarget);
			timer.removeEventListener(TimerEvent.TIMER, timerHandler);
			timer.stop();
			draw();
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}

	private function alphaTimerHandler(event:TimerEvent):void
	{
		if (splash.alpha > 0)
		{
			splash.alpha -= fadeOutRate;
			if (splash.alpha < 0)
			{
				splash.alpha = 0;
			}
		}
		else
		{
			var fadeOutTimer:Timer = Timer(event.currentTarget);
			fadeOutTimer.stop();
			fadeOutTimer.removeEventListener(TimerEvent.TIMER, alphaTimerHandler);
			splash.parent.removeChild(splash);
		}
	}

	private function removeHandler(event:Event):void
	{
		removeEventListener(Event.REMOVED_FROM_STAGE, removeHandler);

		splash.alpha = 1;
		var fadeOutTimer:Timer = new Timer(1);
		fadeOutTimer.addEventListener(TimerEvent.TIMER, alphaTimerHandler);
		fadeOutTimer.start();
	}
}
}