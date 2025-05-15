import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Effects

import Linphone
import UtilsCpp
import SettingsCpp

CreationFormLayout {
	id: mainItem
	property bool groupCallVisible
	property bool displayCurrentCalls: false
	signal transferCallToAnotherRequested(CallGui dest)

    //: Appel de groupe
    startGroupButtonText: qsTr("call_start_group_call_title")

    topLayoutVisible: mainItem.displayCurrentCalls && callList.count > 0
    topContent: [
        Text {
            //: "Appels en cours"
            text: qsTr("call_transfer_active_calls_label")
            font {
                pixelSize: Typography.h4.pixelSize
                weight: Typography.h4.weight
            }
        },
        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: callListBackground.height
            Layout.maximumHeight: mainItem.height/2
            contentHeight: callListBackground.height
            contentWidth: width
            RoundedPane {
                id: callListBackground
                anchors.left: parent.left
                anchors.right: parent.right
                contentItem: CallListView {
                    id: callList
                    isTransferList: true
                    onTransferCallToAnotherRequested: (dest) => {
                        mainItem.transferCallToAnotherRequested(dest)
                    }
                }
            }
        }
    ]
}
