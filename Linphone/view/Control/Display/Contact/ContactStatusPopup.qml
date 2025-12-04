import QtQuick
import QtQuick.Effects

import QtQuick.Layouts
import QtQuick.Controls.Basic as Control


import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

PopupButton {
    id: presenceAndRegistrationItem
    width: presenceOrRegistrationText.implicitWidth + Utils.getSizeWithScreenRatio(50)
    height: Utils.getSizeWithScreenRatio(24)
    enabled: mainItem.account && mainItem.account.core.registrationState === LinphoneEnums.RegistrationState.Ok
    onEnabledChanged: if(!enabled) close()
    property bool editCustomStatus : false
    contentItem: Rectangle {
        id: presenceBar
        property bool isRegistered: mainItem.account?.core.registrationState === LinphoneEnums.RegistrationState.Ok
        color: DefaultStyle.main2_200
        radius: Utils.getSizeWithScreenRatio(15)
        RowLayout {
            anchors.fill: parent
            Image {
                id: registrationImage
                sourceSize.width: Utils.getSizeWithScreenRatio(11)
                sourceSize.height: Utils.getSizeWithScreenRatio(11)
                smooth: false
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(11)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(11)
                source: presenceBar.isRegistered 
                    ? mainItem.account.core.presenceIcon 
                    : mainItem.account?.core.registrationIcon || ""
                Layout.leftMargin: Utils.getSizeWithScreenRatio(8)
                RotationAnimator on rotation {
                    running: mainItem.account && mainItem.account.core.registrationState === LinphoneEnums.RegistrationState.Progress
                    direction: RotationAnimator.Clockwise
                    from: 0
                    to: 360
                    loops: Animation.Infinite
                    duration: 10000
                }
            }
            Text {
                id: presenceOrRegistrationText
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                visible: mainItem.account
                font.weight: Utils.getSizeWithScreenRatio(300)
                font.pixelSize: Utils.getSizeWithScreenRatio(12)
                color: presenceBar.isRegistered ? mainItem.account.core.presenceColor : mainItem.account?.core.registrationColor
                text: presenceBar.isRegistered ? mainItem.account.core.presenceStatus : mainItem.account?.core.humaneReadableRegistrationState
            }
            EffectImage {
                fillMode: Image.PreserveAspectFit
                imageSource: AppIcons.downArrow
                colorizationColor: DefaultStyle.main2_600
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(14)
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(14)
                Layout.rightMargin: Utils.getSizeWithScreenRatio(8)
            }
        }
    }
    popup.contentItem: Rectangle {
        implicitWidth: Utils.getSizeWithScreenRatio(280)
        implicitHeight: Utils.getSizeWithScreenRatio(20) + (setCustomStatus.visible ? Utils.getSizeWithScreenRatio(240) : setPresence.implicitHeight)
        Presence {
            id: setPresence
            visible: !presenceAndRegistrationItem.editCustomStatus
            anchors.fill: parent
            anchors.margins: Utils.getSizeWithScreenRatio(20)
            accountCore: mainItem.account.core
            onSetCustomStatusClicked: {
                presenceAndRegistrationItem.editCustomStatus = true
            }
            onIsSet: presenceAndRegistrationItem.popup.close()
        }
        PresenceSetCustomStatus {
            id: setCustomStatus
            visible: presenceAndRegistrationItem.editCustomStatus
            anchors.fill: parent
            anchors.margins: Utils.getSizeWithScreenRatio(20)
            accountCore: mainItem.account.core
            onVisibleChanged: {
                if (!visible) {
                    presenceAndRegistrationItem.editCustomStatus = false
                }
            }
            onIsSet: presenceAndRegistrationItem.popup.close()
        }
    }
}