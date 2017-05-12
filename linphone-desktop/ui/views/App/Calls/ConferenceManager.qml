import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

import 'ConferenceManager.js' as Logic

// =============================================================================

ConfirmDialog {
  descriptionText: qsTr('conferenceManagerDescription')

  height: ConferenceManagerStyle.height
  width: ConferenceManagerStyle.width

  // ---------------------------------------------------------------------------

  RowLayout {
    anchors {
      fill: parent
      leftMargin: ConferenceManagerStyle.leftMargin
      rightMargin: ConferenceManagerStyle.rightMargin
    }

    spacing: 0

    // -------------------------------------------------------------------------
    // Address selector.
    // -------------------------------------------------------------------------

    Column {
      Layout.alignment: Qt.AlignTop
      Layout.fillWidth: true

      spacing: ConferenceManagerStyle.columns.selector.spacing

      TextField {
        icon: 'search'
        width: parent.width

        onTextChanged: Logic.updateFilter(text)
      }
    }

    // -------------------------------------------------------------------------
    // Separator.
    // -------------------------------------------------------------------------

    Rectangle {
      Layout.fillHeight: true
      Layout.leftMargin: ConferenceManagerStyle.leftMargin
      Layout.preferredWidth: ConferenceManagerStyle.columns.separator.width
      Layout.rightMargin: ConferenceManagerStyle.rightMargin

      color: ConferenceManagerStyle.columns.separator.color
    }

    // -------------------------------------------------------------------------
    // See and remove selected addresses.
    // -------------------------------------------------------------------------

    Column {
      Layout.alignment: Qt.AlignTop
      Layout.fillWidth: true
    }
  }
}
