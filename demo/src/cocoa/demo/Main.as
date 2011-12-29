package cocoa.demo {
import cocoa.Container;
import cocoa.Label;
import cocoa.MigLayout;
import cocoa.ScrollView;
import cocoa.SegmentedControl;
import cocoa.Toolbar;
import cocoa.plaf.aqua.AquaLookAndFeel;

import flash.display.StageAlign;
import flash.display.StageScaleMode;

import net.miginfocom.layout.ComponentWrapper;

public class Main extends Container {
  public function Main() {
    var layout:MigLayout = new MigLayout("flowy", "", "");
    laf = new AquaLookAndFeel();
    subviews = createComponents();
    this.layout = layout;

    //setSize(stage.stageWidth, stage.stageHeight);
    validate();
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

    var scrollView:ScrollView = new ScrollView();
    scrollView.documentView = createSC();
    components[components.length] = scrollView;

    return components;
  }

  private static function createSC():SegmentedControl {
    var segmentedControl:SegmentedControl = new SegmentedControl();
    segmentedControl.dataSource = new DemoCollectionViewDataSource();
    return segmentedControl;
  }
}
}