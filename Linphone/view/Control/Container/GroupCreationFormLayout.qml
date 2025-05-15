import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Effects

import Linphone
import UtilsCpp
import SettingsCpp
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
            spacing: Math.round(10 * DefaultStyle.dp)
            Button {
                id: backGroupCallButton
                style: ButtonStyle.noBackgroundOrange
                icon.source: AppIcons.leftArrow
                Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                KeyNavigation.down: groupName
                KeyNavigation.right: groupCallButton
                KeyNavigation.left: groupCallButton
                onClicked: {
                    mainItem.returnRequested()
                }
            }
            Text {
                text: mainItem.formTitle
                color: DefaultStyle.main1_500_main
                maximumLineCount: 1
                font {
                    pixelSize: Math.round(18 * DefaultStyle.dp)
                    weight: Typography.h4.weight
                }
                Layout.fillWidth: true
            }
            SmallButton {
                id: groupCallButton
                enabled: mainItem.selectedParticipantsCount.length != 0
                Layout.rightMargin: Math.round(21 * DefaultStyle.dp)
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
            Layout.topMargin: Math.round(18 * DefaultStyle.dp)
            Layout.rightMargin: Math.round(38 * DefaultStyle.dp)
            Text {
                font.pixelSize: Typography.p2.pixelSize
                font.weight: Typography.p2.weight
                //: "Nom du groupe"
                text: qsTr("history_group_call_start_dialog_subject_hint")
            }
            Item {
                Layout.fillWidth: true
            }
            Text {
                font.pixelSize: Math.round(12 * DefaultStyle.dp)
                font.weight: Math.round(300 * DefaultStyle.dp)
                //: "Requis"
                text: qsTr("required")
            }
        }
        TextField {
            id: groupName
            Layout.fillWidth: true
            Layout.rightMargin: Math.round(38 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(49 * DefaultStyle.dp)
            focus: true
            KeyNavigation.down: addParticipantsLayout //participantList.count > 0 ? participantList : searchbar
        }
        AddParticipantsForm {
            id: addParticipantsLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: Math.round(15 * DefaultStyle.dp)
            onSelectedParticipantsCountChanged: mainItem.selectedParticipantsCount = selectedParticipantsCount
            focus: true
            
        }
    }
}
