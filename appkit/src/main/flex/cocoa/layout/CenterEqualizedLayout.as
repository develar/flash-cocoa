package cocoa.layout {
import cocoa.CheckBox;
import cocoa.Component;
import cocoa.Label;
import cocoa.SliderNumericStepper;
import cocoa.VSeparator;
import cocoa.plaf.Skin;

import flash.events.Event;

import mx.core.ILayoutElement;
import mx.core.IUIComponent;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;

/**
 * https://astra.rit.com:8443/display/~v.krivosheev/Cocoa+lib+and+Aqua+LaF+for+Flex#CocoalibandAquaLaFforFlex-Layout
 */
public class CenterEqualizedLayout extends LayoutBase {
  private var columns:Vector.<Column>;

  private var _fieldGap:Number = 8;
  /**
   * Расстояние вертикальное между полями
   */
  public function get fieldGap():Number {
    return _fieldGap;
  }

  public function set fieldGap(value:Number):void {
    if (value != _fieldGap) {
      _fieldGap = value;
    }
  }

  private var _labelBelow:Boolean;
  public function set labelBelow(value:Boolean):void {
    _labelBelow = value;
  }

  private var _maxRowCount:int = 99;
  public function get maxRowCount():int {
    return _maxRowCount;
  }

  public function set maxRowCount(value:int):void {
    _maxRowCount = value;
  }

  protected function get isRightAlignLabel():Boolean {
    return true;
  }

  /**
   * Промежуток между controls в колонке
   */
  private var _controlGap:Number = 3;
  public function set controlGap(value:Number):void {
    if (value != _controlGap) {
      _controlGap = value;
    }
  }

  private var _controlWidth:Number;
  public function set controlWidth(value:Number):void {
    if (value != _controlWidth) {
      _controlWidth = value;
    }
  }

  private var _labelGap:Number = 6;
  public function set labelGap(value:Number):void {
    if (value != _labelGap) {
      _labelGap = value;
    }
  }

  private var _columnGap:int = 6;
  /**
   * Промежуток между колонками, игнорируется при явно вставленном разделителе
   */
  public function set columnGap(value:int):void {
    _columnGap = value;
  }

  private var _useEnableCheckBox:Boolean = true;
  public function set useEnableCheckBox(value:Boolean):void {
    _useEnableCheckBox = value;
  }

  override public function measure():void {
    var layoutTarget:GroupBase = target;
    if (layoutTarget == null) {
      return;
    }

    if (columns == null) {
      columns = new Vector.<Column>();
    }
    else {
      columns.fixed = false;
      columns.length = 0;
    }

    var measuredWidth:Number = 0;
    var measuredHeight:Number = 0;

    var effectiveMaxRowCount:int = maxRowCount;

    var column:Column;
    const numElements:int = target.numElements;
    var i:int = 0;
    var oldColumn:Column;
    while (true) {
      var element:ILayoutElement = layoutTarget.getElementAt(i++);
      assert(element != null);
      if (element is Skin && Skin(element).component is VSeparator) {
        column.separator = Skin(element);
        oldColumn = column;
        column = null;

        measuredWidth += element.getPreferredBoundsWidth();

        effectiveMaxRowCount = maxRowCount; // see about share first auxiliaryElement
      }
      else {
        var skipAdd:Boolean = false;
        if (isStartElement(element)) {
          if (column == null || column.compositions.length == effectiveMaxRowCount) {
            if (column != null && column.separator == null) {
              measuredWidth += _columnGap;
            }
            oldColumn = column;
            column = new Column();
          }

          if (column.maxControlLengthInComposition > 1 &&
                  (i == numElements || ((column.compositions.length + 1) == effectiveMaxRowCount && isAnotherColumnElement(layoutTarget.getElementAt(i))))) {
            column.auxiliaryElement = element;
            skipAdd = true;
          }
          // проверка на first auxiliary element — в данный момент считаем что он должен быть первым в композиции
          else if (_useEnableCheckBox && i == 1 && numElements > 2 && isCheckBox(element) && !isCheckBox(layoutTarget.getElementAt(i + 1))) {
            column.auxiliaryElement = element;
            column.isAuxiliaryElementFirst = true;
            effectiveMaxRowCount--;
            continue;
          }
          else {
            column.addComposition();
          }
        }

        if (!skipAdd) {
          column.addElement(element, _controlWidth);
        }
      }

      if (i == numElements) {
        oldColumn = column;
      }

      if (oldColumn != null) {
        columns[columns.length] = oldColumn;
        oldColumn.finalize();
        measuredWidth += oldColumn.calculateTotalWidth(_labelGap, _controlGap, _labelBelow);

        const currentHeight:Number = oldColumn.calculateTotalHeight(fieldGap, _labelBelow);
        if (currentHeight > measuredHeight) {
          measuredHeight = currentHeight;
        }

        if (i == numElements) {
          break;
        }

        oldColumn = null;
      }
    }

    columns.fixed = true;

    layoutTarget.measuredWidth = measuredWidth;
    layoutTarget.measuredHeight = measuredHeight;
  }

  private function isAnotherColumnElement(element:ILayoutElement):Boolean {
    return element is Skin && Skin(element).component is VSeparator || isStartElement(element);
  }

  private function isStartElement(element:ILayoutElement):Boolean {
    return element is Label /* control не может состоять только из Label, поэтому дальше явно часть текущего control, а не новый */ || isLabeledControl(element);
  }

  private function isLabeledControl(element:ILayoutElement):Boolean {
    if (element is Skin) {
      var component:Component = Skin(element).component;
      return (component is CheckBox && CheckBox(component).title != null) || (component is SliderNumericStepper && SliderNumericStepper(component).title != null);
    }
    else {
      return false;
    }
  }

  private function isCheckBox(element:ILayoutElement):Boolean {
    return element is Skin && Skin(element).component is CheckBox;
  }

  override public function updateDisplayList(w:Number, h:Number):void {
    var layoutTarget:GroupBase = target;
    if (layoutTarget == null) {
      return;
    }

    var lastFirstAuxiliaryElement:Skin;

    var x:Number = layoutTarget.measuredWidth == w ? 0 : ((w - layoutTarget.measuredWidth) / 2);
    for each (var column:Column in columns) {
      var localY:Number = 0;
      const columnCompositionsLength:int = column.compositions.length;
      if (column.isAuxiliaryElementFirst) {
        column.auxiliaryElement.setLayoutBoundsPosition(x, localY);
        column.auxiliaryElement.setLayoutBoundsSize(NaN, NaN);

        lastFirstAuxiliaryElement = Skin(column.auxiliaryElement);
      }

      if (lastFirstAuxiliaryElement != null) {
        localY += lastFirstAuxiliaryElement.getPreferredBoundsHeight() + fieldGap;
      }

      for (var compositionIndex:int = 0; compositionIndex < columnCompositionsLength; compositionIndex++) {
        var localX:Number = x;
        const compositionHeight:Number = column.heights[compositionIndex];
        var composition:Vector.<ILayoutElement> = column.compositions[compositionIndex];
        for (var elementIndex:int = 0; elementIndex < composition.length; elementIndex++) {
          if (elementIndex == 1) {
            localX += _labelGap;
          }

          var element:ILayoutElement = composition[elementIndex];
          if (!isRightAlignLabel || elementIndex != 0) {
            element.setLayoutBoundsPosition(localX, localY + ((compositionHeight - element.getPreferredBoundsHeight()) / 2));
          }

          if (elementIndex == 0) {
            var columnPartWidth:Number = column.labelMaxWidth;
            if (isRightAlignLabel) {
              element.setLayoutBoundsPosition(composition.length == 1 ? (localX + columnPartWidth + _labelGap) : (localX + columnPartWidth - element.getPreferredBoundsWidth()),
                      localY + ((compositionHeight - element.getPreferredBoundsHeight()) / 2));
            }

            localX += columnPartWidth;
          }
          else {
            localX += element.getPreferredBoundsWidth() + _controlGap;
          }

          element.setLayoutBoundsSize(_controlWidth, NaN);
        }

        localY += compositionHeight + fieldGap;
      }

      if (!column.isAuxiliaryElementFirst && column.auxiliaryElement != null) {
        column.auxiliaryElement.setLayoutBoundsPosition(x, localY);
        column.auxiliaryElement.setLayoutBoundsSize(NaN, NaN);
      }

      x += column.totalWidth;
      var separator:Skin = column.separator;
      if (separator == null) {
        x += _columnGap;
      }
      else {
        separator.setLayoutBoundsPosition(x, 0);
        separator.setLayoutBoundsSize(NaN, NaN);

        x += separator.getPreferredBoundsWidth();

        lastFirstAuxiliaryElement = null;
      }
    }

    if (lastFirstAuxiliaryElement != null && monitoredSelectionControl == lastFirstAuxiliaryElement.component) {
      return;
    }

    if (monitoredSelectionControl != null) {
      monitoredSelectionControl.removeEventListener("selectedChanged", selectionControlStateChanged);
      monitoredSelectionControl.removeEventListener("enabledChanged", selectionControlStateChanged);
      monitoredSelectionControl = null;
    }

    // в настоящее время мы поддерживаем только валидация на один firstAuxiliaryElement для всех колонок
    if (lastFirstAuxiliaryElement != null) {
      monitoredSelectionControl = CheckBox(lastFirstAuxiliaryElement.component);
      monitoredSelectionControl.addEventListener("selectedChanged", selectionControlStateChanged);
      monitoredSelectionControl.addEventListener("enabledChanged", selectionControlStateChanged);
      selectionControlStateChanged();
    }
  }

  private var monitoredSelectionControl:CheckBox;

  private function selectionControlStateChanged(event:Event = null):void {
    var enabled:Boolean = monitoredSelectionControl.selected && monitoredSelectionControl.enabled;
    for each (var column:Column in columns) {
      for each (var elements:Vector.<ILayoutElement> in column.compositions) {
        // только первый, в композиции Label: CheckBox ColorPicker мы отвечаем только за enable CheckBox
        // проверка на длину нужна для таких контролов как SliderNumericStepper с label
        IUIComponent(elements[elements.length == 1 ? 0 : 1]).enabled = enabled;
      }

      if (!column.isAuxiliaryElementFirst && column.auxiliaryElement != null) {
        IUIComponent(column.auxiliaryElement).enabled = enabled;
      }
    }
  }
}
}