package cocoa.plaf.basic {
import flash.display.InteractiveObject;

public class OpenedEditorInfo {
  public var editor:InteractiveObject;

  public var rowIndex:int;
  public var columnIndex:int;

  public function OpenedEditorInfo(editor:InteractiveObject, columnIndex:int, rowIndex:int) {
    this.editor = editor;
    this.columnIndex = columnIndex;
    this.rowIndex = rowIndex;
  }
}
}
