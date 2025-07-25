import QtQuick
import QtQuick.Window

import QtQuick.Controls.Basic
import QtQuick.Layouts
import Qt.labs.platform

Window {
  id: mainItem

	// ---------------------------------------------------------------------------

	color: "transparent"
	
	property bool requestActivate: false
	//property int flags: Qt.SplashScreen

	default property alias _content: content.data
	property bool _isOpen: false
	signal isOpened()
	signal isClosed()
	signal dataChanged()

	on_ContentChanged: dataChanged(_content)
	// ---------------------------------------------------------------------------

	function open () {
		_isOpen = true;
		isOpened();
	}
	/*
	function close () {
		_isOpen = false
		isClosed()
	}
	*/
	// ---------------------------------------------------------------------------

	objectName: '__internalWindow'
	property bool showAsTool : false
	// Don't use Popup for flags : it could lead to error in geometry. On Mac, Using Tool ensure to have the Window on Top and fullscreen independant
	// flags: Qt.WindowDoesNotAcceptFocus | Qt.BypassWindowManagerHint | (showAsTool?Qt.Tool:Qt.WindowStaysOnTopHint) | Qt.Window | Qt.FramelessWindowHint;
	flags: Qt.Popup | Qt.Dialog | Qt.WindowDoesNotAcceptFocus |  Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
	opacity: 1.0
	height: _content[0] != null ? _content[0].height : 0
	width: _content[0] != null ? _content[0].width : 0
	visible:true
	Item {
		id: content
		anchors.fill:parent
		focus: false

		property var $parent: mainItem
	}

  // ---------------------------------------------------------------------------
/*
  states: State {
    name: 'opening'
    when: _isOpen

    PropertyChanges {
      opacity: 1.0
      target: window
    }
  }

  transitions: [
    Transition {
      from: ''
      to: 'opening'
      ScriptAction {
        script: {
          if (wrapper.requestActivate) {
            window.requestActivate()
          }
        }
      }
    },
    Transition {
      from: '*'
      to: ''
      ScriptAction {
        script: window.close()
      }
    }
  ]
  */
}