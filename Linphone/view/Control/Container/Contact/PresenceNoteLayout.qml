import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Rectangle {
    id: mainItem
    property var friendCore
    color: DefaultStyle.grey_0
    radius: 20 * DefaultStyle.dp
    border.color: DefaultStyle.main2_200
    border.width: 2 * DefaultStyle.dp

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 16 * DefaultStyle.dp
        anchors.rightMargin: 16 * DefaultStyle.dp
        spacing: 8 * DefaultStyle.dp

        RowLayout {
            spacing: 6 * DefaultStyle.dp

            EffectImage {
                fillMode: Image.PreserveAspectFit
                imageSource: AppIcons.presenceNote
                colorizationColor: DefaultStyle.main2_600
                Layout.preferredHeight: Math.round(17 * DefaultStyle.dp)
                Layout.preferredWidth: Math.round(17 * DefaultStyle.dp)
            }

            Text {
                font: Typography.p2
                color: DefaultStyle.main2_600
                text: qsTr("contact_presence_note_title")
            }
        }

        Text {
            font: Typography.p3
            color: DefaultStyle.main2_500main
            text: mainItem.friendCore.presenceNote
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }
    }
}
