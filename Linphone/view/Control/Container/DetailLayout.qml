import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ColumnLayout {
    id: mainItem
    spacing: Math.round(15 * DefaultStyle.dp)
    property string label
    property var icon
    property alias content: contentControl.contentItem
    signal titleIconClicked
    RowLayout {
        spacing: Math.round(10 * DefaultStyle.dp)
        Text {
            text: mainItem.label
            color: DefaultStyle.main1_500_main
            font {
                pixelSize: Typography.h4.pixelSize
                weight: Typography.h4.weight
            }
        }
        RoundButton {
            visible: mainItem.icon != undefined
            icon.source: mainItem.icon
            style: ButtonStyle.noBackgroundOrange
            onClicked: mainItem.titleIconClicked()
        }
        Item {
            Layout.fillWidth: true
        }
        RoundButton {
            id: expandButton
            style: ButtonStyle.noBackground
            checkable: true
            checked: true
            icon.source: checked ? AppIcons.upArrow : AppIcons.downArrow
            KeyNavigation.down: contentControl
        }
    }
    RoundedPane {
        id: contentControl
        visible: expandButton.checked
        Layout.fillWidth: true
        leftPadding: Math.round(20 * DefaultStyle.dp)
        rightPadding: Math.round(20 * DefaultStyle.dp)
        topPadding: Math.round(17 * DefaultStyle.dp)
        bottomPadding: Math.round(17 * DefaultStyle.dp)
    }
}