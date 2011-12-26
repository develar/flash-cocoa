package cocoa.renderer {
import cocoa.Border;
import cocoa.View;
import cocoa.pane.PaneItem;
import cocoa.plaf.LookAndFeel;
import cocoa.text.TextFormat;

import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.engine.TextLine;

public class PaneRendererManager extends TextRendererManager {
  private var border:Border;
  private var laf:LookAndFeel;
 
  private const paneTitleEntryFactory:TextLineAndDisplayObjectEntryFactory = new TextLineAndDisplayObjectEntryFactory(Shape, true);
 
  public function PaneRendererManager(textFormat:TextFormat, border:Border, laf:LookAndFeel) {
    super(textFormat, border.contentInsets);
 
    this.border = border;
    this.laf = laf;
    registerEntryFactory(paneTitleEntryFactory);
  }
 
  protected var titleCanvasContainer:Sprite;
 
  override public function set container(value:DisplayObjectContainer):void {
    super.container = value;
 
    if (titleCanvasContainer == null) {
      titleCanvasContainer = new Sprite();
      titleCanvasContainer.mouseEnabled = false;
      titleCanvasContainer.mouseChildren = false;
    }
 
    value.addChild(titleCanvasContainer);
  }
 
  override protected function createEntry(itemIndex:int, x:Number, y:Number, w:int, h:int):TextLineEntry {
    var line:TextLine = createTextLine(itemIndex, w);
    layoutTextLine(line, x, y, border.layoutHeight);
 
    var e:TextLineAndDisplayObjectEntry = paneTitleEntryFactory.create(line);
    var shape:Shape = Shape(e.displayObject);
    if (shape.parent != titleCanvasContainer) {
      titleCanvasContainer.addChild(shape);
    }
    
    shape.y = y;
    shape.x = x;
    var g:Graphics = shape.graphics;
    g.clear();
    border.draw(g, w, border.layoutHeight);
 
    var item:PaneItem = PaneItem(_dataSource.getObjectValue(itemIndex));
    var view:View = item.view;
    if (view == null) {
      var viewFactory:ViewFactory = ViewFactory(item.viewFactory);
      view = viewFactory.create(laf, _container);
      item.view = view;
    }

    var viewHeight:int = view.getPreferredHeight();
    view.setBounds(x, y, w, viewHeight);
    view.validate();

    _lastCreatedRendererDimension = border.layoutHeight + viewHeight;
    return e;
  }

  override protected function entryMoved(e:TextLineEntry, isChangeWidth:Boolean):void {
    var item:PaneItem = PaneItem(_dataSource.getObjectValue(e.itemIndex));
    var view:View = item.view;
    if (view != null) {
      if (isChangeWidth) {
        view.setLocation(view.x + _lastCreatedRendererDimension, view.y);
      }
      else {
        view.setLocation(view.x, view.y + _lastCreatedRendererDimension);
      }
    }
  }
}
}
