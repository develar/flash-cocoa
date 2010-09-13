package cocoa.plaf {
import cocoa.ScrollView;

public interface ListViewSkin {
  function set verticalScrollPolicy(value:uint):void;

  function set horizontalScrollPolicy(value:uint):void;

  function set laf(value:LookAndFeel):void;

  function set bordered(value:Boolean):void;

  function get scrollView():ScrollView;
}
}