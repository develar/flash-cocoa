package cocoa.preloaders
{
import flash.display.DisplayObject;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.filters.DropShadowFilter;
import flash.utils.Timer;

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
public class TranslucentPreloaderView extends AbstractPreloaderView implements IPreloaderDisplay
{
	private var splash:DisplayObject;

	private static const FADE_OUT_RATE:Number = 0.01;

	private var fractionLoaded:Number = 0;  // 0-1

	public function TranslucentPreloaderView()
	{
		super();

		addEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
	}

	protected function get assetClass():Class
	{
		throw new IllegalOperationError();
	}

	override public function initialize():void
	{
		splash = new assetClass();

		splash.x = (stageWidth / 2) - (splash.width / 2);
		splash.y = (stageHeight / 2) - (splash.height / 2);
		splash.filters = [new DropShadowFilter(2, 45, 0x000000, 0.5)];
		splash.alpha = 0;
		stage.addChild(splash);
	}

	override protected function update(progress:Number):void
	{
		splash.alpha = progress / 100;
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
}
}