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
  objectName: '__about'

  height: AboutStyle.height
  width: AboutStyle.width

  Column {
    anchors.fill: parent
    spacing: AboutStyle.spacing

    RowLayout {
    id:versionsLayout
      spacing: AboutStyle.versionsBlock.spacing

      height: AboutStyle.versionsBlock.iconSize
      width: parent.width

      Icon {
        icon: 'linphone_logo'
        iconSize: parent.height
      }
      
      Column {
        id:versionsArea
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height

        spacing: 0

        TextEdit {
          id: appVersion
          color: AboutStyle.versionsBlock.appVersion.color
          selectByMouse: true
          font.pointSize: AboutStyle.versionsBlock.appVersion.pointSize
          text: 'Desktop ' + Qt.application.version + ' - Qt' + App.qtVersion +'\nCore ' + CoreManager.version

          height: parent.height
          width: parent.width   

          verticalAlignment: Text.AlignVCenter

          onActiveFocusChanged: deselect();
        }
      }
    }
   
    Column {
      spacing: AboutStyle.copyrightBlock.spacing
      width: parent.width

      Text {
        elide: Text.ElideRight
        font.pointSize: AboutStyle.copyrightBlock.url.pointSize
        linkColor: AboutStyle.copyrightBlock.url.color
        text: '<a href="'+applicationUrl+'">'+applicationUrl+'</a>'

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
        font.pointSize: AboutStyle.copyrightBlock.license.pointSize

        text: 'GNU General Public License V3\n\u00A9 2010-' +
          (new Date().toLocaleDateString(Qt.locale(), 'yyyy')) +
          ' Belledonne Communications'

        width: parent.width

        horizontalAlignment: Text.AlignHCenter
      }
    }
  }
  
}
