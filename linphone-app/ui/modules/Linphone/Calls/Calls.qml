import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

import 'Calls.js' as Logic

// =============================================================================
Column{
    id:mainList
    property alias conferenceModel : conferenceCalls.model
    property alias simpleCallModel : calls.model
    property var selectedCall   // only one selected Call

    ListView {
    id: calls
    
      // ---------------------------------------------------------------------------
    
      property alias _selectedCall : mainList.selectedCall
    
      // ---------------------------------------------------------------------------
    
      boundsBehavior: Flickable.StopAtBounds
      clip: true
      spacing: 0
      width:parent.width
      height:count*CallControlsStyle.height 
      // ---------------------------------------------------------------------------
    
      onCountChanged: {Logic.handleCountChanged(calls, count); console.log(count);
        }
    
      Connections {
        target: calls.model
    
        onCallRunning: Logic.handleCallRunning(calls, callModel)
        onRowsAboutToBeRemoved: Logic.handleRowsAboutToBeRemoved(calls, first, last)
        onRowsInserted: Logic.handleRowsInserted(calls, first, last)
      }
    
      // ---------------------------------------------------------------------------
    
      Component {
        id: callAction
    
        ActionButton {
          icon: params.icon || 'generic_error'
          iconSize: CallsStyle.entry.iconActionSize
    
          onClicked: params.handler()
        }
      }
    
      Component {
        id: callActions
    
        ActionButton {
          id: button
    
          icon: calls.currentIndex === callId && call.status !== CallModel.CallStatusEnded
            ? 'burger_menu_light'
            : 'burger_menu'
          iconSize: CallsStyle.entry.iconMenuSize
    
          onClicked: menu.open()
    
          DropDownStaticMenu {
            id: menu
    
            relativeTo: callControls
            relativeX: callControls.width
    
            entryHeight: CallsStyle.entry.height
            entryWidth: CallsStyle.entry.width
    
            Repeater {
              model: params ? params.actions : []
    
              DropDownStaticMenuEntry {
                entryName: modelData.name
    
                onClicked: {
                  menu.close()
                  params.actions[index].handler()
                }
              }
            }
          }
        }
      }
    
      // ---------------------------------------------------------------------------
      // Calls.
      // ---------------------------------------------------------------------------
    
      delegate: CallControls {
        id: _callControls
    
        // -------------------------------------------------------------------------
    
        function useColorStatus () {
          return calls.currentIndex === index && $call && $call.status !== CallModel.CallStatusEnded
        }
    
        // -------------------------------------------------------------------------
    
        color: useColorStatus()
          ? CallsStyle.entry.color.selected
          : CallsStyle.entry.color.normal
        sipAddressColor: useColorStatus()
          ? CallsStyle.entry.sipAddressColor.selected
          : CallsStyle.entry.sipAddressColor.normal
        usernameColor: useColorStatus()
          ? CallsStyle.entry.usernameColor.selected
          : CallsStyle.entry.usernameColor.normal
    
        signIcon: {
          var params = loader.params
          return params ? 'call_sign_' + params.string : ''
        }
    
        peerAddress: $call.peerAddress
        localAddress: $call.localAddress
    
        width: parent.width
    
        onClicked: {
          if ($call.status !== CallModel.CallStatusEnded) {
            Logic.updateSelectedCall(calls, $call, index)
          }
        }
    
        // -------------------------------------------------------------------------
    
        Loader {
          id: loader
    
          readonly property int callId: index
    
          readonly property var call: $call
          readonly property var callControls: _callControls
          readonly property var params: Logic.getParams($call)
    
          anchors.centerIn: parent
          sourceComponent: params ? params.component : null
        }
    
        SequentialAnimation on color {
          loops: CallsStyle.entry.endCallAnimation.loops
          running: !$call || $call.status === CallModel.CallStatusEnded
    
          ColorAnimation {
            duration: CallsStyle.entry.endCallAnimation.duration
            from: CallsStyle.entry.color.normal
            to: CallsStyle.entry.endCallAnimation.blinkColor
          }
    
          ColorAnimation {
            duration: CallsStyle.entry.endCallAnimation.duration
            from: CallsStyle.entry.endCallAnimation.blinkColor
            to: CallsStyle.entry.color.normal
          }
        }
      }
    }
    ListView {
      id: conferenceCalls
    
      // ---------------------------------------------------------------------------
    
      property alias _selectedCall : mainList.selectedCall
    
      // ---------------------------------------------------------------------------
     
      boundsBehavior: Flickable.StopAtBounds
      clip: true
      spacing: 0
      width:parent.width
      height:count*CallControlsStyle.height + headerItem.height
      // ---------------------------------------------------------------------------
      
      onCountChanged: {{Logic.handleCountChanged(conferenceCalls, count);
        }}
    
      Connections {
        target: conferenceCalls.model
    
        onCallRunning: Logic.handleCallRunning(conferenceCalls, callModel)
        onRowsAboutToBeRemoved: Logic.handleRowsAboutToBeRemoved(conferenceCalls, first, last)
        onRowsInserted: Logic.handleRowsInserted(conferenceCalls, first, last)
      }
    
      // ---------------------------------------------------------------------------
    
      Component {
        id: conferenceCallAction
    
        ActionButton {
          icon: params.icon || 'generic_error'
          iconSize: CallsStyle.entry.iconActionSize
    
          onClicked: params.handler()
        }
      }
    
      Component {
        id: conferenceCallActions
    
        ActionButton {
          id: button
    
          icon: conferenceCalls.currentIndex === callId && call.status !== CallModel.CallStatusEnded
            ? 'burger_menu_light'
            : 'burger_menu'
          iconSize: CallsStyle.entry.iconMenuSize
    
          onClicked: menu.open()
    
          DropDownStaticMenu {
            id: menu
    
            relativeTo: callControls
            relativeX: callControls.width
    
            entryHeight: CallsStyle.entry.height
            entryWidth: CallsStyle.entry.width
    
            Repeater {
              model: params ? params.actions : []
    
              DropDownStaticMenuEntry {
                entryName: modelData.name
    
                onClicked: {
                  menu.close()
                  params.actions[index].handler()
                }
              }
            }
          }
        }
      }
    
      // ---------------------------------------------------------------------------
      // Conference.
      // ---------------------------------------------------------------------------
    
      header: ConferenceControls {
        readonly property bool isSelected: conferenceCalls.currentIndex === -1 && conferenceCalls._selectedCall == null
    
        width: parent.width
    
        visible: conferenceCalls.model.count > 0
    
        color: isSelected
          ? CallsStyle.entry.color.selected
          : CallsStyle.entry.color.normal
    
        textColor: isSelected
          ? CallsStyle.entry.usernameColor.selected
          : CallsStyle.entry.usernameColor.normal
    
        onClicked: Logic.resetSelectedCall(conferenceCalls)
        onVisibleChanged: {!visible && Logic.handleCountChanged(conferenceCalls, conferenceCalls.count); 
            }
        }
    
      // ---------------------------------------------------------------------------
      // Calls.
      // ---------------------------------------------------------------------------
    
      delegate: CallControls {
        id: _conferenceCallControls
    
        // -------------------------------------------------------------------------
    
        function useColorStatus () {
          return conferenceCalls.currentIndex === index && $call && $call.status !== CallModel.CallStatusEnded
        }
    
        // -------------------------------------------------------------------------
    
        color: useColorStatus()
          ? CallsStyle.entry.color.selected
          : CallsStyle.entry.color.normal
        sipAddressColor: useColorStatus()
          ? CallsStyle.entry.sipAddressColor.selected
          : CallsStyle.entry.sipAddressColor.normal
        usernameColor: useColorStatus()
          ? CallsStyle.entry.usernameColor.selected
          : CallsStyle.entry.usernameColor.normal
        conferenceModel: conferenceCalls.model
    
        signIcon: {
          var params = conferenceLoader.params
          return params ? 'call_sign_' + params.string : ''
        }
        
        call: $call
        peerAddress: $call.peerAddress
        localAddress: $call.localAddress
        showSpeakerMeter:true
        width: parent.width
    
        onClicked: {
          if ($call.status !== CallModel.CallStatusEnded) {
            console.log($call.status+' '+$call.localAddress+' '+$call.peerAddress)
            Logic.updateSelectedCall(conferenceCalls, $call, index)
          }
        }
    
        // -------------------------------------------------------------------------
    
        Loader {
          id: conferenceLoader
    
          readonly property int callId: index
    
          readonly property var call: $call
          readonly property var callControls: _conferenceCallControls
          readonly property var params: Logic.getParams($call)
    
          anchors.centerIn: parent
          sourceComponent: params ? params.component : null
        }
    
        SequentialAnimation on color {
          loops: CallsStyle.entry.endCallAnimation.loops
          running: !$call || $call.status === CallModel.CallStatusEnded
    
          ColorAnimation {
            duration: CallsStyle.entry.endCallAnimation.duration
            from: CallsStyle.entry.color.normal
            to: CallsStyle.entry.endCallAnimation.blinkColor
          }
    
          ColorAnimation {
            duration: CallsStyle.entry.endCallAnimation.duration
            from: CallsStyle.entry.endCallAnimation.blinkColor
            to: CallsStyle.entry.color.normal
          }
        }
      }
    }
}
