import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

DialogPlus {
  buttons: [
    TextButtonB {
      text: qsTr('ok')

      onClicked: exit(0)
    }
  ]

  centeredButtons: true

  height: AboutStyle.height
  width: AboutStyle.width

  Column {
    anchors {
      fill: parent
      leftMargin: AboutStyle.leftMargin
      rightMargin: AboutStyle.rightMargin
    }

    spacing: AboutStyle.spacing

    RowLayout {
      spacing: AboutStyle.versionsBlock.spacing

      height: AboutStyle.versionsBlock.iconSize
      width: parent.width

      Icon {
        icon: 'linphone_logo'
        iconSize: parent.height
      }

      Column {
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height

        spacing: 0

        Text {
          color: AboutStyle.versionsBlock.appVersion.color
          elide: Text.ElideRight
          font.pointSize: AboutStyle.versionsBlock.appVersion.fontSize
          text: 'Linphone Desktop Qt' + App.qtVersion + ' - ' + Qt.application.version

          height: parent.height / 2
          width: parent.width

          verticalAlignment: Text.AlignVCenter
        }

        Text {
          color: AboutStyle.versionsBlock.coreVersion.color
          elide: Text.ElideRight
          font.pointSize: AboutStyle.versionsBlock.coreVersion.fontSize
          text: 'Linphone Core ' + CoreManager.version

          height: parent.heigth / 2
          width: parent.width

          verticalAlignment: Text.AlignVCenter
        }
      }
    }

    Column {
      spacing: AboutStyle.copyrightBlock.spacing
      width: parent.width

      Text {
        elide: Text.ElideRight
        font.pointSize: AboutStyle.copyrightBlock.url.fontSize
        linkColor: AboutStyle.copyrightBlock.url.color
        text: '<a href="https://www.linphone.org">https://www.linphone.org</a>'

        width: parent.width

        horizontalAlignment: Text.AlignHCenter

        onLinkActivated: Qt.openUrlExternally(link)

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.NoButton
          cursorShape: parent.hoveredLink
            ? Qt.PointingHandCursor
            : Qt.IBeamCursor
        }
      }

      Text {
        color: AboutStyle.copyrightBlock.license.color
        elide: Text.ElideRight
        font.pointSize: AboutStyle.copyrightBlock.license.fontSize

        text: 'GNU General Public License V2\n\u00A9 2010-2017 Belledonne Communications'

        width: parent.width

        horizontalAlignment: Text.AlignHCenter
      }
    }
  }
}
