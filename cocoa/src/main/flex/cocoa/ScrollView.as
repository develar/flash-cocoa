package cocoa
{
import flash.display.DisplayObject;
import flash.geom.Point;

import mx.core.IUIComponent;
import mx.events.PropertyChangeEvent;
import mx.managers.IFocusManagerComponent;
import mx.utils.MatrixUtil;

import spark.components.supportClasses.GroupBase;
import spark.components.supportClasses.ScrollBarBase;
import spark.core.IViewport;

/**
 * http://developer.apple.com/mac/library/documentation/cocoa/reference/ApplicationKit/Classes/NSScrollView_Class/Reference/Reference.html
 * http://developer.apple.com/mac/library/documentation/cocoa/Conceptual/NSScrollViewGuide/Articles/Basics.html
 *
 * Терминология частей полосы прокрутки как во Flex/Swing, а не как в Cocoa
 *
 * При скиновании может потребоваться чтобы thumb гулял не на всем track — как в Cocoa для вертикальной полосы прокрутки отступ сверху 7px —
 * для этого установите у track border соответствующий contentInsets.
 */
public class ScrollView extends AbstractView implements IFocusManagerComponent
{
	private var horizontalScrollBar:HScrollBar;
    private var verticalScrollBar:VScrollBar;

	/**
     *  SDT - Scrollbar Display Threshold.  If the content size exceeds the viewport's size by SDT, then we show a scrollbar.
	 * For example, if the contentWidth >= viewport width + SDT, show the horizontal scrollbar.
     */
    private static const SDT:Number = 1.0;

	public function ScrollView()
	{
		hasFocusableChildren = true;
        focusEnabled = false;
	}

	private var documentViewChanged:Boolean;
	private var _documentView:IViewport;
	public function set documentView(value:IViewport):void
	{
		if (value != _documentView)
		{
			documentViewChanged = true;
			_documentView = value;
			invalidateProperties();
		}
	}

	private var _verticalScrollbarPolicy:int = ScrollbarPolicy.AUTO;
	public function set verticalScrollbarPolicy(value:uint):void
	{
		_verticalScrollbarPolicy = value;

		if (verticalScrollBar != null)
		{
			verticalScrollBar.visible = _verticalScrollbarPolicy != ScrollbarPolicy.OFF;
		}
	}

	private var _horizontalScrollbarPolicy:int = ScrollbarPolicy.AUTO;
	public function set horizontalScrollbarPolicy(value:uint):void
	{
		_horizontalScrollbarPolicy = value;

		if (horizontalScrollBar != null)
		{
			horizontalScrollBar.visible = _horizontalScrollbarPolicy != ScrollbarPolicy.OFF;
		}
	}

	public function drawFocus(isFocused:Boolean):void
	{
	}

	override protected function createChildren():void
	{
		super.createChildren();

		if (_verticalScrollbarPolicy != ScrollbarPolicy.OFF)
		{
			verticalScrollBar = new VScrollBar();
			addChild(verticalScrollBar);
		}

		if (_horizontalScrollbarPolicy != ScrollbarPolicy.OFF)
		{
			horizontalScrollBar = new HScrollBar();
			addChild(horizontalScrollBar);
		}
	}

	override protected function commitProperties():void
	{
		super.commitProperties();

		if (documentViewChanged)
		{
			documentViewChanged = false;

			var oldDocumentView:IViewport = numChildren == 0 ? null : (getChildAt(0) as IViewport);
			if (oldDocumentView != null)
			{
				removeChildAt(0);
				oldDocumentView.clipAndEnableScrolling = false;
				oldDocumentView.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, documentViewPropertyChangeHandler);
			}

			if (_documentView != null)
			{
				_documentView.clipAndEnableScrolling = true;
				addChildAt(DisplayObject(_documentView), 0);
				_documentView.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, documentViewPropertyChangeHandler);
			}

			if (verticalScrollBar != null)
			{
				verticalScrollBar.viewport = _documentView;
			}
			if (horizontalScrollBar != null)
			{
				horizontalScrollBar.viewport = _documentView;
			}
		}
	}

	private function documentViewPropertyChangeHandler(event:PropertyChangeEvent):void
	{
		switch (event.property)
		{
			case "contentWidth":
			case "contentHeight":
			{
				invalidateSize();
            	invalidateDisplayList();
			}
			break;
		}
	}

	private function get hsbVisible():Boolean
	{
		var hsb:HScrollBar = horizontalScrollBar;
		return hsb && hsb.visible;
	}

	private var hsbScaleX:Number = 1;
	private var hsbScaleY:Number = 1;

	private var vsbScaleX:Number = 1;
    private var vsbScaleY:Number = 1;

	private function hsbRequiredHeight():Number
	{
        return Math.max(minViewportInset, horizontalScrollBar.getPreferredBoundsHeight(hsbVisible) * (hsbVisible ? 1 : hsbScaleY));
    }

	private function get vsbVisible():Boolean
    {
        return verticalScrollBar && verticalScrollBar.visible;
    }

	 private function vsbRequiredWidth():Number
    {
        return Math.max(minViewportInset, verticalScrollBar.getPreferredBoundsWidth(vsbVisible) * (vsbVisible ? 1 : vsbScaleX));
    }

	private var minViewportInset:Number = 0;

	private function getLayoutContentSize(viewport:IViewport):Point
    {
        // TODO(hmuller):prefer to do nothing if transform doesn't change size, see UIComponent/nonDeltaLayoutMatrix()
        var cw:Number = viewport.contentWidth;
        var ch:Number = viewport.contentHeight;
        if (((cw == 0) && (ch == 0)) || (isNaN(cw) || isNaN(ch)))
            return new Point(0,0);
        return MatrixUtil.transformSize(cw, ch, viewport.getLayoutMatrix());
    }

	override protected function measure():void
	{
		var measuredW:Number = 0;
		var measuredH:Number = 0;

		const measuredSizeIncludesScrollBars:Boolean = true;
		const hsb:ScrollBarBase = horizontalScrollBar;
		var showHSB:Boolean = false;
		var hAuto:Boolean = false;
		if (measuredSizeIncludesScrollBars)
		{
			switch (_horizontalScrollbarPolicy)
			{
				case ScrollbarPolicy.ON:
				{
					if (hsb)
					{
						showHSB = true;
					}
				}
				break;

				case ScrollbarPolicy.AUTO:
				{
					if (hsb)
					{
						showHSB = hsb.visible;
					}
					hAuto = true;
				}
				break;
			}
		}

		const vsb:ScrollBarBase = verticalScrollBar;
		var showVSB:Boolean = false;
		var vAuto:Boolean = false;
		if (measuredSizeIncludesScrollBars)
		{
			switch (_verticalScrollbarPolicy)
			{
				case ScrollbarPolicy.ON:
				{
					if (vsb)
					{
						showVSB = true;
					}
				}
				break;

				case ScrollbarPolicy.AUTO:
				{
					if (vsb)
					{
						showVSB = vsb.visible;
					}
					vAuto = true;
				}
				break;
			}
		}

		measuredH += (showHSB) ? hsbRequiredHeight() : minViewportInset;
		measuredW += (showVSB) ? vsbRequiredWidth() : minViewportInset;

		// The measured size of the viewport is just its preferredBounds, except:
		// don't give up space if doing so would make an auto scrollbar visible.
		// In other words, if an auto scrollbar isn't already showing, and using
		// the preferred size would force it to show, and the current size would not,
		// then use its current size as the measured size.  Note that a scrollbar
		// is only shown if the content size is greater than the viewport size
		// by at least SDT.

		var viewport:IViewport = _documentView;
		if (viewport != null)
		{
			if (measuredSizeIncludesScrollBars)
			{
				var contentSize:Point = getLayoutContentSize(viewport);

				var viewportPreferredW:Number = viewport.getPreferredBoundsWidth();
				var viewportContentW:Number = contentSize.x;
				var viewportW:Number = viewport.getLayoutBoundsWidth();  // "current" size
				var currentSizeNoHSB:Boolean = !isNaN(viewportW) && ((viewportW + SDT) > viewportContentW);
				if (hAuto && !showHSB && ((viewportPreferredW + SDT) <= viewportContentW) && currentSizeNoHSB)
				{
					measuredW += viewportW;
				}
				else
				{
					measuredW += Math.max(viewportPreferredW, (showHSB) ? hsb.getMinBoundsWidth() : 0);
				}

				var viewportPreferredH:Number = viewport.getPreferredBoundsHeight();
				var viewportContentH:Number = contentSize.y;
				var viewportH:Number = viewport.getLayoutBoundsHeight();  // "current" size
				var currentSizeNoVSB:Boolean = !isNaN(viewportH) && ((viewportH + SDT) > viewportContentH);
				if (vAuto && !showVSB && ((viewportPreferredH + SDT) <= viewportContentH) && currentSizeNoVSB)
				{
					measuredH += viewportH;
				}
				else
				{
					measuredH += Math.max(viewportPreferredH, (showVSB) ? vsb.getMinBoundsHeight() : 0);
				}
			}
			else
			{
				measuredW += viewport.getPreferredBoundsWidth();
				measuredH += viewport.getPreferredBoundsHeight();
			}
		}

		var minW:Number = minViewportInset * 2;
		var minH:Number = minViewportInset * 2;

		// If the viewport's explicit size is set, then
		// include that in the scroller's minimum size

		var viewportUIC:IUIComponent = viewport as IUIComponent;
		var explicitViewportW:Number = viewportUIC ? viewportUIC.explicitWidth : NaN;
		var explicitViewportH:Number = viewportUIC ? viewportUIC.explicitHeight : NaN;

		if (!isNaN(explicitViewportW))
		{
			minW += explicitViewportW;
		}

		if (!isNaN(explicitViewportH))
		{
			minH += explicitViewportH;
		}

		measuredWidth = Math.ceil(measuredW);
		measuredHeight = Math.ceil(measuredH);
		measuredMinWidth = Math.ceil(minW);
		measuredMinHeight = Math.ceil(minH);
	}

	/**
     *  @private
     *  To make the scrollbars invisible to methods like getRect() and getBounds()
     *  as well as to methods based on them like hitTestPoint(), we set their scale
     *  to 0.  More info about this here: http://bugs.adobe.com/jira/browse/SDK-21540
     */
    private function set hsbVisible(value:Boolean):void
    {
        var hsb:ScrollBarBase = horizontalScrollBar;
        if (!hsb)
            return;

        hsb.includeInLayout = hsb.visible = value;
        if (value)
        {
            if (hsb.scaleX == 0)
                hsb.scaleX = hsbScaleX;
            if (hsb.scaleY == 0)
                hsb.scaleY = hsbScaleY;
        }
        else
        {
            if (hsb.scaleX != 0)
                hsbScaleX = hsb.scaleX;
            if (hsb.scaleY != 0)
                hsbScaleY = hsb.scaleY;
            hsb.scaleX = hsb.scaleY = 0;
        }
    }

	/**
     *  @private
     *  The logic here is the same as for the horizontal scrollbar, see above.
     */
    private function set vsbVisible(value:Boolean):void
    {
        var vsb:ScrollBarBase = verticalScrollBar;
        if (!vsb)
            return;

        vsb.includeInLayout = vsb.visible = value;
        if (value)
        {
            if (vsb.scaleX == 0)
                vsb.scaleX = vsbScaleX;
            if (vsb.scaleY == 0)
                vsb.scaleY = vsbScaleY;
        }
        else
        {
            if (vsb.scaleX != 0)
                vsbScaleX = vsb.scaleX;
            if (vsb.scaleY != 0)
                vsbScaleY = vsb.scaleY;
            vsb.scaleX = vsb.scaleY = 0;
        }
    }

	 private function hsbFits(w:Number, h:Number, includeVSB:Boolean=true):Boolean
    {
        if (vsbVisible && includeVSB)
        {
            var vsb:ScrollBarBase = verticalScrollBar;
            w -= vsb.getPreferredBoundsWidth();
            h -= vsb.getMinBoundsHeight();
        }
        var hsb:ScrollBarBase = horizontalScrollBar;
        return (w >= hsb.getMinBoundsWidth()) && (h >= hsb.getPreferredBoundsHeight());
    }

	private function vsbFits(w:Number, h:Number, includeHSB:Boolean=true):Boolean
    {
        if (hsbVisible && includeHSB)
        {
            var hsb:ScrollBarBase = horizontalScrollBar;
            w -= hsb.getMinBoundsWidth();
            h -= hsb.getPreferredBoundsHeight();
        }
        var vsb:ScrollBarBase = verticalScrollBar;  
        return (w >= vsb.getPreferredBoundsWidth()) && (h >= vsb.getMinBoundsHeight());
    }

	override protected function updateDisplayList(w:Number, h:Number):void
	{
        var viewport:IViewport = _documentView;
        var hsb:ScrollBarBase = horizontalScrollBar;
        var vsb:ScrollBarBase = verticalScrollBar;
        var minViewportInset:Number = minViewportInset;

        var contentW:Number = 0;
        var contentH:Number = 0;
        if (viewport)
        {
            var contentSize:Point = getLayoutContentSize(viewport);
            contentW = contentSize.x;
            contentH = contentSize.y;
        }

        // If the viewport's size has been explicitly set (not typical) then use it
        // The initial values for viewportW,H are only used to decide if auto scrollbars
        // should be shown.

        var viewportUIC:IUIComponent = viewport as IUIComponent;
        var explicitViewportW:Number = viewportUIC ? viewportUIC.explicitWidth : NaN;
        var explicitViewportH:Number = viewportUIC ? viewportUIC.explicitHeight : NaN;

        var viewportW:Number = isNaN(explicitViewportW) ? (w - (minViewportInset * 2)) : explicitViewportW;
        var viewportH:Number = isNaN(explicitViewportH) ? (h - (minViewportInset * 2)) : explicitViewportH;

        // Decide which scrollbars will be visible based on the viewport's content size
        // and the scroller's scroll policies.  A scrollbar is shown if the content size
        // greater than the viewport's size by at least SDT.

        var oldShowHSB:Boolean = hsbVisible;
        var oldShowVSB:Boolean = vsbVisible;

        var hAuto:Boolean = false;
        switch(_horizontalScrollbarPolicy)
        {
            case ScrollbarPolicy.ON:
                hsbVisible = true;
                break;

            case ScrollbarPolicy.AUTO:
                if (hsb && viewport)
                {
                    hAuto = true;
                    hsbVisible = (contentW >= (viewportW + SDT));
                }
                break;

            default:
                hsbVisible = false;
        }

        var vAuto:Boolean = false;
        switch(_verticalScrollbarPolicy)
        {
           case ScrollbarPolicy.ON:
                vsbVisible = true;
                break;

            case ScrollbarPolicy.AUTO:
                if (vsb && viewport)
                {
                    vAuto = true;
                    vsbVisible = (contentH >= (viewportH + SDT));
                }
                break;

            default:
                vsbVisible = false;
        }

        // Reset the viewport's width,height to account for the visible scrollbars, unless
        // the viewport's size was explicitly set, then we just use that.

        if (isNaN(explicitViewportW))
            viewportW = w - ((vsbVisible) ? (minViewportInset + vsbRequiredWidth()) : (minViewportInset * 2));
        else
            viewportW = explicitViewportW;

        if (isNaN(explicitViewportH))
            viewportH = h - ((hsbVisible) ? (minViewportInset + hsbRequiredHeight()) : (minViewportInset * 2));
        else
            viewportH = explicitViewportH;

        // If the scrollBarPolicy is auto, and we're only showing one scrollbar,
        // the viewport may have shrunk enough to require showing the other one.

        var hsbIsDependent:Boolean = false;
        var vsbIsDependent:Boolean = false;

        if (vsbVisible && !hsbVisible && hAuto && (contentW >= (viewportW + SDT)))
            hsbVisible = hsbIsDependent = true;
        else if (!vsbVisible && hsbVisible && vAuto && (contentH >= (viewportH + SDT)))
            vsbVisible = vsbIsDependent = true;

        // If the HSB doesn't fit, hide it and give the space back.   Likewise for VSB.
        // If both scrollbars are supposed to be visible but they don't both fit,
        // then prefer to show the "non-dependent" auto scrollbar if we added the second
        // "dependent" auto scrollbar because of the space consumed by the first.

        if (hsbVisible && vsbVisible)
        {
            if (hsbFits(w, h) && vsbFits(w, h))
            {
                // Both scrollbars fit, we're done.
            }
            else if (!hsbFits(w, h, false) && !vsbFits(w, h, false))
            {
                // Neither scrollbar would fit, even if the other scrollbar wasn't visible.
                hsbVisible = false;
                vsbVisible = false;
            }
            else
            {
                // Only one of the scrollbars will fit.  If we're showing a second "dependent"
                // auto scrollbar because the first scrollbar consumed enough space to
                // require it, if the first scrollbar doesn't fit, don't show either of them.

                if (hsbIsDependent)
                {
                    if (vsbFits(w, h, false))  // VSB will fit if HSB isn't shown
                        hsbVisible = false;
                    else
                        vsbVisible = hsbVisible = false;

                }
                else if (vsbIsDependent)
                {
                    if (hsbFits(w, h, false)) // HSB will fit if VSB isn't shown
                        vsbVisible = false;
                    else
                        hsbVisible = vsbVisible = false;
                }
                else if (vsbFits(w, h, false)) // VSB will fit if HSB isn't shown
                    hsbVisible = false;
                else // hsbFits(w, h, false)   // HSB will fit if VSB isn't shown
                    vsbVisible = false;
            }
        }
        else if (hsbVisible && !hsbFits(w, h))  // just trying to show HSB, but it doesn't fit
            hsbVisible = false;
        else if (vsbVisible && !vsbFits(w, h))  // just trying to show VSB, but it doesn't fit
            vsbVisible = false;

        // Reset the viewport's width,height to account for the visible scrollbars, unless
        // the viewport's size was explicitly set, then we just use that.

        if (isNaN(explicitViewportW))
            viewportW = w - ((vsbVisible) ? (minViewportInset + vsbRequiredWidth()) : (minViewportInset * 2));
        else
            viewportW = explicitViewportW;

        if (isNaN(explicitViewportH))
            viewportH = h - ((hsbVisible) ? (minViewportInset + hsbRequiredHeight()) : (minViewportInset * 2));
        else
            viewportH = explicitViewportH;

        // Layout the viewport and scrollbars.

        if (viewport)
        {
            viewport.setLayoutBoundsSize(viewportW, viewportH);
            viewport.setLayoutBoundsPosition(minViewportInset, minViewportInset);
        }

        if (hsbVisible)
        {
            var hsbW:Number = (vsbVisible) ? w - vsb.getPreferredBoundsWidth() : w;
            var hsbH:Number = hsb.getPreferredBoundsHeight();
            hsb.setLayoutBoundsSize(Math.max(hsb.getMinBoundsWidth(), hsbW), hsbH);
            hsb.setLayoutBoundsPosition(0, h - hsbH);
        }

        if (vsbVisible)
        {
            var vsbW:Number = vsb.getPreferredBoundsWidth();
            var vsbH:Number = (hsbVisible) ? h - hsb.getPreferredBoundsHeight() : h;
            vsb.setLayoutBoundsSize(vsbW, Math.max(vsb.getMinBoundsHeight(), vsbH));
            vsb.setLayoutBoundsPosition(w - vsbW, 0);
        }

        if ((((vsbVisible != oldShowVSB) && vAuto) || ((hsbVisible != oldShowHSB) && hAuto)))
        {
            invalidateSize();

            // If the viewport's layout is virtual, it's possible that its
            // measured size changed as a consequence of laying it out,
            // so we invalidate its size as well.
            var viewportGroup:GroupBase = viewport as GroupBase;
            if (viewportGroup && viewportGroup.layout && viewportGroup.layout.useVirtualLayout)
                viewportGroup.invalidateSize();
        }

       // setContentSize(w, h);
	}

//	private var _contentWidth:Number = 0;
//	private var _contentHeight:Number = 0;
}
}