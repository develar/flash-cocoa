package cocoa
{
import cocoa.plaf.LookAndFeelProvider;

import flash.geom.Rectangle;

import mx.core.IDeferredContentOwner;

public interface Application extends ViewContainer, IDeferredContentOwner, LookAndFeelProvider
{
	function get screen():Rectangle;
}
}