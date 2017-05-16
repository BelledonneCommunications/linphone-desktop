import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Window 2.2

import Utils 1.0

import App.Styles 1.0

// =============================================================================

Item {
  id: assistant

  readonly property string viewsPath: 'qrc:/ui/views/App/Main/Assistant/'
  readonly property alias nViews: stack.depth

  // ---------------------------------------------------------------------------

  function pushView (view, properties) {
    stack.push(
      Utils.isString(view) ? viewsPath + view + '.qml' : view,
      properties
    )
  }

  function getView (index) {
    return stack.get(index)
  }

  function popView () {
    stack.pop()
  }

  // ---------------------------------------------------------------------------

  Rectangle {
    anchors.fill: parent
    color: AssistantStyle.color
  }

  // ---------------------------------------------------------------------------

  StackView {
    id: stack

    anchors {
      fill: parent

      bottomMargin: AssistantStyle.bottomMargin
      leftMargin: AssistantStyle.leftMargin
      rightMargin: AssistantStyle.rightMargin
      topMargin: AssistantStyle.topMargin
    }

    initialItem: assistant.viewsPath + 'AssistantHome.qml'

    // -------------------------------------------------------------------------

    popEnter: Transition {
      YAnimator {
        duration: AssistantStyle.stackAnimation.duration
        easing.type: Easing.OutBack
        from: stack.height + AssistantStyle.bottomMargin
        to: 0
      }
    }

    popExit: Transition {
      XAnimator {
        duration: AssistantStyle.stackAnimation.duration
        easing.type: Easing.OutBack
        from: 0
        to: stack.width + AssistantStyle.rightMargin
      }
    }

    pushEnter: Transition {
      XAnimator {
        duration: AssistantStyle.stackAnimation.duration
        easing.type: Easing.OutBack
        from: stack.width + AssistantStyle.rightMargin
        to: 0
      }
    }

    pushExit: Transition {
      YAnimator {
        duration: AssistantStyle.stackAnimation.duration
        easing.type: Easing.OutBack
        from: 0
        to: stack.height + AssistantStyle.bottomMargin
      }
    }
  }
}
