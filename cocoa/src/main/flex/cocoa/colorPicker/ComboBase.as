////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2002-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package cocoa.colorPicker
{
import flash.events.Event;
import flash.events.FocusEvent;

import mx.collections.ArrayCollection;
import mx.collections.CursorBookmark;
import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.IViewCursor;
import mx.collections.ListCollectionView;
import mx.collections.XMLListCollection;
import mx.controls.Button;
import mx.core.EdgeMetrics;
import mx.core.IIMESupport;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.FlexEvent;
import mx.managers.IFocusManager;
import mx.managers.IFocusManagerComponent;
import mx.utils.UIDUtil;

use namespace mx_internal;

/**
 *  Name of the class to use as the default skin for the background and border.
 *  For the ComboBase class, there is no default value.
 *  For the ComboBox class, the default value is the ComboBoxArrowSkin class.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="skin", type="Class", inherit="no", states=" up, over, down, disabled,  editableUp, editableOver, editableDown, editableDisabled")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when the mouse is not over the control.
 *  For the ComboBase class, there is no default value.
 *  For the ComboBox class, the default value is the ComboBoxArrowSkin class.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="upSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when the mouse is over the control.
 *  For the ComboBase class, there is no default value.
 *  For the ComboBox class, the default value is the ComboBoxArrowSkin class.
 *  For the ColorPicker class, the default value is the ColorPickerSkin class.
 *  For the DateField class, the default value is the ScrollArrowDownSkin class.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="overSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when the user holds down the mouse button.
 *  For the ComboBase class, there is no default value.
 *  For the ComboBox class, the default value is the ComboBoxArrowSkin class.
 *  For the ColorPicker class, the default value is the ColorPickerSkin class.
 *  For the DateField class, the default value is the ScrollArrowDownSkin class.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="downSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when the control is disabled.
 *  For the ComboBase class, there is no default value.
 *  For the ComboBox class, the default value is the ComboBoxArrowSkin class.
 *  For the ColorPicker class, the default value is the ColorPickerSkin class.
 *  For the DateField class, the default value is the ScrollArrowDownSkin class.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="disabledSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when the <code>editable</code>
 *  property is <code>true</code>. This skin is only used by the ComboBox class.
 *  For the ComboBase class, there is no default value.
 *  For the ComboBox class, the default value is the ComboBoxArrowSkin class.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="editableSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when the mouse is not over the control, and the <code>editable</code>
 *  property is <code>true</code>. This skin is only used by the ComboBox class.
 *  For the ComboBase class, there is no default value.
 *  For the ComboBox class, the default value is the ComboBoxArrowSkin class.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="editableUpSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when the mouse is over the control, and the <code>editable</code>
 *  property is <code>true</code>. This skin is only used by the ComboBox class.
 *  For the ComboBase class, there is no default value.
 *  For the ComboBox class, the default value is the ComboBoxArrowSkin class.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="editableOverSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when the user holds down the mouse button, and the <code>editable</code>
 *  property is <code>true</code>. This skin is only used by the ComboBox class.
 *  For the ComboBase class, there is no default value.
 *  For the ComboBox class, the default value is the ComboBoxArrowSkin class.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="editableDownSkin", type="Class", inherit="no")]

/**
 *  Name of the class to use as the skin for the background and border
 *  when the control is disabled, and the <code>editable</code>
 *  property is <code>true</code>. This skin is only used by the ComboBox class.
 *  For the ComboBase class, there is no default value.
 *  For the ComboBox class, the default value is the ComboBoxArrowSkin class.
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="editableDisabledSkin", type="Class", inherit="no")]


/**
 *  The ComboBase class is the base class for controls that display text in a
 *  text field and have a button that causes a drop-down list to appear where
 *  the user can choose which text to display.
 *  The ComboBase class is not used directly as an MXML tag.
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mx:ComboBase&gt;</code> tag inherits all the tag attributes
 *  of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;<i>mx:tagname</i>
 *    <b>Properties</b>
 *    dataProvider="null"
 *    editable="false|true"
 *    imeMode="null"
 *    restrict="null"
 *    selectedIndex="-1"
 *    selectedItem="null"
 *    text=""
 *    &nbsp;
 *    <b>Styles</b>
 *    disabledSkin="<i>Depends on class</i>"
 *    downSkin="<i>Depends on class</i>"
 *    editableDisabledSkin="<i>Depends on class</i>"
 *    editableDownSkin="<i>Depends on class</i>"
 *    editableOverSkin="<i>Depends on class</i>"
 *    editableUpSkin="<i>Depends on class</i>"
 *    overSkin="<i>Depends on class</i>"
 *    textInputStyleName=""
 *    upSkin="<i>Depends on class</i>"
 *
 *  /&gt;
 *  </pre>
 *
 *  @see mx.controls.Button
 *  @see mx.controls.TextInput
 *  @see mx.collections.ICollectionView
 *
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ComboBase extends UIComponent implements IIMESupport, IFocusManagerComponent
{
    public function ComboBase()
    {
        super();

        tabEnabled = true;
        tabFocusEnabled = true;
    }

    /**
     *  The ICollectionView of items this component displays.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var collection:ICollectionView;

    /**
     *  The main IViewCursor used to fetch items from the
     *  dataProvider and pass the items to the renderers.
     *  At the end of any sequence of code, it must always be positioned
     *  at the topmost visible item on screen.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var iterator:IViewCursor;

    /**
     *  The internal Button property that causes the drop-down list to appear.
     */
    protected var downArrowButton:Button;

    /**
     *  @private
     */
    private var selectedUID:String;

    /**
     *  @private
     *  A flag indicating that selection has changed
     */
    private var selectionChanged:Boolean = false;

    /**
     *  @private
     *  A flag indicating that selectedIndex has changed
     */
    private var selectedIndexChanged:Boolean = false;

    /**
     *  @private
     *  A flag indicating that selectedItem has changed
     */
    private var selectedItemChanged:Boolean = false;

    /**
     *  @private
     *  Storage for enabled property.
     */
    private var _enabled:Boolean = false;

    /**
     *  @private
     */
    private var enabledChanged:Boolean = false;

    [Inspectable(category="General", enumeration="true,false", defaultValue="true")]

    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        super.enabled = value;
        _enabled = value;

        enabledChanged = true;
        invalidateProperties();
    }

    /**
     *  Returns an EdgeMetrics object that has four properties:
     *  <code>left</code>, <code>top</code>, <code>right</code>,
     *  and <code>bottom</code>.
     *  The value of each property is equal to the thickness of the
     *  corresponding side of the border, expressed in pixels.
     *
     *  @return EdgeMetrics object with the left, right, top,
     *  and bottom properties.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function get borderMetrics():EdgeMetrics
    {
        return EdgeMetrics.EMPTY;
    }

    //----------------------------------
    //  dataProvider
    //----------------------------------

    [Bindable("collectionChange")]
    [Inspectable(category="Data")]

    /**
     *  The set of items this component displays. This property is of type
     *  Object because the derived classes can handle a variety of data
     *  types such as Arrays, XML, ICollectionViews, and other classes.  All
     *  are converted into an ICollectionView and that ICollectionView is
     *  returned if you get the value of this property; you will not get the
     *  value you set if it was not an ICollectionView.
     *
     *  <p>Setting this property will adjust the <code>selectedIndex</code>
     *  property (and therefore the <code>selectedItem</code> property) if
     *  the <code>selectedIndex</code> property has not otherwise been set.
     *  If there is no <code>prompt</code> property, the <code>selectedIndex</code>
     *  property will be set to 0; otherwise it will remain at -1,
     *  the index used for the prompt string.
     *  If the <code>selectedIndex</code> property has been set and
     *  it is out of range of the new data provider, unexpected behavior is
     *  likely to occur.</p>
     *
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get dataProvider():Object
    {
        return collection;
    }

    /**
     *  @private
     */
    public function set dataProvider(value:Object):void
    {
        if (value is Array)
        {
            collection = new ArrayCollection(value as Array);
        }
        else if (value is ICollectionView)
        {
            collection = ICollectionView(value);
        }
        else if (value is IList)
        {
            collection = new ListCollectionView(IList(value));
        }
        else if (value is XMLList)
        {
            collection = new XMLListCollection(value as XMLList);
        }
        else
        {
            // convert it to an array containing this one item
            var tmp:Array = [value];
            collection = new ArrayCollection(tmp);
        }
        // get an iterator for the displaying rows.  The CollectionView's
        // main iterator is left unchanged so folks can use old DataSelector
        // methods if they want to
        iterator = collection.createCursor();

        // trace("ListBase added change listener");
        // weak listeners to collections and dataproviders
        collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler, false, 0, true);

        var event:CollectionEvent =
            new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
        event.kind = CollectionEventKind.RESET;
        collectionChangeHandler(event);
        dispatchEvent(event);

        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  editable
    //----------------------------------

    /**
     *  @private
     *  Storage for editable property.
     */
    private var _editable:Boolean = false;

    /**
     *  @private
     */
    mx_internal var editableChanged:Boolean = true;

    [Bindable("editableChanged")]
    [Inspectable(category="General", defaultValue="false")]

    /**
     *  A flag that indicates whether the control is editable,
     *  which lets the user directly type entries that are not specified
     *  in the dataProvider, or not editable, which requires the user select
     *  from the items in the dataProvider.
     *
     *  <p>If <code>true</code> keyboard input will be entered in the
     *  editable text field; otherwise it will be used as shortcuts to
     *  select items in the dataProvider.</p>
     *
     *  @default false.
     *  This property is ignored by the DateField control.
     *
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get editable():Boolean
    {
        return _editable;
    }

    /**
     *  @private
     */
    public function set editable(value:Boolean):void
    {
        _editable = value;
        editableChanged = true;

        invalidateProperties();

        dispatchEvent(new Event("editableChanged"));
    }

    //----------------------------------
    //  enableIME
    //----------------------------------

    /**
     *  A flag that indicates whether the IME should
     *  be enabled when the component receives focus.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get enableIME():Boolean
    {
        return editable;
    }

    //----------------------------------
    //  imeMode
    //----------------------------------

    /**
     *  @private
     */
    private var _imeMode:String = null;

    /**
     *  @copy mx.controls.TextInput#imeMode
     *
     *  @default null
     **/
    public function get imeMode():String
    {
        return _imeMode;
    }

    /**
     *  @private
     */
    public function set imeMode(value:String):void
    {
        _imeMode = value;
    }

    //----------------------------------
    //  restrict
    //----------------------------------

    /**
     *  @private
     *  Storage for restrict property.
     */
    private var _restrict:String;

    [Bindable("restrictChanged")]
    [Inspectable(category="Other")]

    /**
     *  Set of characters that a user can or cannot enter into the text field.
     *
     *  @default null
     *
     *  @see flash.text.TextField#restrict
     *
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get restrict():String
    {
        return _restrict;
    }

    /**
     *  @private
     */
    public function set restrict(value:String):void
    {
        _restrict = value;

        invalidateProperties();

        dispatchEvent(new Event("restrictChanged"));
    }

    //----------------------------------
    //  selectedIndex
    //----------------------------------

    private var _selectedIndex:int = -1;

    [Bindable("change")]
    [Bindable("valueCommit")]
    [Inspectable(category="General", defaultValue="-1")]

    /**
     *  The index in the data provider of the selected item.
     *  If there is a <code>prompt</code> property, the <code>selectedIndex</code>
     *  value can be set to -1 to show the prompt.
     *  If there is no <code>prompt</code>, property then <code>selectedIndex</code>
     *  will be set to 0 once a <code>dataProvider</code> is set.
     *
     *  <p>If the ComboBox control is editable, the <code>selectedIndex</code>
     *  property is -1 if the user types any text
     *  into the text field.</p>
     *
     *  <p>Unlike many other Flex properties that are invalidating (setting
     *  them does not have an immediate effect), the <code>selectedIndex</code> and
     *  <code>selectedItem</code> properties are synchronous; setting one immediately
     *  affects the other.</p>
     *
     *  @default -1
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get selectedIndex():int
    {
        return _selectedIndex;
    }

    /**
     *  @private
     */
    public function set selectedIndex(value:int):void
    {
        _selectedIndex = value;
        if (value == -1)
        {
            _selectedItem = null;
            selectedUID = null;
        }

        //2 code paths: one for before collection, one after
        if (!collection || collection.length == 0)
        {
            selectedIndexChanged = true;
        }
        else
        {
            if (value != -1)
            {
                value = Math.min(value, collection.length - 1);
                var bookmark:CursorBookmark = iterator.bookmark;
                var len:int = value;
                iterator.seek(CursorBookmark.FIRST, len);
                var data:Object = iterator.current;
                var uid:String = itemToUID(data);
                iterator.seek(bookmark, 0);
                _selectedIndex = value;
                _selectedItem = data;
                selectedUID = uid;
            }
        }

        selectionChanged = true;

        invalidateDisplayList();

        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }


    //----------------------------------
    //  selectedItem
    //----------------------------------

    /**
     *  @private
     *  Storage for the selectedItem property.
     */
    private var _selectedItem:Object;

    [Bindable("change")]
    [Bindable("valueCommit")]
    [Inspectable(category="General", defaultValue="null")]

    /**
     *  The item in the data provider at the selectedIndex.
     *
     *  <p>If the data is an object or class instance, modifying
     *  properties in the object or instance modifies the
     *  <code>dataProvider</code> object but may not update the views
     *  unless the instance is Bindable or implements IPropertyChangeNotifier
     *  or a call to dataProvider.itemUpdated() occurs.</p>
     *
     *  Setting the <code>selectedItem</code> property causes the
     *  ComboBox control to select that item (display it in the text field and
     *  set the <code>selectedIndex</code>) if it exists in the data provider.
     *  If the ComboBox control is editable, the <code>selectedItem</code>
     *  property is <code>null</code> if the user types any text
     *  into the text field.
     *
     *  <p>Unlike many other Flex properties that are invalidating (setting
     *  them does not have an immediate effect), <code>selectedIndex</code> and
     *  <code>selectedItem</code> are synchronous; setting one immediately
     *  affects the other.</p>
     *
     *  @default null;
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get selectedItem():Object
    {
        return _selectedItem;
    }

    /**
     *  @private
     */
    public function set selectedItem(data:Object):void
    {
        setSelectedItem(data);
    }

    /**
     *  @private
     */
    private function setSelectedItem(data:Object):void
    {
        //2 code paths: one for before collection, one after
        if (!collection || collection.length == 0)
        {
           _selectedItem = data;
            selectedItemChanged = true;
            invalidateDisplayList();
            return;
        }

        var found:Boolean = false;
        var listCursor:IViewCursor = collection.createCursor();
        var i:int = 0;
        do
        {
            if (data == listCursor.current)
            {
                _selectedIndex = i;
                _selectedItem = data;
                selectedUID = itemToUID(data);
                selectionChanged = true;
                found = true;
                break;
            }
            i++;
        }
        while (listCursor.moveNext());

        if (!found)
        {
            selectedIndex = -1;
            _selectedItem = null;
            selectedUID = null;
        }

        invalidateDisplayList();
    }

    //----------------------------------
    //  text
    //----------------------------------

    /**
     *  @private
     *  Storage for the text property.
     */
    private var _text:String = "";

    /**
     *  @private
     */
    mx_internal var textChanged:Boolean;

    [Bindable("collectionChange")]
    [Bindable("valueCommit")]
    [Inspectable(category="General", defaultValue="")]
    [NonCommittingChangeEvent("change")]

    /**
     *  Contents of the text field.  If the control is non-editable
     *  setting this property has no effect. If the control is editable,
     *  setting this property sets the contents of the text field.
     *
     *  @default ""
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get text():String
    {
        return _text;
    }

    /**
     *  @private
     */
    public function set text(value:String):void
    {
        _text = value;
        textChanged = true;

        invalidateProperties();

        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }

    //----------------------------------
    //  value
    //----------------------------------

    [Bindable("change")]
    [Bindable("valueCommit")]

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------


    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();

        // Next, create the downArrowButton before creating the textInput,
        // because it can be as large as the entire control.
        if (!downArrowButton)
        {
            downArrowButton = new Button();
            downArrowButton.focusEnabled = false;

            addChild(downArrowButton);

            downArrowButton.addEventListener(FlexEvent.BUTTON_DOWN,
                                             downArrowButton_buttonDownHandler);

        }
    }

    override public function styleChanged(styleProp:String):void
    {
        if (downArrowButton)
            downArrowButton.styleChanged(styleProp);

        super.styleChanged(styleProp);
    }

    override protected function commitProperties():void
    {
        super.commitProperties();

        if (enabledChanged)
        {
            editableChanged = true;
            downArrowButton.enabled = _enabled;
            enabledChanged = false;
        }

        if (editableChanged)
        {
            editableChanged = false;
        }
    }

    /**
     *  Sizes and positions the internal components in the given width
     *  and height.  The drop-down button is placed all the way to the right
     *  and the text field fills the remaining area.
     *
     *  @param unscaledWidth Specifies the width of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleX</code> property of the component.
     *
     *  @param unscaledHeight Specifies the height of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleY</code> property of the component.
     *
     *  @see mx.core.UIComponent#updateDisplayList()
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        if (selectedItemChanged)
        {
            selectedItem = selectedItem;
            selectedItemChanged = false;
            selectedIndexChanged = false;
        }

        if (selectedIndexChanged)
        {
            selectedIndex = selectedIndex;
            selectedIndexChanged = false;
        }
    }


    /**
     *  Determines the UID for a dataProvider item.
     *  Every dataProvider item must have or will be assigned a unique
     *  identifier (UID).
     *
     *  @param data A dataProvider item.
     *
     *  @return A unique identifier.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function itemToUID(data:Object):String
    {
        if (!data)
            return "null";

        return UIDUtil.getUID(data);
    }

    override protected function focusOutHandler(event:FocusEvent):void
    {
        super.focusOutHandler(event);

        var fm:IFocusManager = focusManager;

        if (fm && event.target == this)
            fm.defaultButtonEnabled = true;

        if (_editable)
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }

    /**
     *  Responds to changes to the data provider.  The component will adjust
     *  the <code>selectedIndex</code> property if items are added or removed
     *  before the component's selected item.
     *
     *  @param event The CollectionEvent dispatched from the collection.
     *
     *  @see mx.events.CollectionEvent
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function collectionChangeHandler(event:Event):void
    {
        if (event is CollectionEvent)
        {
            var requiresValueCommit:Boolean = false;

			var ce:CollectionEvent = CollectionEvent(event);
            if (ce.kind == CollectionEventKind.ADD)
            {
                if (selectedIndex >= ce.location)
                    _selectedIndex++;
            }
            if (ce.kind == CollectionEventKind.REMOVE)
            {
                for (var i:int = 0; i < ce.items.length; i++)
                {
                    var uid:String = itemToUID(ce.items[i]);
                    if (selectedUID == uid)
                    {
                        selectionChanged = true;
                    }
                }
                if (selectionChanged)
                {
                    if (_selectedIndex >= collection.length)
                        _selectedIndex = collection.length - 1;

                    selectedIndexChanged = true;
                    requiresValueCommit = true;
                    invalidateDisplayList();
                }
                else if (selectedIndex >= ce.location)
                {
                    _selectedIndex--;
                    selectedIndexChanged = true;
                    requiresValueCommit = true;
                    invalidateDisplayList();
                }

            }
            if (ce.kind == CollectionEventKind.REFRESH)
            {
                selectedItemChanged = true;
                // Sorting always changes the selection array
                requiresValueCommit = true;
            }

            invalidateDisplayList();

            if (requiresValueCommit)
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        }
    }

    /**
     *  Performs some action when the drop-down button is pressed.  This is
     *  an abstract base class implementation, so it has no effect and is
     *  overridden by the subclasses.
     *
     *  @param event The event that is triggered when the drop-down button is pressed.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function downArrowButton_buttonDownHandler(event:FlexEvent):void
    {
        // overridden by subclasses
    }
}
}
