import QtQuick 2.7

Item {
  id: container

  property int handleLimitLeft: 0
  property int handleLimitRight: 0
  property alias childA: contentA.data
  property alias childB: contentB.data

  property bool useDynamicLimits: true

  function updateContentA () {
    // width(A) < minimum width(A)
    if (contentA.width < handleLimitLeft) {
      contentA.width = handleLimitLeft
    }

    // width(B) < minimum width(B)
    else if (width - contentA.width - handle.width < handleLimitRight) {
      contentA.width = width - handle.width - handleLimitRight
    }
  }

  onHandleLimitLeftChanged: updateContentA()
  onHandleLimitRightChanged: updateContentA()
  onWidthChanged: !useDynamicLimits && updateContentA()

  Component.onCompleted: {
    contentA.width = handleLimitLeft
  }

  Rectangle {
    id: contentA

    color: '#FFFFFF'
    height: parent.height
  }

  MouseArea {
    id: handle

    property int _mouseStart

    anchors.left: contentA.right
    cursorShape: Qt.SplitHCursor
    height: parent.height
    hoverEnabled: true
    width: 8

    onMouseXChanged: {
      // Necessary because `hoverEnabled` is used.
      if (!pressed) {
        return
      }

      var offset = mouseX - _mouseStart

      // width(B) < minimum width(B)
      if (container.width - offset - contentA.width - width < handleLimitRight) {
        contentA.width = container.width - width - handleLimitRight
      }
      // width(A) < minimum width(A)
      else if (contentA.width + offset < handleLimitLeft) {
        contentA.width = handleLimitLeft
      }
      // Resize A/B.
      else {
        contentA.width = contentA.width + offset
      }
    }

    onPressed: _mouseStart = mouseX

    Rectangle {
      anchors.fill: parent
      color: parent.pressed
        ? '#5E5E5E'
        : (parent.containsMouse
           ? '#707070'
           : '#C5C5C5'
        )
    }
  }

  Rectangle {
    id: contentB

    anchors.left: handle.right
    color: '#EAEAEA'
    height: parent.height
    width: {

      console.log('toto',  container.width, contentA.width, container.width - contentA.width - handle.width)
     return  container.width - contentA.width - handle.width
    }
  }
}
