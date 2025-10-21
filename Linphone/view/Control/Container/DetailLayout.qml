import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ColumnLayout {
    id: mainItem
    spacing: Utils.getSizeWithScreenRatio(15)
    property string label
    property var icon
    property alias content: contentControl.contentItem
    signal titleIconClicked
    RowLayout {
        spacing: Utils.getSizeWithScreenRatio(10)
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
        leftPadding: Utils.getSizeWithScreenRatio(20)
        rightPadding: Utils.getSizeWithScreenRatio(20)
        topPadding: Utils.getSizeWithScreenRatio(17)
        bottomPadding: Utils.getSizeWithScreenRatio(17)
    }
}