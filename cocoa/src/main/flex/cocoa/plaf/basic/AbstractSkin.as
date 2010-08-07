package cocoa.plaf.basic
{
import cocoa.AbstractView;
import cocoa.Border;
import cocoa.Component;
import cocoa.Icon;
import cocoa.UIPartProvider;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;

import com.asfusion.mate.events.InjectorEvent;

import flash.geom.Point;

import flashx.textLayout.formats.ITextLayoutFormat;

import mx.core.IFactory;

import org.flyti.plexus.Injectable;

/**
 * Default base skin implementation for view
 */
public class AbstractSkin extends AbstractView implements Skin, UIPartProvider
{
	private static var sharedPoint:Point;

	protected var laf:LookAndFeel;

	private var _component:Component;
	public function get component():Component
	{
		return _component;
	}

	protected final function getTextLayoutFormat(key:String):ITextLayoutFormat
	{
		return laf.getTextLayoutFormat(_component.lafKey + "." + key);
	}

	protected final function getBorder(key:String):Border
	{
		return laf.getBorder(_component.lafKey + "." + key);
	}

	protected final function getIcon(key:String):Icon
	{
		return laf.getIcon(_component.lafKey + "." + key);
	}

	protected final function getFactory(key:String):IFactory
	{
		return laf.getFactory(_component.lafKey + "." + key);
	}

	public function attach(component:Component, laf:LookAndFeel):void
	{
		_component = component;
		this.laf = laf;
	}

	override protected function createChildren():void
	{
		// Скин, в отличии от других элементов, также может содержать local event map — а контейнер с инжекторами мы находим посредством баблинга,
		// поэтому отослать InjectorEvent мы должны от самого скина и только после того, как он будет добавлен в display list.
		if (_component is Injectable)
		{
			dispatchEvent(new InjectorEvent(_component));
		}
	}

	override protected function commitProperties():void
	{
		component.commitProperties();
		super.commitProperties();
	}

	override public function hitTestPoint(x:Number, y:Number, shapeFlag:Boolean = false):Boolean
	{
		if (shapeFlag)
		{
			return super.hitTestPoint(x, y, shapeFlag);
		}
		else
		{
			if (sharedPoint == null)
			{
				sharedPoint = new Point(x, y);
			}
			else
			{
				sharedPoint.x = x;
				sharedPoint.y = y;
			}

			var local:Point = globalToLocal(sharedPoint);
			return local.x >= 0 && local.y >= 0 && local.x <= width && local.y <= height;
		}
	}
}
}