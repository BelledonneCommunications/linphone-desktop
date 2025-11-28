import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import Linphone
import UtilsCpp
import SettingsCpp
import DesktopToolsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ApplicationWindow {
    id: mainWindow
    x: 0
    y: 0
    width: Math.min(Utils.getSizeWithScreenRatio(1512), Screen.desktopAvailableWidth)
    height: Math.min(Utils.getSizeWithScreenRatio(982), Screen.desktopAvailableHeight)

    onActiveChanged: {
        if (active) UtilsCpp.setLastActiveWindow(this)
    }
    Component.onDestruction: if (UtilsCpp.getLastActiveWindow() === this) UtilsCpp.setLastActiveWindow(null)

    property bool isFullscreen: visibility == Window.FullScreen
    onIsFullscreenChanged: DesktopToolsCpp.screenSaverStatus = !isFullscreen


    MouseArea {
        anchors.fill: parent
        onClicked: mainWindow.contentItem.forceActiveFocus()
    }

    Component {
        id: popupComp
        InformationPopup{}
    }

    Component{
        id: confirmPopupComp
        Dialog {
            property var requestDialog
            property int index
            property var callback: requestDialog?.result
            signal closePopup(int index)
            onClosed: closePopup(index)
            text: requestDialog?.message
            details: requestDialog?.details
            firstButtonAccept: title.length === 0
            secondButtonAccept: title.length !== 0
            Component.onCompleted: if (details.length != 0) radius = 0
            // For C++, requestDialog need to be call directly
            onAccepted: requestDialog ? requestDialog.result(1) : callback(1)
            onRejected: requestDialog ? requestDialog.result(0) : callback(0)
            width: Utils.getSizeWithScreenRatio(title.length === 0 ? 278 : 637)
        }
    }

    Component {
        id: addressChooserPopupComp
        Popup {
            id: addressChooserPopup
            property FriendGui contact
            signal addressChosen(string address)
            underlineColor: DefaultStyle.main1_500_main
            anchors.centerIn: parent
            width: Utils.getSizeWithScreenRatio(370)
            modal: true
            leftPadding: Utils.getSizeWithScreenRatio(15)
            rightPadding: Utils.getSizeWithScreenRatio(15)
            topPadding: Utils.getSizeWithScreenRatio(20)
            bottomPadding: Utils.getSizeWithScreenRatio(25)
            contentItem: ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(16)
                RowLayout {
                    spacing: Utils.getSizeWithScreenRatio(5)
                    width: addressChooserPopup.width
                    Text {
                        //: "Choisissez un numéro ou adresse SIP"
                        text: qsTr("contact_dialog_pick_phone_number_or_sip_address_title")
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        font {
                            pixelSize: Typography.h4.pixelSize
                            weight: Typography.h4.weight
                        }
                    }
                    RoundButton {
                        Layout.alignment: Qt.AlignVCenter
                        style: ButtonStyle.noBackground
                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
                        icon.source:AppIcons.closeX
                        onClicked: addressChooserPopup.close()
                    }
                }
                ListView {
                    id: popuplist
                    model: VariantList {
                        model: addressChooserPopup.contact && addressChooserPopup.contact.core.allAddresses || []
                    }
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    spacing: Utils.getSizeWithScreenRatio(10)
                    delegate: Item {
                        width: popuplist.width
                        height: Utils.getSizeWithScreenRatio(56)
                        ColumnLayout {
                            width: popuplist.width
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Utils.getSizeWithScreenRatio(10)
                            ColumnLayout {
                                spacing: Utils.getSizeWithScreenRatio(7)
                                Text {
                                    Layout.leftMargin: Utils.getSizeWithScreenRatio(5)
                                    text: modelData.label + " :"
                                    font {
                                        pixelSize: Typography.p2.pixelSize
                                        weight: Typography.p2.weight
                                    }
                                }
                                Text {
                                    Layout.leftMargin: Utils.getSizeWithScreenRatio(5)
                                    text: SettingsCpp.hideSipAddresses ? UtilsCpp.getUsername(modelData.address) : modelData.address
                                    font {
                                        pixelSize: Typography.p1.pixelSize
                                        weight: Typography.p1.weight
                                    }
                                }
                            }
                            Rectangle {
                                visible: index != popuplist.model.count - 1
                                Layout.fillWidth: true
                                Layout.preferredHeight: Utils.getSizeWithScreenRatio(1)
                                color: DefaultStyle.main2_200
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                addressChooserPopup.addressChosen(modelData.address)
                            }
                        }
                    }
                }
            }
        }
    }

    function startCallWithContact(contact, videoEnabled, parentItem) {
        if (parentItem == undefined) parentItem = mainWindow.contentItem
        if (contact) {
            console.log("START CALL WITH", contact.core.fullName, "addresses count", contact.core.allAddresses.length)
            if (contact.core.allAddresses.length > 1) {
                var addressPopup = addressChooserPopupComp.createObject()
                addressPopup.parent = parentItem
                addressPopup.contact = contact
                addressPopup.addressChosen.connect(function(address) {
                    UtilsCpp.createCall(address, {'localVideoEnabled': videoEnabled})
                    addressPopup.close()
                })
                addressPopup.open()

            } else {
                var addressToCall = contact.core.defaultAddress.length === 0
                    ? contact.core.phoneNumbers.length === 0
                        ? ""
                        : contact.core.phoneNumbers[0].address
                    : contact.core.defaultAddress
                if (addressToCall.length != 0) UtilsCpp.createCall(addressToCall, {'localVideoEnabled':videoEnabled})
            }
        }
    }

    function sendMessageToContact(contact, parentItem) {
        if (parentItem == undefined) parentItem = mainWindow.contentItem
        if (contact) {
            console.log("SEND MESSAGE TO", contact.core.fullName, "addresses count", contact.core.allAddresses.length)
            if (contact.core.allAddresses.length > 1) {
                var addressPopup = addressChooserPopupComp.createObject()
                addressPopup.parent = parentItem
                addressPopup.contact = contact
                addressPopup.addressChosen.connect(function(address) {
                    displayChatPage(address)
                    addressPopup.close()
                })
                addressPopup.open()

            } else {
                displayChatPage(contact.core.defaultAddress)
                if (addressToCall.length != 0) UtilsCpp.createCall(addressToCall, {'localVideoEnabled':videoEnabled})
            }
        }
    }

    function transferCallToContact(call, contact, parentItem) {
        if (!call || !contact) return
        if (parentItem == undefined) parentItem = mainWindow.contentItem
        if (contact) {
            console.log("[AbstractWindow] Transfer call to", contact.core.fullName, "addresses count", contact.core.allAddresses.length, call)
            if (contact.core.allAddresses.length > 1) {
                var addressPopup = addressChooserPopupComp.createObject()
                addressPopup.parent = parentItem
                addressPopup.contact = contact
                addressPopup.addressChosen.connect(function(address) {
                    call.core.lTransferCall(address)
                    addressPopup.close()
                })
                addressPopup.open()

            } else {
                var addressToCall = contact.core.defaultAddress.length === 0
                    ? contact.core.phoneNumbers.length === 0
                        ? ""
                        : contact.core.phoneNumbers[0].address
                    : contact.core.defaultAddress
                if (addressToCall.length != 0) call.core.lTransferCall(addressToCall)
            }
        }
    }

    function removeFromPopupLayout(index) {
        popupLayout.popupList.splice(index, 1)
    }
    function showInformationPopup(title, description, isSuccess) {
        if (isSuccess == undefined) isSuccess = true
        var infoPopup = popupComp.createObject(popupLayout, {"title": title, "description": description, "isSuccess": isSuccess})
        infoPopup.index = popupLayout.popupList.length
        popupLayout.popupList.push(infoPopup)
        infoPopup.open()
        infoPopup.closePopup.connect(removeFromPopupLayout)
    }
    function showLoadingPopup(text, cancelButtonVisible, callback) {
        if (cancelButtonVisible == undefined) cancelButtonVisible = false
        loadingPopup.text = text
        loadingPopup.callback = callback
        loadingPopup.cancelButtonVisible = cancelButtonVisible
        loadingPopup.open()
    }
    function closeLoadingPopup() {
        loadingPopup.close()
    }

    function showConfirmationPopup(requestDialog){
        console.log("Showing confirmation popup")
        var popup = confirmPopupComp.createObject(popupLayout, {"requestDialog": requestDialog})
        popup.open()
        popup.closePopup.connect(removeFromPopupLayout)
    }

    function showConfirmationLambdaPopup(title,text, details, callback, firstButtonText, secondButtonText, customContent){
        console.log("Showing confirmation lambda popup")
        var popup = confirmPopupComp.createObject(popupLayout, {"title": title, "text": text, "details":details,"callback":callback})
        if (firstButtonText != undefined) popup.firstButtonText = firstButtonText
        if (secondButtonText != undefined) popup.secondButtonText = secondButtonText
        if (customContent != undefined) popup.content = customContent
        popup.titleColor = DefaultStyle.main1_500_main
        popup.open()
        popup.closePopup.connect(removeFromPopupLayout)
    }

    ColumnLayout {
        id: popupLayout
        anchors.fill: parent
        Layout.alignment: Qt.AlignBottom
        property real nextY: mainWindow.height
        property list<InformationPopup> popupList
        property int popupCount: popupList.length
        spacing: Utils.getSizeWithScreenRatio(15)
        onPopupCountChanged: {
            nextY = mainWindow.height
            for(var i = 0; i < popupCount; ++i) {
                var popupItem = popupList[i]
                if( popupItem ){
                    popupItem.y = nextY - popupItem.height
                    popupItem.index = i
                    nextY = nextY - popupItem.height - 15
                }
            }
        }
    }

    LoadingPopup {
        id: loadingPopup
        modal: true
        closePolicy: Popup.NoAutoClose
        anchors.centerIn: parent
        padding: Utils.getSizeWithScreenRatio(20)
        underlineColor: DefaultStyle.main1_500_main
        radius: Utils.getSizeWithScreenRatio(15)
    }
    FPSCounter{
        anchors.top: parent.top
        anchors.left: parent.left
        height: 50
        width: fpsText.implicitWidth
        z: 100
        visible: !SettingsCpp.hideFps
        Text{
            id: fpsText
            font.bold: true
            font.italic: true
            font.pixelSize: Utils.getSizeWithScreenRatio(14)
            // "%1 FPS"
            text: qsTr("fps_counter").arg(parent.fps)
            color: parent.fps < 30 ? DefaultStyle.danger_500_main : DefaultStyle.main2_900
        }
    }
}
