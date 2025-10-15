import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Effects

import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle

FocusScope {
    id: mainItem
    property alias addParticipantsLayout: addParticipantsLayout
    property alias groupName: groupName
    property string formTitle
    property string createGroupButtonText
    property int selectedParticipantsCount
    signal returnRequested()
    signal groupCreationRequested()
    
    ColumnLayout {
        spacing: 0
        anchors.fill: parent
        RowLayout {
            spacing: Utils.getSizeWithScreenRatio(10)
            Button {
                id: backGroupCallButton
                style: ButtonStyle.noBackgroundOrange
                icon.source: AppIcons.leftArrow
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(30)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
                icon.width: Utils.getSizeWithScreenRatio(24)
                icon.height: Utils.getSizeWithScreenRatio(24)
                KeyNavigation.down: groupName
                KeyNavigation.right: groupCallButton
                KeyNavigation.left: groupCallButton
                //: Return
                Accessible.name: qsTr("return_accessible_name")
                onClicked: {
                    mainItem.returnRequested()
                }
            }
            Text {
                text: mainItem.formTitle
                color: DefaultStyle.main1_500_main
                maximumLineCount: 1
                font {
                    pixelSize: Utils.getSizeWithScreenRatio(18)
                    weight: Typography.h4.weight
                }
                Layout.fillWidth: true
            }
            SmallButton {
                id: groupCallButton
                enabled: mainItem.selectedParticipantsCount.length != 0
                Layout.rightMargin: Utils.getSizeWithScreenRatio(21)
                text: mainItem.createGroupButtonText
                style: ButtonStyle.main
                KeyNavigation.down: addParticipantsLayout
                KeyNavigation.left: backGroupCallButton
                KeyNavigation.right: backGroupCallButton
                onClicked: {
                    mainItem.groupCreationRequested()
                }
            }
        }
        RowLayout {
            spacing: 0
            Layout.topMargin: Utils.getSizeWithScreenRatio(18)
            Layout.rightMargin: Utils.getSizeWithScreenRatio(38)
            Text {
                font.pixelSize: Typography.p2.pixelSize
                font.weight: Typography.p2.weight
                //: "Nom du groupe"
                text: qsTr("group_start_dialog_subject_hint")
            }
            Item {
                Layout.fillWidth: true
            }
            Text {
                font.pixelSize: Utils.getSizeWithScreenRatio(12)
                font.weight: Utils.getSizeWithScreenRatio(300)
                //: "Requis"
                text: qsTr("required")
            }
        }
        TextField {
            id: groupName
            Layout.fillWidth: true
            Layout.rightMargin: Utils.getSizeWithScreenRatio(38)
            Layout.preferredHeight: Utils.getSizeWithScreenRatio(49)
            focus: true
            KeyNavigation.down: addParticipantsLayout //participantList.count > 0 ? participantList : searchbar
            Accessible.name: qsTr("group_start_dialog_subject_hint")
        }
        AddParticipantsForm {
            id: addParticipantsLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: Utils.getSizeWithScreenRatio(15)
            onSelectedParticipantsCountChanged: mainItem.selectedParticipantsCount = selectedParticipantsCount
            focus: true
            
        }
    }
}
