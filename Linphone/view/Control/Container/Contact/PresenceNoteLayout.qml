import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Rectangle {
    id: mainItem
    property var friendCore
    color: DefaultStyle.grey_0
    radius: Utils.getSizeWithScreenRatio(20)
    border.color: DefaultStyle.main2_200
    border.width: Utils.getSizeWithScreenRatio(2)

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Utils.getSizeWithScreenRatio(16)
        anchors.rightMargin: Utils.getSizeWithScreenRatio(16)
        spacing: Utils.getSizeWithScreenRatio(8)

        RowLayout {
            spacing: Utils.getSizeWithScreenRatio(6)

            EffectImage {
                fillMode: Image.PreserveAspectFit
                imageSource: AppIcons.presenceNote
                colorizationColor: DefaultStyle.main2_600
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(17)
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(17)
            }

            Text {
                font: Typography.p2
                color: DefaultStyle.main2_600
                text: qsTr("contact_presence_note_title")
            }
        }

        Text {
            font: Typography.p3
            color: DefaultStyle.main2_500_main
            text: mainItem.friendCore?.presenceNote || ""
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }
    }
}
