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
	opacity: 1.0
	transientParent: null
	height: _content[0] != null ? _content[0].height : 0
	width: _content[0] != null ? _content[0].width : 0
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
