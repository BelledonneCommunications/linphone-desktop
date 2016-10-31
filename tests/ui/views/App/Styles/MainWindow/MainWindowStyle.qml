pragma Singleton
import QtQuick 2.7

// ===================================================================

QtObject {
  property int minimumHeight: 480
  property int minimumWidth: 780
  property string title: 'Linphone'

  property QtObject accountStatus: QtObject {
    property int width: 200
  }

  property QtObject menu: QtObject {
    property int entryHeight: 50
    property int width: 250
  }

  property QtObject searchBox: QtObject {
    property int maxHeight: 300 // See Hick's law for good choice.
  }

  property QtObject toolBar: QtObject {
    property int height: 70
    property int leftMargin: 20
    property int rightMargin: 20
    property int spacing: 20

    property var background: Rectangle {
      color: '#E2E2E2'
    }
  }
}
