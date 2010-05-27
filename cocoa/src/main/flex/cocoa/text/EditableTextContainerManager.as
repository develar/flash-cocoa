package cocoa.text
{
import flash.display.Graphics;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.ui.ContextMenu;

import flashx.textLayout.container.ContainerController;
import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.edit.EditingMode;
import flashx.textLayout.edit.ElementRange;
import flashx.textLayout.edit.IEditManager;
import flashx.textLayout.edit.ISelectionManager;
import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.edit.SelectionManager;
import flashx.textLayout.edit.SelectionState;
import flashx.textLayout.elements.FlowLeafElement;
import flashx.textLayout.elements.IConfiguration;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.SelectionEvent;
import flashx.textLayout.formats.Category;
import flashx.textLayout.formats.ITextLayoutFormat;
import flashx.textLayout.formats.TextLayoutFormat;
import flashx.textLayout.operations.ApplyFormatOperation;
import flashx.textLayout.operations.InsertTextOperation;
import flashx.textLayout.property.Property;
import flashx.textLayout.tlf_internal;
import flashx.undo.IUndoManager;
import flashx.undo.UndoManager;

import mx.core.mx_internal;

use namespace mx_internal;
use namespace tlf_internal;

internal final class EditableTextContainerManager extends TextContainerManager
{
	private var hasScrollRect:Boolean = false;

	private var textDisplay:EditableTextView;

	public function EditableTextContainerManager(container:EditableTextView, configuration:IConfiguration)
    {
        super(container, configuration);

        textDisplay = container;
    }

    /**
     *  TLF doesn't guarantee it won't touch the context menu.  It removes it
     *  when it switches from the factory to the composer so we need to save it.
     */
    private var userContextMenu:ContextMenu;

    override public function drawBackgroundAndSetScrollRect(scrollX:Number, scrollY:Number):Boolean
    {
        // If not auto-sizing these are the same as the compositionWidth/Height.
        // If auto-sizing, the compositionWidth/Height may be NaN.  If no
        // constraints this will reflect the actual size of the text.
        var width:Number = textDisplay.width;
        var height:Number = textDisplay.height;

        var contentBounds:Rectangle = getContentBounds();

        // If measuring width, use the content width.
        if (isNaN(width))
            width = contentBounds.right;

        // If measuring height, use the content height.
        if (isNaN(height))
            height = contentBounds.bottom;

        // TODO:(cframpto)  Adjust for RL text.
        // See ContainerController.updateVisibleRectangle().
        // (effectiveBlockProgression == BlockProgression.RL) ? -width : 0;
        var xOrigin:Number = 0;

        // If autoSize, and lineBreak="toFit" there should never be
        // a scroll rect but if lineBreak="explicit" the text may need
        // to be clipped.
        if (scrollX == 0 && scrollY == 0 &&
            contentBounds.left >= xOrigin &&
            contentBounds.right <= width &&
            contentBounds.top >= 0 &&
            contentBounds.bottom <= height)
        {
            // skip the scrollRect
            if (hasScrollRect)
            {
                container.scrollRect = null;
                hasScrollRect = false;
            }
        }
        else
        {
            container.scrollRect = new Rectangle(scrollX, scrollY, width, height);
            hasScrollRect = true;
        }

        // Client must draw a background to get mouse events,
        // even it if is 100% transparent.
    	// If backgroundColor is defined, fill the bounds of the component
    	// with backgroundColor drawn with alpha level backgroundAlpha.
    	// Otherwise, fill with transparent black.
    	// (The color in this case is irrelevant.)
    	var color:uint = 0x000000;
    	var alpha:Number = 0.0;
        var g:Graphics = container.graphics;
        g.clear();
        g.lineStyle();
        g.beginFill(color, alpha);
        g.drawRect(scrollX, scrollY, width, height);
        g.endFill();

        return hasScrollRect;
    }

    /**
     * If the user specified a custom context menu then save it and use
     * it rather than the default context menu. It must be set before the
     * first mouse over/mouse hover or foucsIn event to be used.
     *
     * TLF will remove the context menu when it switches from the factory
     * to the composer and the controller will then request it again.
     */
    override tlf_internal function getContextMenu():ContextMenu
    {
        // ToDo(cframpto): can't differentiate between the user removing the
        // context menu because they don't want it and TLF removing it and
        // it is requesting it again.  Need additional API to support
        // contextMenus correctly.  Ideally could specify the context
        // menu on the TextArea or the TextInput and it wouldn't be obscured
        // by TLF's context menu.

        if (textDisplay.contextMenu != null)
		{
			userContextMenu = textDisplay.contextMenu;
		}
		else if (userContextMenu == null)
		{
            userContextMenu = super.getContextMenu();
		}

        return userContextMenu;
    }

    override protected function getUndoManager():IUndoManager
    {
        if (!textDisplay.undoManager)
        {
            textDisplay.undoManager = new UndoManager();
            textDisplay.undoManager.undoAndRedoItemLimit = int.MAX_VALUE;
        }

        return textDisplay.undoManager;
	}

    override protected function createEditManager(undoManager:IUndoManager):IEditManager
    {
        return new EditableTextEditManager(textDisplay, undoManager);
    }

    override public function setText(text:String):void
    {
        super.setText(text);

        // If we have focus, need to make sure we can still input text.
        initForInputIfHaveFocus();
    }

    override public function setTextFlow(textFlow:TextFlow):void
    {
        super.setTextFlow(textFlow);

        // If we have focus, need to make sure we can still input text.
        initForInputIfHaveFocus();
    }

    private function initForInputIfHaveFocus():void
    {
        // If we have focus, need to make sure there is a composer in place,
        // the new controller knows it has focus, and there is an insertion
        // point so input works without a mouse over or mouse click.  Normally
        // this is done in our focusIn handler by making sure there is a
        // selection.  Test this by clicking an arrow in the NumericStepper
        // and then entering a number without clicking on the input field first.
        if (editingMode != EditingMode.READ_ONLY &&
            textDisplay.getFocus() == textDisplay)
        {
            // this will ensure a text flow with a comopser
            var im:ISelectionManager = beginInteraction();

            var controller:ContainerController =
                getTextFlow().flowComposer.getControllerAt(0);

            controller.requiredFocusInHandler(null);

            im.selectRange(0, 0);

            endInteraction();
        }
    }

    /**
     *  @private
     *  To apply a format to a selection in a textFlow without using the
     *  selection manager.
     */
    mx_internal function applyFormatOperation(
                            leafFormat:ITextLayoutFormat,
                            paragraphFormat:ITextLayoutFormat,
                            containerFormat:ITextLayoutFormat,
                            anchorPosition:int,
                            activePosition:int):Boolean
    {
        // Nothing to do.
        if (anchorPosition == -1 || activePosition == -1)
            return true;

        var textFlow:TextFlow = getTextFlowWithComposer();

        var operationState:SelectionState =
            new SelectionState(textFlow, anchorPosition, activePosition);

        // On point selection remember pendling formats for next char typed.
        operationState.selectionManagerOperationState = true;

        var op:ApplyFormatOperation =
            new ApplyFormatOperation(
                operationState, leafFormat, paragraphFormat, containerFormat);

        var success:Boolean = op.doOperation();
        if (success)
        {
            textFlow.normalize();
            textFlow.flowComposer.updateAllControllers();
        }

        return success;
    }

    /**
     *  @private
     *  To get the format of a character without using a SelectionManager.
     *  The method should be kept in sync with the version in the
     *  SelectionManager.
     */
    mx_internal function getCommonCharacterFormat(
                                        anchorPosition:int,
                                        activePosition:int):ITextLayoutFormat
    {
        if (anchorPosition == -1 || activePosition == -1)
            return null;

        var textFlow:TextFlow = getTextFlowWithComposer();

        var absoluteStart:int = getAbsoluteStart(anchorPosition, activePosition);
        var absoluteEnd:int = getAbsoluteEnd(anchorPosition, activePosition);

        var selRange:ElementRange =
            ElementRange.createElementRange(textFlow, absoluteStart, absoluteEnd);

        var leaf:FlowLeafElement = selRange.firstLeaf;
        var attr:TextLayoutFormat = new TextLayoutFormat(leaf.computedFormat);

        // If there is a insertion point, see if there is an interaction
        // manager with a pending point format.
        if (anchorPosition != -1 && anchorPosition == activePosition)
        {
            if (textFlow.interactionManager)
            {
                var selectionState:SelectionState =
                    textFlow.interactionManager.getSelectionState();
                if (selectionState.pointFormat)
                    attr.apply(selectionState.pointFormat);
            }
        }
        else
        {
            for (;;)
            {
                if (leaf == selRange.lastLeaf)
                    break;
                leaf = leaf.getNextLeaf();
                attr.removeClashing(leaf.computedFormat);
            }
        }

        return Property.extractInCategory(
                    TextLayoutFormat,
                    TextLayoutFormat.description,
                    attr, Category.CHARACTER) as ITextLayoutFormat;
    }

    /**
     *  @private
     *  To get the format of the container without using a SelectionManager.
     *  The method should be kept in sync with the version in the
     *  SelectionManager.
     */
    mx_internal function getCommonContainerFormat():ITextLayoutFormat
    {
        var textFlow:TextFlow = getTextFlowWithComposer();

        var controller:ContainerController =
            textFlow.flowComposer.getControllerAt(0);

        return Property.extractInCategory(
                    TextLayoutFormat, TextLayoutFormat.description,
                    controller.computedFormat,
                    Category.CONTAINER) as ITextLayoutFormat;
    }

    /**
     *  @private
     *  To get the format of a paragraph without using a SelectionManager.
     *  The method should be kept in sync with the version in the
     *  SelectionManager.
     */
    mx_internal function getCommonParagraphFormat(
                                        anchorPosition:int,
                                        activePosition:int):ITextLayoutFormat
    {
        if (anchorPosition == -1 || activePosition == -1)
            return null;

        var textFlow:TextFlow = getTextFlowWithComposer();

        var absoluteStart:int = getAbsoluteStart(anchorPosition, activePosition);
        var absoluteEnd:int = getAbsoluteEnd(anchorPosition, activePosition);

        var selRange:ElementRange =
            ElementRange.createElementRange(textFlow, absoluteStart, absoluteEnd);

        var para:ParagraphElement = selRange.firstParagraph;
        var attr:TextLayoutFormat = new TextLayoutFormat(para.computedFormat);
        for (;;)
        {
            if (para == selRange.lastParagraph)
                break;

            para = textFlow.findAbsoluteParagraph(
                            para.getAbsoluteStart() + para.textLength);
            attr.removeClashing(para.computedFormat);
        }

        return Property.extractInCategory(TextLayoutFormat,
                    TextLayoutFormat.description,
                    attr, Category.PARAGRAPH) as ITextLayoutFormat;
    }

    /**
     *  @private
     *  Insert or append text to the textFlow without using an EditManager.
     *  If there is a SelectionManager or EditManager its selection will be
     *  updated at the end of the operation to keep it in sync.
     */
    mx_internal function insertTextOperation(insertText:String,
                                             anchorPosition:int,
                                             activePosition:int):Boolean
    {
        // No insertion point.
        if (anchorPosition == -1 || activePosition == -1)
		{
			return false;
		}

        var textFlow:TextFlow = getTextFlowWithComposer();

        var absoluteStart:int = getAbsoluteStart(anchorPosition, activePosition);
        var absoluteEnd:int = getAbsoluteEnd(anchorPosition, activePosition);

        // Need to get the format of the insertion point so that the inserted
        // text will have this format.
        var pointFormat:ITextLayoutFormat = getCommonCharacterFormat(absoluteStart, absoluteStart);
        var operationState:SelectionState = new SelectionState(textFlow, absoluteStart, absoluteEnd, pointFormat);

        // If there is an interaction manager, this keeps it in sync with
        // the results of this operation.
        operationState.selectionManagerOperationState = true;

        var op:InsertTextOperation = new InsertTextOperation(operationState, insertText);

        // Generations don't seem to be used in this code path since we
        // aren't doing composite, merge or undo operations so they were
        // optimized out.

        var success:Boolean = op.doOperation();
        if (success)
        {
            textFlow.normalize();

            textFlow.flowComposer.updateAllControllers();

            var insertPt:int = absoluteEnd - (absoluteEnd - absoluteStart) +
                                    + insertText.length;

            // No point format.
            var selectionState:SelectionState =
                new SelectionState(textFlow, insertPt, insertPt);

            var selectionEvent:SelectionEvent =
                new SelectionEvent(SelectionEvent.SELECTION_CHANGE,
                                   false, false, selectionState);

            textFlow.dispatchEvent(selectionEvent);

            scrollToRange(insertPt, insertPt);
        }

        return success;
    }

    mx_internal function getTextFlowWithComposer():TextFlow
    {
        var textFlow:TextFlow = getTextFlow();

        // Make sure there is a text flow with a flow composer.  There will
        // not be an interaction manager if editingMode is read-only.  If
        // there is an interaction manager flush any pending inserts into the
        // text flow.
        if (composeState != TextContainerManager.COMPOSE_COMPOSER)
		{
			convertToTextFlowWithComposer();
		}
        else if (textFlow.interactionManager)
		{
			textFlow.interactionManager.flushPendingOperations();
		}

        return textFlow;
    }

    private function getAbsoluteStart(anchorPosition:int, activePosition:int):int
    {
        return (anchorPosition < activePosition) ? anchorPosition : activePosition;
    }

    private function getAbsoluteEnd(anchorPosition:int, activePosition:int):int
    {
        return (anchorPosition > activePosition) ? anchorPosition : activePosition;
    }

    override public function focusInHandler(event:FocusEvent):void
    {
        textDisplay.focusInHandler(event);

        super.focusInHandler(event);
    }

    override public function focusOutHandler(event:FocusEvent):void
    {
        textDisplay.focusOutHandler(event);

        super.focusOutHandler(event);
    }

    override public function keyDownHandler(event:KeyboardEvent):void
    {
        textDisplay.keyDownHandler(event);

        if (!event.isDefaultPrevented())
		{
			super.keyDownHandler(event);
		}
    }

    override public function keyUpHandler(event:KeyboardEvent):void
    {
        if (!event.isDefaultPrevented())
		{
			super.keyUpHandler(event);
		}
    }

    override public function mouseWheelHandler(event:MouseEvent):void
    {
        // Bug: ContainerController.mouseWheelHandler() should be checking
        // if the default behavior is prevented before it acts on the event.
        if (!event.isDefaultPrevented())
		{
			super.mouseWheelHandler(event);
		}
    }

    override public function mouseDownHandler(event:MouseEvent):void
    {
        textDisplay.mouseDownHandler(event);

        super.mouseDownHandler(event);
    }

    /**
     *  @private
     *  This handler gets called for ACTIVATE events from the player
     *  and FLEX_WINDOW_ACTIVATE events from Flex.  Because of the
     *  way AIR handles activation of AIR Windows, and because Flex
     *  has its own concept of popups or pseudo-windows, we
     *  ignore ACTIVATE and respond to FLEX_WINDOW_ACTIVATE instead
     */
    override public function activateHandler(event:Event):void
    {
        // block ACTIVATE events
        if (event.type == Event.ACTIVATE)
		{
			return;
		}

        super.activateHandler(event);

        // TLF ties activation and focus together.  If a Flex PopUp is created
        // it is possible to get deactivate/activate events without any
        // focus events.  If we have focus when we are activated, the selection
        // state should be SelectionFormatState.FOCUSED not
        // SelectionFormatState.UNFOCUSED since there might not be a follow on
        // focusIn event.
        if (editingMode != EditingMode.READ_ONLY && textDisplay.getFocus() == textDisplay)
        {
            SelectionManager(beginInteraction()).setFocus();
            endInteraction();
       }
    }

    /**
     *  @private
     *  This handler gets called for DEACTIVATE events from the player
     *  and FLEX_WINDOW_DEACTIVATE events from Flex.  Because of the
     *  way AIR handles activation of AIR Windows, and because Flex
     *  has its own concept of popups or pseudo-windows, we
     *  ignore DEACTIVATE and respond to FLEX_WINDOW_DEACTIVATE instead
     */
    override public function deactivateHandler(event:Event):void
    {
        // block DEACTIVATE events
        if (event.type != Event.DEACTIVATE)
		{
        	super.deactivateHandler(event);
		}
    }

	override protected function getFocusedSelectionFormat():SelectionFormat
	{
		return textDisplay._selectionFormat;
	}
}
}

