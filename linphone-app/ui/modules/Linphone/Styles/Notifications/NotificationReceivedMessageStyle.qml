pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property color color: ColorsList.add("NorificationReceived_message", "k").color
  property int bottomMargin: 15
  property int leftMargin: 15
  property int overrodeHeight: 55
  property int rightMargin: 15
  property int spacing: 0

  property QtObject messageContainer: QtObject {
    property color color: ColorsList.add("NorificationReceived_message_container", "o").color
    property int radius: 6
    property int margins: 10

    property QtObject text: QtObject {
      property color color: ColorsList.add("NorificationReceived_message_container_text", "l").color
      property int pointSize: Units.dp * 9
    }
  }
}
