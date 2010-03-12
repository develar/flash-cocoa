package cocoa
{
import cocoa.keyboard.KeyboardManagerClient;
import cocoa.keyboard.KeyboardManagerClientHelper;

import spark.components.Button;
import spark.primitives.BitmapImage;

/**
 * Как ставить иконки? Мы не стали изобретать велосипед с icon factory, а используем стили.
 * Используя FQN, вы в CSS прописываете все нужные вам иконки в формате
 * fluent|Button { textIcon: Embed("/icons/large/insert/text.png"); iconName2: Embed("icon.png"); }
 * где textIcon есть стиль данного компонента iconName. Таким образом для получения Fluent Large Icon вы используете следующий код:
 * <fluent:Button label="text" styleName="large" iconName="textIcon"/>
 */

[Style(name="iconName", type="String")]
[Style(name="icon", type="Class")]
public class Button extends spark.components.Button implements KeyboardManagerClient
{
	[SkinPart(required="false")]
	public var bitmapImage:BitmapImage;

	private var iconNameChanged:Boolean = false;
	private var iconChanged:Boolean = false;

	private var shortcutHelper:KeyboardManagerClientHelper;

	private var prevButtonMode:Boolean = false;

	public function Button()
	{
		shortcutHelper = new KeyboardManagerClientHelper(this);

		super();
	}

	public function set shortcut(value:String):void
	{
		shortcutHelper.shortcut = value;
	}

	override public function set toolTip(value:String):void
	{
		super.toolTip = shortcutHelper.adjustRawToolTip(value);
	}

	override public function styleChanged(styleProp:String):void
	{
		super.styleChanged(styleProp);

		if (!styleProp || styleProp == "iconName")
		{
			iconNameChanged = true;
			invalidateProperties();
		}
		if (!styleProp || styleProp == "icon")
		{
			iconChanged = true;
			invalidateProperties();
		}
	}

	override protected function commitProperties():void
	{
		super.commitProperties();

		if (bitmapImage != null)
		{
			var iconNameApplied:Boolean = false;
			if (iconNameChanged)
			{
				iconNameChanged = false;
				if (getStyle("iconName") != undefined)
				{
					bitmapImage.source = getStyle(getStyle("iconName"));
					iconNameApplied = true;
				}
			}
			if (iconChanged)
			{
				iconChanged = false;
				if (!iconNameApplied)
				{
					bitmapImage.source = getStyle("icon");
				}
			}
		}
	}

	override public function set enabled(value:Boolean):void
    {
		if (value != enabled)
		{
			super.enabled = value;
			
			if (value)
			{
				if (prevButtonMode)
				{
					prevButtonMode = false;
					buttonMode = true;
				}
			}
			else if (buttonMode)
			{
				prevButtonMode = true;
				buttonMode = false;
			}
		}
	}
}
}