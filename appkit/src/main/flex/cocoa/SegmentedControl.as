package cocoa {
import cocoa.layout.CollectionLayout;
import cocoa.layout.ListHorizontalLayout;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelUtil;
import cocoa.plaf.Skin;
import cocoa.plaf.basic.SegmentedControlInteractor;
import cocoa.renderer.InteractiveRendererManager;

import flash.display.DisplayObject;

import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

public class SegmentedControl extends AbstractView {
  public static function isEmpty(v:Vector.<int>):Boolean {
    return v == null || v.length == 0;
  }

  private var _mode:int = SelectionMode.ONE;
  public function get mode():int {
    return _mode;
  }
  public function set mode(value:int):void {
    _mode = value;
  }

  private var _dataSource:ListViewDataSource;
  public function get dataSource():ListViewDataSource {
    return _dataSource;
  }
  public function set dataSource(value:ListViewDataSource):void {
    _dataSource = value;
  }

  private var _selectedIndices:Vector.<int>;
  public function get selectedIndices():Vector.<int> {
    return _selectedIndices;
  }

  public function set selectedIndices(value:Vector.<int>):void {
    if (value == selectedIndices) {
      return;
    }

    var addedItems:Vector.<int> = new Vector.<int>();
    var removedItems:Vector.<int> = new Vector.<int>();
    var i:int;
    var n:int;

    if (!isEmpty(selectedIndices)) {
      if (isEmpty(value)) {
        // Going to a null selection, remove all
        removedItems = _selectedIndices;
      }
      else {
        // Changing selection, determine which items were added to the selection interval
        n = value.length;
        for (i = 0; i < n; i++) {
          if (selectedIndices.indexOf(value[i]) == -1) {
            addedItems.push(value[i]);
          }
        }
        // Then determine which items were removed from the selection interval
        n = selectedIndices.length;
        for (i = 0; i < n; i++) {
          if (value.indexOf(selectedIndices[i]) == -1) {
            removedItems.push(selectedIndices[i]);
          }
        }
      }
    }
    else if (!isEmpty(value)) {
      // Going from a null selection, add all
      addedItems = value;
    }

    for (i = 0, n = addedItems.length; i < n; i++) {
      rendererManager.setSelected(addedItems[i], true);
    }
    for (i = 0, n = removedItems.length; i < n; i++) {
      rendererManager.setSelected(removedItems[i], false);
    }

    _selectedIndices = value;

    if (_selectionChanged != null) {
      _selectionChanged.dispatch(addedItems, removedItems);
    }
  }

  private var _selectedIndex:int = -1;
  public function get selectedIndex():int {
    return _selectedIndex;
  }

  public function set selectedIndex(value:int):void {
    setSelected(value, true);
  }

  private var _layout:CollectionLayout;
  public function get layout():CollectionLayout {
    return _layout;
  }
  public function set layout(value:CollectionLayout):void {
    _layout = value;
  }

  private var _rendererManager:InteractiveRendererManager;
  public function get rendererManager():InteractiveRendererManager {
    return _rendererManager;
  }
  public function set rendererManager(value:InteractiveRendererManager):void {
    _rendererManager = value;
  }

  protected var _selectionChanged:ISignal;
  public function get selectionChanged():ISignal {
    if (_selectionChanged == null) {
      _selectionChanged = new Signal();
    }
    return _selectionChanged;
  }

  private var _lafKey:String = "SegmentedControl";
  public function set lafKey(value:String):void {
    _lafKey = value;
  }

  public function isItemSelected(index:int):Boolean {
    return mode == SelectionMode.ONE ? selectedIndex == index : (!isEmpty(selectedIndices) && selectedIndices.indexOf(index) != -1);
  }

  override protected function createChildren():void {
    if (layout == null) {
      layout = new ListHorizontalLayout();
    }

    var laf:LookAndFeel = LookAndFeelUtil.find(parent);
    var rendererManager:InteractiveRendererManager = this.rendererManager;
    if (rendererManager == null) {
      rendererManager = laf.getFactory(_lafKey + ".rendererManager").newInstance();
      this.rendererManager = rendererManager;
    }

    rendererManager.dataSource = dataSource;
    rendererManager.container = this;

    layout.dataSource = dataSource;
    layout.rendererManager = rendererManager;
    layout.container = this;

    SegmentedControlInteractor(laf.getFactory(_lafKey + ".interactor").newInstance()).register(this);

    super.createChildren();
  }

  override public function addChild(child:DisplayObject):DisplayObject {
    child is Skin ? super.addChild(child) : addDisplayObject(child);
    return child;
  }

  override public function removeChild(child:DisplayObject):DisplayObject {
    child is Skin ? super.removeChild(child) : removeDisplayObject(child);
    return child;
  }

  override protected function measure():void {
    layout.measure(this);
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    layout.updateDisplayList(w, h);
  }

  public function setSelected(index:int, value:Boolean):void {
    if (mode == SelectionMode.ONE) {
      if (index == _selectedIndex) {
        return;
      }

      if (_selectedIndex != -1) {
        rendererManager.setSelected(_selectedIndex, false);
      }

      var oldSelectedIndex:int = _selectedIndex;
      _selectedIndex = index;

      if (_selectedIndex != -1) {
        rendererManager.setSelected(_selectedIndex, true);
      }

      if (_selectionChanged != null) {
        _selectionChanged.dispatch(oldSelectedIndex, _selectedIndex);
      }
    }
    else {
      if (value) {
        selectedIndices.push(index);
      }
      else {
        selectedIndices.splice(selectedIndices.indexOf(index), 1);
      }

      if (_selectionChanged != null) {
        _selectionChanged.dispatch(value ? null : new <int>[index], value ? new <int>[index] : null);
      }
    }
  }
}
}