package cocoa.preloaders
{
import flash.display.DisplayObject;
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

/**
 * Загрузка приложения состоит из загрузки основной swf приложения и RSL. При этом RSL не входят в bytesTotal, точный размер загрузки мы знаем только в момент начала загрузки последнего RSL
 * Проблем нет, если у нас несколько индикаторов загрузки — 1 на приложение + на каждый RSL.
 * Но мы клиенту хочется иметь общий, показывающий процесс загрузки в целом индикатор.
 * Поэтому мы из 100% отводим 85 на app и 15 / rslNumber на RSL.
 * Общее количество RSL мы получаем с началом загрузки первого — это нам никак не мешает показывать прогресс загрузки app, так как оно то четко рассчитывается на отведенные ей 85.
 * Таким образом, мы получаем не совсем честный индикатор, зато прогресс всегда будет правдив (без скачков назад).
 */

[Abstract]
public class TranslucentPreloaderView extends Sprite implements IPreloaderDisplay
{
	private static const APP_TOTAL_PART:Number = 83;
	private static const RSL_TOTAL_PART:Number = 15;
	private static const INIT_TOTAL_PART:Number = 2;

	private var splash:DisplayObject;

	private static const FADE_OUT_RATE:Number = 0.01;

	private var fractionLoaded:Number = 0;  // 0-1

	private var appLoadingFraction:Number = 0;
	private var rslLoadingFractions:Vector.<Number>;
	private var initFraction:Number = 0; // 0-1

	private static const INIT_PROGRESS_TOTAL:int = 6;
	private var initProgressCounter:int = 0;

	public function TranslucentPreloaderView()
	{
		super();

		addEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
	}

	protected function get assetClass():Class
	{
		throw new IllegalOperationError();
	}

	public function initialize():void
	{
		splash = new assetClass();

		splash.x = (stageWidth / 2) - (splash.width / 2);
		splash.y = (stageHeight / 2) - (splash.height / 2);
		splash.filters = [new DropShadowFilter(2, 45, 0x000000, 0.5)];
		splash.alpha = 0;
		stage.addChild(splash);
	}

	public function set preloader(value:Sprite):void
	{
		value.addEventListener(ProgressEvent.PROGRESS, progressHandler);
		value.addEventListener(RSLEvent.RSL_PROGRESS, rslProgressHandler);
		value.addEventListener(FlexEvent.INIT_PROGRESS, initProgressHandler);
		value.addEventListener(FlexEvent.INIT_COMPLETE, initCompleteHandler);
	}

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

		fractionLoaded = (appLoadingFraction * APP_TOTAL_PART) + rslLoadingFraction + (initFraction * INIT_TOTAL_PART);

		draw();
	}

	private function draw():void
	{
		splash.alpha = initFraction == 1 ? 1 : (fractionLoaded / 100);
	}

	private function alphaTimerHandler(event:TimerEvent):void
	{
		if (splash.alpha > FADE_OUT_RATE)
		{
			splash.alpha -= FADE_OUT_RATE;
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