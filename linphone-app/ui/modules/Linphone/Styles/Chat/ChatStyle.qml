pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property color color: ColorsList.add("Chat", "q").color

  property QtObject sectionHeading: QtObject {
    property int padding: 5
    property int bottomMargin: 20

    property QtObject border: QtObject {
      property color color: ColorsList.add("Chat_section_border", "g10").color
      property int width: 1
    }

    property QtObject text: QtObject {
      property int pointSize: Units.dp * 10
      property color color: ColorsList.add("Chat_section_text", "ab").color
    }
  }

  property QtObject sendArea: QtObject {
    property int height: 80

    property QtObject border: QtObject {
      property color color: ColorsList.add("Chat_send_border", "f").color
      property int width: 1
    }
  }

  property QtObject composingText: QtObject {
    property color color: ColorsList.add("Chat_composing_text", "d").color
    property int height: 25
    property int leftPadding: 20
    property int pointSize: Units.dp * 9
  }

  property QtObject entry: QtObject {
    property int bottomMargin: 10
    property int deleteIconSize: 22
    property int leftMargin: 18
    property int lineHeight: 30
    property int metaWidth: 40

    property QtObject event: QtObject {
      property int iconSize: 18

      property QtObject text: QtObject {
        property color color: ColorsList.add("Chat_entry_text", "ac").color
        property int pointSize: Units.dp * 10
      }
    }

    property QtObject message: QtObject {
      property int padding: 8
      property int radius: 4

      property QtObject extraContent: QtObject {
        property int leftMargin: 10
        property int spacing: 5
        property int rightMargin: 5
      }

      property QtObject file: QtObject {
        property int height: 64
        property int iconSize: 18
        property int margins: 8
        property int spacing: 8
        property int width: 250

        property QtObject animation: QtObject {
          property int duration: 200
          property real to: 1.5
        }

        property QtObject extension: QtObject {
          property QtObject background: QtObject {
            property color color: ColorsList.add("Chat_file_extension_background", "l50").color
          }

          property QtObject text: QtObject {
            property color color: ColorsList.add("Chat_file_extension_text", "q").color
          }
        }

        property QtObject status: QtObject {
          property int spacing: 4

          property QtObject bar: QtObject {
            property int height: 6
            property int radius: 3

            property QtObject background: QtObject {
              property color color: ColorsList.add("Chat_file_statusbar_background", "f").color
            }

            property QtObject contentItem: QtObject {
              property color color: ColorsList.add("Chat_file_statusbar_content", "p").color
            }
          }
        }
      }

      property QtObject images: QtObject {
        property int height: 48
      }

      property QtObject incoming: QtObject {
        property color backgroundColor: ColorsList.add("Chat_incoming_background", "o").color
        property int avatarSize: 20

        property QtObject text: QtObject {
          property color color: ColorsList.add("Chat_incoming_text", "d").color
        }
      }

      property QtObject outgoing: QtObject {
        property color backgroundColor: ColorsList.add("Chat_outgoing_background", "e").color
        property int areaSize: 16
        property int busyIndicatorSize: 16
        property int sendIconSize: 12

        property QtObject text: QtObject {
          property color color: ColorsList.add("Chat_outgoing_text", "d").color
        }
      }
    }

    property QtObject time: QtObject {
      property color color: ColorsList.add("Chat_time", "d").color
      property int pointSize: Units.dp * 10
      property int width: 44
    }
  }
}
