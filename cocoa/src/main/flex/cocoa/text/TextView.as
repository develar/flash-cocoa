package cocoa.text
{
import cocoa.AbstractView;

import flash.display.Sprite;

import flash.geom.Rectangle;

import flashx.textLayout.container.ContainerController;
import flashx.textLayout.edit.SelectionManager;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.CompositionCompleteEvent;

import spark.core.IViewport;
import spark.core.NavigationUnit;

/**
 * Not editable text view, only display
 */
public class TextView extends AbstractView implements IViewport
{
	private var container:Sprite;
	private var containerController:ContainerController;

	private var _textFlow:TextFlow;
	public function get textFlow():TextFlow
	{
		return _textFlow;
	}

	public function set textFlow(value:TextFlow):void
	{
		if (_textFlow != value)
		{
			if (_textFlow != null)
			{
				_textFlow.removeEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, textFlowCompositionCompleteHandler);
				if (_textFlow.flowComposer != null)
				{
					_textFlow.flowComposer.removeAllControllers();
				}
			}
			_textFlow = value;
			//add controller immediately to mark that textFlow already in use
			if (_textFlow != null)
			{
				_textFlow.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, textFlowCompositionCompleteHandler);
				if (containerController == null)
				{
					createController();
				}
				_textFlow.flowComposer.addController(containerController);
				if (_textFlow.interactionManager == null)
				{
					_textFlow.interactionManager = new SelectionManager();
				}
			}
			invalidateProperties();
			invalidateDisplayList();
		}
	}

	private function createController():void
	{
		container = new Sprite;
		addDisplayObject(container);
		containerController = new ContainerController(container, 0, 0);
	}

	private function textFlowCompositionCompleteHandler(event:CompositionCompleteEvent):void
	{
		var oldContentWidth:Number = _contentWidth;
		var oldContentHeight:Number = _contentHeight;

		var newContentBounds:Rectangle =
				containerController.getContentBounds();

		var newContentWidth:Number = newContentBounds.width;
		var newContentHeight:Number = newContentBounds.height;

		if (newContentWidth != oldContentWidth)
		{
			_contentWidth = newContentWidth;

			//trace("composeWidth", containerController.compositionWidth, "contentWidth", oldContentWidth, newContentWidth);

			// If there is a scroller, this triggers the scroller layout.
			dispatchPropertyChangeEvent("contentWidth", oldContentWidth, newContentWidth);
		}

		if (newContentHeight != oldContentHeight)
		{
			_contentHeight = newContentHeight;
			//trace("composeHeight", containerController.compositionHeight, "contentHeight", oldContentHeight, newContentHeight);

			// If there is a scroller, this triggers the scroller layout.
			dispatchPropertyChangeEvent("contentHeight", oldContentHeight, newContentHeight);
		}
	}

	override protected function commitProperties():void
	{
		super.commitProperties();

		if (containerController == null)
		{
			createController();
		}
		if (clipAndEnableScrollingChanged)
		{
			// The TLF code seems to check for !off.
			containerController.horizontalScrollPolicy = "auto";
			containerController.verticalScrollPolicy = "auto";

			clipAndEnableScrollingChanged = false;
		}

		if (horizontalScrollPositionChanged)
		{
			var oldHorizontalScrollPosition:Number = containerController.horizontalScrollPosition;
			containerController.horizontalScrollPosition = _horizontalScrollPosition;

			dispatchPropertyChangeEvent("horizontalScrollPosition",
					oldHorizontalScrollPosition, _horizontalScrollPosition);

			horizontalScrollPositionChanged = false;
		}

		if (verticalScrollPositionChanged)
		{
			var oldVerticalScrollPosition:Number = containerController.verticalScrollPosition;
			containerController.verticalScrollPosition = _verticalScrollPosition;

			dispatchPropertyChangeEvent("verticalScrollPosition",
					oldVerticalScrollPosition, _verticalScrollPosition);

			verticalScrollPositionChanged = false;
		}
	}

	override protected function measure():void
	{
		super.measure();

		if (!isNaN(explicitWidth))
		{
			measuredWidth = explicitWidth;
		}
		else if (_textFlow != null)
		{
			measuredWidth = containerController.compositionWidth;
		}

		if (!isNaN(explicitHeight))
		{
			measuredHeight = explicitHeight;
		}
		else if (_textFlow != null)
		{
			measuredHeight = containerController.compositionHeight;
		}
	}


	override protected function updateDisplayList(w:Number, h:Number):void
	{
		if (_textFlow != null)
		{
			containerController.setCompositionSize(w, h);
			textFlow.flowComposer.updateToController();
		}

	}

	private var _contentWidth:Number = 0;
	[Bindable("propertyChange")]
	public function get contentWidth():Number
	{
		return _contentWidth;
	}

	private var _contentHeight:Number = 0;
	[Bindable("propertyChange")]
	public function get contentHeight():Number
	{
		return _contentHeight;
	}

	private var _horizontalScrollPosition:Number = 0;
	private var horizontalScrollPositionChanged:Boolean = false;

	[Bindable("propertyChange")]
	public function get horizontalScrollPosition():Number
	{
		return _horizontalScrollPosition;
	}

	public function set horizontalScrollPosition(value:Number):void
	{
		if (_horizontalScrollPosition != value)
		{
			_horizontalScrollPosition = value;
			horizontalScrollPositionChanged = true;

			invalidateProperties();
		}
		// Note:  TLF takes care of updating the container when the scroll
		// position is set so there is no need for us to invalidate the
		// display list.
	}

	private var _verticalScrollPosition:Number = 0;
	private var verticalScrollPositionChanged:Boolean = false;

	[Bindable("propertyChange")]
	public function get verticalScrollPosition():Number
	{
		return _verticalScrollPosition;
	}

	public function set verticalScrollPosition(value:Number):void
	{
		if (_verticalScrollPosition != value)
		{
			_verticalScrollPosition = value;
			verticalScrollPositionChanged = true;

			invalidateProperties();
		}
		// Note:  TLF takes care of updating the container when the scroll
		// position is set so there is no need for us to invalidate the
		// display list.
	}


	public function getHorizontalScrollPositionDelta(navigationUnit:uint):Number
	{
		/*var scrollR:Rectangle = scrollRect;
		 if (!scrollR)
		 return 0;

		 // maxDelta is the horizontalScrollPosition delta required
		 // to scroll to the RIGHT and minDelta scrolls to LEFT.
		 var maxDelta:Number = contentWidth - scrollR.right;
		 var minDelta:Number = -scrollR.left;

		 // Scroll by a "character" which is 1 em (matches widthInChars()).
		 var em:Number = getStyle("fontSize");

		 switch (navigationUnit)
		 {
		 case NavigationUnit.LEFT:
		 return (scrollR.left <= 0) ? 0 : Math.max(minDelta, -em);

		 case NavigationUnit.RIGHT:
		 return (scrollR.right >= contentWidth) ? 0 : Math.min(maxDelta, em);

		 case NavigationUnit.PAGE_LEFT:
		 return Math.max(minDelta, -scrollR.width);

		 case NavigationUnit.PAGE_RIGHT:
		 return Math.min(maxDelta, scrollR.width);

		 case NavigationUnit.HOME:
		 return minDelta;

		 case NavigationUnit.END:
		 return maxDelta;

		 default:
		 return 0;
		 }*/
		return 0;
	}

	public function getVerticalScrollPositionDelta(navigationUnit:uint):Number
	{
		var scrollR:Rectangle = scrollRect;
		if (!scrollR)
			return 0;

		// maxDelta is the horizontalScrollPosition delta required
		// to scroll to the END and minDelta scrolls to HOME.
		var maxDelta:Number = contentHeight - scrollR.bottom;
		var minDelta:Number = -scrollR.top;

		switch (navigationUnit)
		{
			case NavigationUnit.UP:
				return containerController.getScrollDelta(-1);

			case NavigationUnit.DOWN:
				return containerController.getScrollDelta(1);

			case NavigationUnit.PAGE_UP:
				return Math.max(minDelta, -scrollR.height);

			case NavigationUnit.PAGE_DOWN:
				return Math.min(maxDelta, scrollR.height);

			case NavigationUnit.HOME:
				return minDelta;

			case NavigationUnit.END:
				return maxDelta;

			default:
				return 0;
		}
	}

	private var _clipAndEnableScrolling:Boolean = false;
	private var clipAndEnableScrollingChanged:Boolean = false;

	public function get clipAndEnableScrolling():Boolean
	{
		return _clipAndEnableScrolling;
	}

	public function set clipAndEnableScrolling(value:Boolean):void
	{
		if (_clipAndEnableScrolling != value)
		{
			_clipAndEnableScrolling = value;
			clipAndEnableScrollingChanged = true;
			invalidateProperties();
		}
	}
}
}