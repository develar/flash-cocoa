package cocoa
{
import flash.utils.Dictionary;

import mx.core.IVisualElement;
import mx.events.PropertyChangeEvent;
import mx.utils.OnDemandEventDispatcher;

import org.flyti.view;

use namespace ui;

public class ViewBase extends OnDemandEventDispatcher
{
	protected static const HANDLER_NOT_EXISTS:int = 2;

	protected const skinParts:Dictionary = new Dictionary();

	private var untypedSkin:SimpleSkin;

	/**
	 * @todo Подумать о том, чтобы сделать partAdded публичным или же в неком namespace типа view
	 */
	public function skinPartAdded(id:String, instance:Object):void
	{
		partAdded(id, instance);
	}

	protected function listenSkinParts(skin:SimpleSkin):void
	{
		untypedSkin = skin;
		skin.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, skinPropertyChangeHandler);

		if (!(skin is SkinPartProvider))
		{
			// PROPERTY_CHANGE вешается поздно, и некоторые skin part устанавливаются в конструкторе
			for (var skinPartId:String in skinParts)
			{
				var instance:Object = skin[skinPartId];
				if (instance != null && this[skinPartId] == null)
				{
					partAdded(skinPartId, instance);
				}
			}
		}
	}

	protected function invalidateProperties():void
    {
		if (untypedSkin != null)
		{
        	untypedSkin.invalidateProperties();
		}
    }

	protected function skinPropertyChangeHandler(event:PropertyChangeEvent):void
	{
		var skinPartId:String = String(event.property);
		if (skinPartId in skinParts)
		{
			partAdded(skinPartId, event.newValue);
		}
	}

	protected function partAdded(id:String, instance:Object):void
	{
		this[id] = instance;
		const handlerName:String = id + "Added";
		if (!((skinParts[id] as int) & HANDLER_NOT_EXISTS))
		{
			this[handlerName]();
		}
	}

	public function get hidden():Boolean
	{
		return !IVisualElement(untypedSkin).visible && !IVisualElement(untypedSkin).includeInLayout;
	}
	public function set hidden(value:Boolean):void
	{
		IVisualElement(untypedSkin).visible = !value;
		IVisualElement(untypedSkin).includeInLayout = !value;
	}
}
}