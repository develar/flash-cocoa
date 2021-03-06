package cocoa {
import cocoa.layout.CollectionLayout;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.RendererManagerFactory;
import cocoa.plaf.basic.SegmentedControlInteractor;
import cocoa.renderer.InteractiveRendererManager;
import cocoa.renderer.RendererManager;
import cocoa.util.Vectors;

import flash.display.DisplayObjectContainer;

import mx.core.IFactory;

import org.flyti.plexus.Injectable;
import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

public class SegmentedControl extends CollectionBody implements Injectable, ListSelectionModel {
  protected var border:Border;

  override public function getMaximumWidth(hHint:int = -1):int {
    return layout.getMaximumWidth(hHint);
  }

  override public function getMaximumHeight(wHint:int = -1):int {
    return layout.getMaximumHeight(wHint);
  }

  override public function getMinimumWidth(hHint:int = -1):int {
    return layout.getMinimumWidth(hHint);
  }

  override public function getMinimumHeight(wHint:int = -1):int {
    return layout.getMinimumHeight(wHint);
  }

  override public function getPreferredWidth(hHint:int = -1):int {
    return layout.getPreferredWidth(hHint);
  }

  override public function getPreferredHeight(wHint:int = -1):int {
    return layout.getPreferredHeight(wHint);
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

    var modifiableDataSource:ListViewMutableDataSource = _dataSource as ListViewMutableDataSource;
    if (modifiableDataSource != null) {
      modifiableDataSource.itemRemoved.remove(itemRemoved);
    }

    _dataSource = value;

    if ((modifiableDataSource = _dataSource as ListViewMutableDataSource) != null) {
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
    return mode == SelectionMode.ONE ? _selectedIndex == -1 : Vectors.isEmpty(selectedIndices);
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

    if (!Vectors.isEmpty(selectedIndices)) {
      if (Vectors.isEmpty(value)) {
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
    else if (!Vectors.isEmpty(value)) {
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

  private var _rendererManager:RendererManager;
  public function get rendererManager():RendererManager {
    return _rendererManager;
  }
  public function set rendererManager(value:RendererManager):void {
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
    return mode == SelectionMode.ONE ? selectedIndex == index : (!Vectors.isEmpty(selectedIndices) && selectedIndices.indexOf(index) != -1);
  }

  override public function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void {
    super.addToSuperview(displayObjectContainer, laf, superview);

    var rendererManager:RendererManager = this.rendererManager;
    if (rendererManager == null) {
      var factory:IFactory = laf.getFactory(_lafKey + ".rendererManager");
      rendererManager = factory is RendererManagerFactory ? RendererManagerFactory(factory).create(laf) : factory.newInstance();
      this.rendererManager = rendererManager;
    }

    if (layout == null) {
      layout = laf.getFactory((laf.controlSize == null ? "" : laf.controlSize + ".") + _lafKey + ".layout").newInstance();
    }

    rendererManager.container = this;
    if (rendererManager is InteractiveRendererManager) {
      InteractiveRendererManager(rendererManager).selectionModel = this;
    }
    else {
      mode = SelectionMode.NONE;
    }

    border = laf.getBorder(_lafKey + ".b", true);
    if (border != null) {
      layout.insets = border.contentInsets;
    }

    layout.rendererManager = rendererManager;
    layout.dataSource = dataSource;
    layout.container = this;

    if (mode != SelectionMode.NONE) {
      SegmentedControlInteractor(laf.getFactory(_lafKey + ".interactor").newInstance()).register(this);
    }
  }

  override protected function draw(w:int, h:int):void {
    if (border != null) {
      graphics.clear();
      border.draw(graphics, w, h);
    }

    layout.draw(w, h);
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
      if (_selectedIndices == null) {
        _selectedIndices = new Vector.<int>();
      }

      if (value) {
        selectedIndices[selectedIndices.length] = index;
      }
      else if (index == (selectedIndices.length - 1)) {
        selectedIndices.length = index;
      }
      else {
        selectedIndices.splice(selectedIndices.indexOf(index), 1);
      }

      if (layout != null) {
        layout.setSelected(index, -1, value);
      }

      if (_selectionChanged != null) {
        _selectionChanged.dispatch(value ? new <int>[index] : null, value ? null : new <int>[index]);
      }
    }
  }

  public function invalidateSize():void {
    invalidate(true);
  }
}
}