/**
 * Created by IntelliJ IDEA.
 * User: develar
 * Date: Jul 29, 2010
 * Time: 8:22:37 PM
 * To change this template use File | Settings | File Templates.
 */
package cocoa.text
{
import flash.display.Sprite;

import flashx.textLayout.container.ContainerController;

public class ContainerController extends flashx.textLayout.container.ContainerController implements ScrollController
{
	public function ContainerController(container:Sprite, compositionWidth:Number = 100, compositionHeight:Number = 100)
	{
		super(container, compositionWidth, compositionHeight);
	}
}
}