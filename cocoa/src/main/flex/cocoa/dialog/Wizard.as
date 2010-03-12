package cocoa.dialog
{
import mx.core.IFactory;

import org.flyti.view;
import cocoa.View;

use namespace ui;

public class Wizard extends Dialog
{
	protected var steps:Vector.<IFactory>;

	override ui function contentGroupAdded():void
	{
		super.contentGroupAdded();

		contentGroup.addElement(createStep(0));
	}

	protected function createStep(index:int):View
	{
		return steps[index].newInstance();
	}
}
}