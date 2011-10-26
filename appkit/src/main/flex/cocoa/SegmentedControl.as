package cocoa {
import cocoa.layout.CollectionLayout;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelUtil;
import cocoa.plaf.Skin;
import cocoa.plaf.basic.SegmentedControlInteractor;
import cocoa.renderer.InteractiveRendererManager;

import flash.display.DisplayObject;

import org.flyti.plexus.Injectable;
import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

public class SegmentedControl extends CollectionBody implements Injectable, ListSelectionModel {
  public var stupidMxmlId:String;

  private static function isEmpty(v:Vector.<int>):Boolean {
    return v == null || v.length == 0;
  }

  public function get hidden():Boolean {
    return !visible && !includeInLayout;
  }

  public function set hidden(value:Boolean):void {
    visible = !value;
    includeInLayout = !value;
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
    if (_dataSource == value) {
      return;
    }

    var modifiableDataSource:ListViewModifiableDataSource = _dataSource as ListViewModifiableDataSource;
    if (modifiableDataSource != null) {
      modifiableDataSource.itemRemoved.remove(itemRemoved);
    }

    _dataSource = value;

    if ((modifiableDataSource = _dataSource as ListViewModifiableDataSource) != null) {
      modifiableDataSource.itemRemoved.add(itemRemoved);
    }

    if (layout != null) {
      layout.dataSource = value;
    }
  }

  private function itemRemoved(item:Object, index:int):void {
    if (!isItemSelected(index)) {
      if (_selectedIndex > index) {
        _selectedIndex--;
      }
      return;
    }

    if (mode == SelectionMode.ONE) {
      _selectedIndex = dataSource.itemCount > index ? index : (dataSource.itemCount - 1);
      if (_selectionChanged != null) {
        _selectionChanged.dispatch(item, _selectedIndex == -1 ? null : dataSource.getObjectValue(_selectedIndex), index, _selectedIndex);
      }
    }
    else {
      setSelected(index, false);
    }
  }

  public function get isSelectionEmpty():Boolean {
    return mode == SelectionMode.ONE ? _selectedIndex == -1 : isEmpty(selectedIndices);
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

  protected var _lafKey:String = "SegmentedControl";
  public function set lafKey(value:String):void {
    _lafKey = value;
  }

  public function isItemSelected(index:int):Boolean {
    return mode == SelectionMode.ONE ? selectedIndex == index : (!isEmpty(selectedIndices) && selectedIndices.indexOf(index) != -1);
  }

  override protected function createChildren():void {
    var laf:LookAndFeel = LookAndFeelUtil.find(parent);
    if (layout == null) {
      layout = laf.getFactory(_lafKey + ".layout").newInstance();
    }

    var rendererManager:InteractiveRendererManager = this.rendererManager;
    if (rendererManager == null) {
      rendererManager = laf.getFactory(_lafKey + ".rendererManager").newInstance();
      this.rendererManager = rendererManager;
    }

    rendererManager.container = this;
    rendererManager.selectionModel = this;

    layout.rendererManager = rendererManager;
    layout.dataSource = dataSource;
    layout.container = this;

    if (mode != SelectionMode.NONE) {
      SegmentedControlInteractor(laf.getFactory(_lafKey + ".interactor").newInstance()).register(this);
    }

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
    layout.measure();
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    layout.layout(w, h);
  }

  public function setSelected(index:int, value:Boolean):void {
    if (mode == SelectionMode.ONE) {
      if (index == _selectedIndex) {
        return;
      }

      var oldSelectedIndex:int = _selectedIndex;
      _selectedIndex = index;

      if (oldSelectedIndex != -1) {
        layout.setSelected(oldSelectedIndex, _selectedIndex, false);
      }
      if (_selectedIndex != -1) {
        layout.setSelected(_selectedIndex, oldSelectedIndex, true);
      }
      
      if (_selectionChanged != null) {
        _selectionChanged.dispatch(oldSelectedIndex == -1 ? null : dataSource.getObjectValue(oldSelectedIndex), _selectedIndex == -1 ? null : dataSource.getObjectValue(_selectedIndex), oldSelectedIndex, _selectedIndex);
      }
    }
    else {
      if (value) {
        selectedIndices.push(index);
      }
      else {
        selectedIndices.splice(selectedIndices.indexOf(index), 1);
      }

      layout.setSelected(index, -1, value);

      if (_selectionChanged != null) {
        _selectionChanged.dispatch(value ? new <int>[index] : null, value ? null : new <int>[index]);
      }
    }
  }
}
}