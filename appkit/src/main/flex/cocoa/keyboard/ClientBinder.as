package cocoa.keyboard {
import flash.utils.Dictionary;

import mx.binding.utils.ChangeWatcher;
import mx.events.StateChangeEvent;

import org.flyti.util.HashMap;
import org.flyti.util.Map;

import spark.components.supportClasses.Skin;

public class ClientBinder {
  private var clients:Map = new HashMap(true);
  private var clientCurrentStatesMap:Map = new HashMap(true);

  internal var eventShortcutMap:Dictionary;

  public function bindShortcut(client:KeyboardManagerClient, eventMetadata:EventMetadata, states:Vector.<String> = null):void {
    if (clients == null) {
      clients = new HashMap(true);
      clientCurrentStatesMap = new HashMap(true);
    }

    var bindabilityInfo:ClientBindabilityInfo;
    if (clients.containsKey(client)) {
      var bindabilityInfoList:Vector.<ClientBindabilityInfo> = Vector.<ClientBindabilityInfo>(clients.get(client));
      var alreadyBinded:Boolean = isAlreadyBinded(bindabilityInfoList, eventMetadata, states);
      assert(!alreadyBinded);
      if (!alreadyBinded) {
        bindabilityInfo = new ClientBindabilityInfo(eventMetadata, states);
        bindabilityInfoList.push(bindabilityInfo);
      }
    }
    else {
      bindabilityInfo = new ClientBindabilityInfo(eventMetadata, states);
      clients.put(client, new <ClientBindabilityInfo>[bindabilityInfo]);

      if (states != null) {
        ChangeWatcher.watch(client, ["skin", "currentState"], clientStateChangeHandler, false, true);
      }
    }

    updateClient(client, bindabilityInfo);
  }

  private function clientStateChangeHandler(event:StateChangeEvent):void {
    var client:KeyboardManagerClient = KeyboardManagerClient(Skin(event.target).owner);
    if (clientCurrentStatesMap.get(client).indexOf(event.newState) == -1) {
      for each (var bindabilityInfo:ClientBindabilityInfo in clients.get(client)) {
        if (updateClient(client, bindabilityInfo)) {
          break;
        }
      }
    }
  }

  public function updateClients():void {
    if (clients != null) {
      for each (var client:KeyboardManagerClient in clients.keySet) {
        for each (var bindabilityInfo:ClientBindabilityInfo in clients.get(client)) {
          if (updateClient(client, bindabilityInfo)) {
            break;
          }
        }
      }
    }
  }

  private function updateClient(client:KeyboardManagerClient, bindabilityInfo:ClientBindabilityInfo):Boolean {
    if (bindabilityInfo.states == null ||
            (bindabilityInfo.states.indexOf(client.skin.currentState) != -1 && (!clientCurrentStatesMap.containsKey(client) || clientCurrentStatesMap.get(client) != bindabilityInfo.states))) {
      client.shortcut = generateShortcutLabel(bindabilityInfo.eventMetadata);
      clientCurrentStatesMap.put(client, bindabilityInfo.states);
      return true;
    }

    return false;
  }

  private function isAlreadyBinded(bindabilityInfoList:Vector.<ClientBindabilityInfo>, eventMetadata:EventMetadata, states:Vector.<String>):Boolean {
    for each (var bindabilityInfo:ClientBindabilityInfo in bindabilityInfoList) {
      if (bindabilityInfo.eventMetadata == eventMetadata && bindabilityInfo.states == states) {
        return true;
      }
    }

    return false;
  }

  private function generateShortcutLabel(event:EventMetadata):String {
    var shortcut:Shortcut = eventShortcutMap[event.type];
    if (shortcut == null) {
      return null;
    }
    else {
      return ShortcutUtil.generateLabel(shortcut);
    }
  }
}
}