package cocoa
{
import mx.core.IDeferredContentOwner;
import mx.styles.IStyleManager2;

public interface Application extends ViewContainer, IDeferredContentOwner
{
	 function get styleManager():IStyleManager2;
}
}