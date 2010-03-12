package cocoa
{
import mx.managers.DragManager;

[Frame(factoryClass='org.flyti.managers.SystemManager')]
public class WindowedApplication extends ApplicationImpl
{
	public function WindowedApplication()
	{
		super();

//        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
//        addEventListener(FlexEvent.PREINITIALIZE, preinitializeHandler);
//        addEventListener(FlexEvent.UPDATE_COMPLETE, updateComplete_handler);
//        addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
//
//        var nativeApplication:NativeApplication = NativeApplication.nativeApplication;
//        nativeApplication.addEventListener(Event.ACTIVATE, nativeApplication_activateHandler);
//        nativeApplication.addEventListener(Event.DEACTIVATE, nativeApplication_deactivateHandler);
//        nativeApplication.addEventListener(Event.NETWORK_CHANGE, dispatchEvent);
//
//        nativeApplication.addEventListener(InvokeEvent.INVOKE, nativeApplication_invokeHandler);
//        initialInvokes = new Array();

        //Force DragManager to instantiate so that it can handle drags from
        //outside the app.
		//noinspection BadExpressionStatementJS
		DragManager.isDragging;
	}
}
}