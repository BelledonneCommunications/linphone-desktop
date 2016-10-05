import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls 2.0

import Linphone 1.0

Window {
  minimumHeight: 480
  minimumWidth: 640

  id: window

  Paned {
    anchors.fill: parent
    handleLimitLeft: parent.width *0.66
    handleLimitRight: 50

    childA: Text {
      text: 'hello'
    }

    childB: Text {
      text: 'hello2'
    }
  }
}
