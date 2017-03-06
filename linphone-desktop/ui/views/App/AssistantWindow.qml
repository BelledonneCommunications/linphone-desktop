import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.2

import App.Styles 1.0

// =============================================================================

Window {
  id: window

  // ---------------------------------------------------------------------------

  readonly property string viewsPath: 'qrc:/ui/views/App/Assistant/'

  // ---------------------------------------------------------------------------

  function pushView (view) {
    stack.push(viewsPath + view + '.qml')
  }

  function popView () {
    stack.pop()
  }

  // ---------------------------------------------------------------------------

  modality: Qt.WindowModal
  title: qsTr('assistantTitle')
  visible: true

  height: AssistantWindowStyle.height
  width: AssistantWindowStyle.width

  maximumHeight: AssistantWindowStyle.height
  maximumWidth: AssistantWindowStyle.width

  minimumHeight: AssistantWindowStyle.height
  minimumWidth: AssistantWindowStyle.width

  // ---------------------------------------------------------------------------

  Shortcut {
    sequence: StandardKey.Close
    onActivated: close()
  }

  // ---------------------------------------------------------------------------

  Rectangle {
    anchors.fill: parent
    color: AssistantWindowStyle.color
  }

  // ---------------------------------------------------------------------------

  StackView {
    id: stack

    anchors {
      fill: parent

      bottomMargin: AssistantWindowStyle.bottomMargin
      leftMargin: AssistantWindowStyle.leftMargin
      rightMargin: AssistantWindowStyle.rightMargin
      topMargin: AssistantWindowStyle.topMargin
    }

    initialItem: window.viewsPath + 'AssistantHome.qml'

    // -------------------------------------------------------------------------

    popEnter: Transition {
      XAnimator {
        duration: AssistantWindowStyle.stackAnimation.duration
        easing.type: Easing.OutBack
        from: -stack.width - AssistantWindowStyle.leftMargin
        to: 0
      }
    }

    popExit: Transition {
      XAnimator {
        duration: AssistantWindowStyle.stackAnimation.duration
        easing.type: Easing.OutBack
        from: 0
        to: stack.width + AssistantWindowStyle.rightMargin
      }
    }

    pushEnter: Transition {
      XAnimator {
        duration: AssistantWindowStyle.stackAnimation.duration
        easing.type: Easing.OutBack
        from: stack.width + AssistantWindowStyle.rightMargin
        to: 0
      }
    }

    pushExit: Transition {
      XAnimator {
        duration: AssistantWindowStyle.stackAnimation.duration
        easing.type: Easing.OutBack
        from: 0
        to: -stack.width - AssistantWindowStyle.leftMargin
      }
    }
  }
}
