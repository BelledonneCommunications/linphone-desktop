import QtQuick 2.7
import QtQuick.Controls 2.1

import Common.Styles 1.0

// =============================================================================

Column {
  id: vuMeter

  property bool enabled: true
  property double value: 0

  height: VuMeterStyle.height
  width: VuMeterStyle.width

  // ---------------------------------------------------------------------------

  ProgressBar {
    id: high

    height: parent.height * 0.25
    width: parent.width

    from: 0.75
    to: 1.0

    value: parent.value

    background: Rectangle {
      color: vuMeter.enabled
        ? VuMeterStyle.high.background.color.enabled
        : VuMeterStyle.high.background.color.disabled
    }

    contentItem: Item {
      Rectangle {
        anchors.bottom: parent.bottom

        color: VuMeterStyle.high.contentItem.color
        height: high.visualPosition * parent.height
        width: parent.width

        visible: vuMeter.enabled
      }
    }
  }

  ProgressBar {
    id: low

    height: parent.height * 0.75
    width: parent.width

    from: 0
    to: 0.75

    value: parent.value

    background: Rectangle {
      color: vuMeter.enabled
        ? VuMeterStyle.low.background.color.enabled
        : VuMeterStyle.low.background.color.disabled
    }

    contentItem: Item {
      Rectangle {
        anchors.bottom: parent.bottom

        color: VuMeterStyle.low.contentItem.color
        height: low.visualPosition * parent.height
        width: parent.width

        visible: vuMeter.enabled
      }
    }
  }
}
