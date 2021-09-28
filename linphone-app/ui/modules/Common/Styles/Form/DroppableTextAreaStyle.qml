pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property color backgroundColor: ColorsList.add("DroppableTextArea_Chat_background", "e").color
  property color outsideBackgroundColor: ColorsList.add("DroppableTextArea_Chat_outsideBackground", "aa").color

  property QtObject fileChooserButton: QtObject {
    property int margins: 6
    property int size: 20
  }

  property QtObject hoverContent: QtObject {
    property color backgroundColor: ColorsList.add("DroppableTextArea_Chat_hoverContent_background", "q").color

    property QtObject text: QtObject {
      property color color: ColorsList.add("DroppableTextArea_Chat_hoverContent_text", "i").color
      property int pointSize: Units.dp * 11
    }
  }

  property QtObject text: QtObject {
    property color color: ColorsList.add("DroppableTextArea_Chat_text", "d").color
    property int pointSize: Units.dp * 10
  }
}