import cocoa.keyboard.KeyCode;
import cocoa.text.EditableTextView;

import flash.events.KeyboardEvent;
import flash.events.TextEvent;
import flash.system.Capabilities;

import flashx.textLayout.edit.EditManager;
import flashx.textLayout.elements.Configuration;
import flashx.textLayout.tlf_internal;
import flashx.undo.IUndoManager;

import mx.core.mx_internal;

use namespace mx_internal;
use namespace tlf_internal;

class EditableTextEditManager extends EditManager
{
	private var textDisplay:EditableTextView;

    public function EditableTextEditManager(component:EditableTextView, undoManager:IUndoManager = null)
    {
        super(undoManager);

        textDisplay = component;
    }

    override public function textInputHandler(event:TextEvent):void
    {
        super.textInputHandler(event);

        // Normally keystrokes are saved until the next enter frame event before
        // they are inserted into the text flow.  If this flag is false, the
        // character just typed will be inserted into the text flow immediately.
        if (!textDisplay.batchTextInput)
		{
			flushPendingOperations();
		}
    }

	public override function keyDownHandler(event:KeyboardEvent):void
	{
		if (!hasSelection() || event.isDefaultPrevented())
		{
			return;
		}

		if (event.ctrlKey && event.shiftKey && event.keyCode == KeyCode.Z)
		{
			if (!Configuration.versionIsAtLeast(10, 1) && (Capabilities.os.search("Mac OS") > -1))
			{
				ignoreNextTextEvent = true;
			}

			redo();
			event.preventDefault();
		}

		super.keyDownHandler(event);
	}
}