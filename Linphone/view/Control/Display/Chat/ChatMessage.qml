import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.Control {
    id: mainItem
    property color backgroundColor
    property bool isRemoteMessage
    property bool isFirstMessage

    property string imgUrl
    property string contentText
    topPadding: Math.round(12 * DefaultStyle.dp)
    bottomPadding: Math.round(12 * DefaultStyle.dp)
    leftPadding: Math.round(18 * DefaultStyle.dp)
    rightPadding: Math.round(18 * DefaultStyle.dp)

    background: Item {
        anchors.fill: parent
        Rectangle {
            anchors.fill: parent
            color: mainItem.backgroundColor
            radius: Math.round(16 * DefaultStyle.dp)
        }
        Rectangle {
            visible: mainItem.isFirstMessage && mainItem.isRemoteMessage
            anchors.top: parent.top
            anchors.left: parent.left
            width: Math.round(parent.width / 4)
            height: Math.round(parent.height / 4)
            color: mainItem.backgroundColor
        }
        Rectangle {
            visible: mainItem.isFirstMessage && !mainItem.isRemoteMessage
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: Math.round(parent.width / 4)
            height: Math.round(parent.height / 4)
            color: mainItem.backgroundColor
        }
    }
    contentItem: ColumnLayout {
        id: contentLayout
        Image {
            visible: mainItem.imgUrl != undefined
            id: contentimage
        }
        Text {
            visible: mainItem.contentText != undefined
            text: mainItem.contentText
            Layout.fillWidth: true
            color: DefaultStyle.main2_700
            font {
                pixelSize: Typography.p1.pixelSize
                weight: Typography.p1.weight
            }
        }
        Text {
            Layout.alignment: Qt.AlignRight
            text: UtilsCpp.formatDate(modelData.core.timestamp, true, false)
            color: DefaultStyle.main2_500main
            font {
                pixelSize: Typography.p3.pixelSize
                weight: Typography.p3.weight
            }
        }
    }
}
