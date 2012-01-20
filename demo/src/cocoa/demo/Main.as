package cocoa.demo {
import cocoa.Container;
import cocoa.FocusManagerImpl;
import cocoa.Insets;
import cocoa.Label;
import cocoa.MigLayout;
import cocoa.ScrollView;
import cocoa.SegmentedControl;
import cocoa.TextInput;
import cocoa.Toolbar;
import cocoa.plaf.TextFormatId;
import cocoa.plaf.aqua.AquaLookAndFeel;
import cocoa.renderer.TextRendererManager;
import cocoa.tableView.TableColumn;
import cocoa.tableView.TableColumnImpl;
import cocoa.tableView.TableView;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;

import net.miginfocom.layout.ComponentWrapper;

public class Main extends Container {
  public function Main() {
    var layout:MigLayout = new MigLayout("flowy", "grow", "grow");
    laf = new AquaLookAndFeel();
    subviews = createComponents();
    this.layout = layout;

    setSize(stage.stageWidth, stage.stageHeight);
    validate();

    graphics.beginFill(0);
    graphics.drawRect(0, 0, 499, 499)
    
    stage.addEventListener(Event.RESIZE, stage_resizeHandler);

    new FocusManagerImpl().init(stage);
  }

  private function createComponents():Vector.<ComponentWrapper> {
    stage.scaleMode = StageScaleMode.NO_SCALE;
    stage.align = StageAlign.TOP_LEFT;

    var components:Vector.<ComponentWrapper> = new Vector.<ComponentWrapper>();
    var l1:Label = new Label();
    l1.title = "First Name";
    components[0] = l1;

    components[1] = createSC();

    var toolbar:Toolbar = new Toolbar();
    toolbar.small = true;
    toolbar.subviews = new <ComponentWrapper>[createSC()];
    components[2] = toolbar;

    //var scrollView:ScrollView = new ScrollView();
    var tableView:TableView = new TableView();
    tableView.c = "grow";
    tableView.lafSubkey = "small";
    tableView.dataSource = new DemoTableViewDataSource();
    var insets:Insets = new Insets(2, NaN, NaN, 3);
    var firstColumn:TableColumnImpl = new TableColumnImpl(tableView, 'a', new TextRendererManager(laf.getTextFormat(TextFormatId.SMALL_SYSTEM), insets));
    firstColumn.preferredWidth = 120;
    tableView.columns = new <TableColumn>[firstColumn, new TableColumnImpl(tableView, 'b', new TextRendererManager(laf.getTextFormat(TextFormatId.SMALL_SYSTEM), insets))];

    //scrollView.documentView = tableView;
    //components[components.length] = tableView;
    var textInput:TextInput = new TextInput();
    textInput.text = "f";
    components[components.length] = textInput;

    return components;
  }

  private static function createSC():SegmentedControl {
    var segmentedControl:SegmentedControl = new SegmentedControl();
    segmentedControl.dataSource = new DemoCollectionViewDataSource();
    return segmentedControl;
  }

  private function stage_resizeHandler(event:Event):void {
    var minimumWidth:int = getMinimumWidth();
    var w:int = Math.max(stage.stageWidth, minimumWidth);
    setSize(w, stage.stageHeight);
    validate();
  }
}
}