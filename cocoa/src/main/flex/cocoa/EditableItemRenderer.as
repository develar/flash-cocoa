package cocoa
{
import mx.controls.listClasses.IListItemRenderer;

public interface EditableItemRenderer extends IListItemRenderer
{
    function set editMode(value:Boolean):void;
    function get editMode():Boolean;
    function getEditableProperties():Array; //e.g. Array of objects {propHolder:Object, prop:String}
}
}