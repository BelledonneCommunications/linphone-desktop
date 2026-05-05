import QtQuick
import Linphone
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.Control {
    id: mainItem
    property int unread: 0
    width: Utils.getSizeWithScreenRatio(14)
    height: Utils.getSizeWithScreenRatio(14)
    visible: unread > 0
    focus: true
    focusPolicy: Qt.TabFocus
    activeFocusOnTab: true
    // Replace badgeType with the name of the data it concerns (e.g. messages, calls...)
    // for accessibility announce
    //: Unread
    property string badgeType: qsTr("unread")
    //: %1 notification badge : %2 unread
    Accessible.name: qsTr("unread_notification_accessible_name").arg(badgeType).arg(unread)
    background: Item {
        anchors.fill: parent
        Rectangle {
            id: background
            anchors.fill: parent
            radius: width/2
            color: DefaultStyle.danger_500_main
            border.color: DefaultStyle.main2_900
            border.width: mainItem.activeFocus ? Utils.getSizeWithScreenRatio(2) : 0
        }
        MultiEffect {
            id: shadow
            anchors.fill: background
            source: background
            // Crash : https://bugreports.qt.io/browse/QTBUG-124730?
            shadowEnabled: true
            shadowColor: DefaultStyle.grey_1000
            shadowBlur: 1
            shadowOpacity: 0.15
            z: mainItem.z - 1
        }
    }
    contentItem: Text {
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: DefaultStyle.grey_0
        fontSizeMode: Text.Fit
        font.pixelSize: Utils.getSizeWithScreenRatio(10)
        text: mainItem.unread > 100 ? '99+' : mainItem.unread
    }
}