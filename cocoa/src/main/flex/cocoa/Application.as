package cocoa
{
import cocoa.plaf.LookAndFeelProvider;

import mx.core.IDeferredContentOwner;
import mx.styles.IStyleManager2;

public interface Application extends ViewContainer, IDeferredContentOwner, LookAndFeelProvider
{
	 function get styleManager():IStyleManager2;
}
}