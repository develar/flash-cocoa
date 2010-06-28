package cocoa.message
{
import cocoa.Application;
import cocoa.Component;
import cocoa.plaf.LookAndFeelProvider;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.utils.Timer;

import mx.core.FlexGlobals;
import mx.core.IFlexDisplayObject;
import mx.events.ResizeEvent;
import mx.managers.PopUpManager;

public class MessageExistenceManager
{
	protected var timer:Timer;
	protected var timerToShow:Timer;

	protected var kind:MessageKind;

	public function MessageExistenceManager(messageKind:MessageKind):void
	{
		this.kind = messageKind;
	}

	public function get underMouse():Boolean
	{
		var messageView:IFlexDisplayObject = getMessageView();
		if (messageView.parent == null)
		{
			return false;
		}
		else
		{
			//var mousePoint:Point = kind.message.localToGlobal(new Point(kind.message.mouseX, kind.message.mouseY));
			var rectangle:Rectangle = messageView.getBounds(DisplayObject(kind.message));
			return rectangle.contains(messageView.mouseX, messageView.mouseY);
		}
	}

	public function show():void
	{
		if (kind.target == null || kind.showDelay == 0)
		{
			immediateShow();
		}
		else
		{
			timerToShow = new Timer(kind.showDelay, 1);
			timerToShow.addEventListener(TimerEvent.TIMER, handleTimerToShow);
			kind.target.addEventListener(MouseEvent.ROLL_OUT, handleMouseRollOutBeforeToShow);
			timerToShow.start();
		}
	}

	protected function handleTimerToShow(event:TimerEvent):void
	{
		timerToShow.removeEventListener(TimerEvent.TIMER, handleTimerToShow);
		timerToShow = null;

		kind.target.removeEventListener(MouseEvent.ROLL_OUT, handleMouseRollOutBeforeToShow);

		immediateShow();
	}

	protected function handleMouseRollOutBeforeToShow(event:MouseEvent = null):void
	{
		timerToShow.stop();
		timerToShow = null;
		kind.target.removeEventListener(MouseEvent.ROLL_OUT, handleMouseRollOutBeforeToShow);
		MessageManager.instance.unregisterExistenceManager(kind.id, this);
	}

	private function getMessageView():IFlexDisplayObject
	{
		if (kind.message is Component)
		{
			var component:Component = Component(kind.message);
			return component.skin == null ? component.createView(LookAndFeelProvider(FlexGlobals.topLevelApplication).laf) : component.skin;
		}
		else
		{
			return IFlexDisplayObject(kind.message);
		}
	}

	protected function immediateShow():void
	{
		var messageView:IFlexDisplayObject = getMessageView();
		messageView.addEventListener(MouseEvent.ROLL_OVER, handleMouseRollOver);
		messageView.addEventListener(MouseEvent.ROLL_OUT, handleMouseRollOutMessage);

		messageView.addEventListener(ResizeEvent.RESIZE, handleResize);
		messageView.addEventListener(Event.CLOSE, hide);

		if (kind.parent == null)
		{
			PopUpManager.addPopUp(messageView, DisplayObject(FlexGlobals.topLevelApplication));
		}
		else
		{
			kind.parent.addChild(DisplayObject(messageView));
		}

		positionMessage();

		if (kind.target == null)
		{
			startTimer(kind.showTime);
		}
		else
		{
			kind.target.addEventListener(MouseEvent.ROLL_OVER, handleMouseRollOver);
			kind.target.addEventListener(MouseEvent.ROLL_OUT, handleMouseRollOutTarget);
		}
	}

	protected function positionMessage():void
	{
		if (kind.positioner == null)
		{
			kind.position == MessagePosition.MOUSE_CURSOR ? positionAtMouseCursor() : positionAtApplicationBottomRightCorner();
		}
		else
		{
			kind.positioner();
		}
	}

	protected function positionAtMouseCursor():void
	{
		var application:Application = Application(FlexGlobals.topLevelApplication);
		// Position the upper-left of the message at the lower-right of the arrow cursor
		var x:Number = application.mouseX + 11;
		var y:Number = application.mouseY + 22;

		var messageView:IFlexDisplayObject = getMessageView();
		// If is too wide to fit onstage, move it left
		if ((x + messageView.width) > application.screen.width)
		{
			x = application.screen.width - messageView.width;
		}

		// If the tooltip is too tall to fit onstage, move it up
		if (y + messageView.height > application.screen.height)
		{
			y = application.screen.height - messageView.height;
		}

		messageView.move(x, y);
	}

	protected function positionAtApplicationBottomRightCorner():void
	{
		var messageView:IFlexDisplayObject = getMessageView();
		var application:Application = Application(FlexGlobals.topLevelApplication);
		messageView.move(application.width - messageView.width - 5, application.height - messageView.height - 5);
	}

	public function hide(event:Event = null):void
	{
		if (timerToShow != null)
		{
			handleMouseRollOutBeforeToShow();
		}

		var messsageView:IFlexDisplayObject = getMessageView();
		if (kind.parent == null)
		{
			PopUpManager.removePopUp(messsageView)
		}
		else if (messsageView.parent != null)
		{
			kind.parent.removeChild(DisplayObject(messsageView));
		}

		messsageView.removeEventListener(MouseEvent.ROLL_OUT, handleMouseRollOutMessage);
		messsageView.removeEventListener(MouseEvent.ROLL_OVER, handleMouseRollOver);

		messsageView.removeEventListener(ResizeEvent.RESIZE, handleResize);
		messsageView.removeEventListener(Event.CLOSE, hide);

		if (kind.target != null)
		{
			kind.target.removeEventListener(MouseEvent.ROLL_OVER, handleMouseRollOver);
			kind.target.removeEventListener(MouseEvent.ROLL_OUT, handleMouseRollOutTarget);
		}

		MessageManager.instance.unregisterExistenceManager(kind.id, this);
	}

	protected function handleResize(event:ResizeEvent):void
	{
		positionMessage();
	}

	protected function startTimer(delay:uint):void
	{
		timer = new Timer(delay, 1);
		timer.addEventListener(TimerEvent.TIMER, hide);
		timer.start();
	}

	protected function handleMouseRollOutMessage(event:MouseEvent):void
	{
		// ignore open context menu
		if (!(event.stageX == -1 && event.stageY == -1))
		{
			startTimer(kind.returnTime);
		}
	}

	protected function handleMouseRollOutTarget(event:MouseEvent):void
	{
		if (!underMouse)
		{
			startTimer(kind.returnTime);
		}
	}

	protected function handleMouseRollOver(event:MouseEvent):void
	{
		if (timer != null)
		{
			timer.reset();
		}
	}
}
}