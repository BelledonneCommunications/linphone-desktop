import QtQuick 2.7

Item {
  id: container

  property int handleLimitLeft: 0
  property int handleLimitRight: 0
  property alias childA: contentA.data
  property alias childB: contentB.data

  onWidthChanged: {
    console.log('RESIZE', width, handleLimitRight)
    if (contentB.width < handleLimitRight) {
      console.log('lala', width, handleLimitRight, width - handle.width - handleLimitRight)
      contentA.width = width - handle.width - handleLimitRight
    } else if (contentA.width < handleLimitLeft) {
      console.log('zaza', width, handleLimitLeft)

      contentA.width = handleLimitLeft
    } else if (contentA.width >= width - handleLimitRight - 20) {
      console.log('FUCK', contentA.width , width - handleLimitRight - 20)
      contentA.width - handle.width - handleLimitRight
    }
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

      if (container.width - offset - contentA.width - width < handleLimitRight) {
        contentA.width = container.width - width - handleLimitRight
      } else if (contentA.width + offset < handleLimitLeft) {
        contentA.width = handleLimitLeft
      } else {
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
