package cocoa.dialog
{
import mx.core.IFactory;

import org.flyti.view;
import cocoa.View;

use namespace view;

public class Wizard extends Dialog
{
	protected var steps:Vector.<IFactory>;

	override view function contentGroupAdded():void
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