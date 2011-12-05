package cocoa.keyboard {
import cocoa.text.EditableTextView;

import flash.display.InteractiveObject;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

import org.flyti.plexus.AbstractComponent;

public class KeyboardManager extends AbstractComponent {
  private var commandShortcuts:Dictionary;
  private var commandShiftShortcuts:Dictionary;
  private var shortcuts:Dictionary;

  private var clientBinder:ClientBinder = new ClientBinder();

  private var keymapLoaded:Boolean = false;

  public function loadKeymap(keymap:Vector.<KeymapItem>, activeProfiles:Vector.<uint>):void {
    shortcuts = new Dictionary();
    commandShortcuts = new Dictionary();
    commandShiftShortcuts = new Dictionary();

    clientBinder.eventShortcutMap = new Dictionary();

    for each (var item:KeymapItem in keymap) {
      var shortcutLabelRegistered:Boolean = false;
      for each (var shortcut:Shortcut in item.shortcuts) {
        if (shortcut.keymap == Shortcut.ANY_PROFILE || activeProfiles.indexOf(shortcut.keymap) != -1) {
          if (!shortcutLabelRegistered) {
            shortcutLabelRegistered = true;
            clientBinder.eventShortcutMap[item.event.type] = shortcut;
          }

          var map:Dictionary;
          if (shortcut.command) {
            if (shortcut.shift) {
              map = commandShiftShortcuts;
            }
            else {
              map = commandShortcuts;
            }
          }
          else {
            map = shortcuts;
          }

          var mapItem:Vector.<KeymapItem> = map[shortcut.code];
          if (mapItem == null) {
            map[shortcut.code] = new <KeymapItem>[item];
          }
          else {
            mapItem.fixed = false;
            mapItem[mapItem.length] = item;
          }
        }
      }
    }

    keymapLoaded = true;
    clientBinder.updateClients();
  }

  public function keyDownHandler(event:KeyboardEvent):void {
    if (!keymapLoaded) {
      return;
    }

    var items:Vector.<KeymapItem>;
    if (event.ctrlKey && !event.altKey) {
      if (event.shiftKey) {
        items = commandShiftShortcuts[event.keyCode];
      }
      else {
        items = commandShortcuts[event.keyCode];
      }
    }
    else {
      var editableText:EditableTextView = event.target as EditableTextView;
      if (editableText == null || !editableText.editable || (!editableText.multiline && event.keyCode == Keyboard.ESCAPE)) {
        items = shortcuts[event.keyCode];
      }
    }

    if (items != null) {
      for each (var item:KeymapItem in items) {
        dispatch(item, InteractiveObject(event.target));
      }
    }
  }

  public function bindShortcut(client:KeyboardManagerClient, eventMetadata:EventMetadata, states:Vector.<String> = null):void {
    clientBinder.bindShortcut(client, eventMetadata, states);
  }

  private function dispatch(item:KeymapItem, target:InteractiveObject):void {
    if (item.event.useContainerChain) {
      dispatchContextEvent(item.event.create());
    }
    else {
      target.dispatchEvent(item.event.create());
    }
  }
}
}