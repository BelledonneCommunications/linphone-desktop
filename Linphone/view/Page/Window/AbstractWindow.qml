import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import Linphone
import UtilsCpp
import SettingsCpp
import DesktopToolsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ApplicationWindow {
    id: mainWindow
    x: 0
    y: 0
    width: Math.min(Math.round(1512 * DefaultStyle.dp), Screen.desktopAvailableWidth)
    height: Math.min(Math.round(982 * DefaultStyle.dp), Screen.desktopAvailableHeight)

    onActiveChanged: UtilsCpp.setLastActiveWindow(this)

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
            width: title.length === 0 ? Math.round(278 * DefaultStyle.dp) : Math.round(637 * DefaultStyle.dp)
        }
    }

    Popup {
        id: startCallPopup
        property FriendGui contact
        property bool videoEnabled
        // if currentCall, transfer call to contact
        property CallGui currentCall
        onContactChanged: {
            console.log("contact changed", contact)
        }
        underlineColor: DefaultStyle.main1_500_main
        anchors.centerIn: parent
        width: Math.round(370 * DefaultStyle.dp)
        modal: true
        leftPadding: Math.round(15 * DefaultStyle.dp)
        rightPadding: Math.round(15 * DefaultStyle.dp)
        topPadding: Math.round(20 * DefaultStyle.dp)
        bottomPadding: Math.round(25 * DefaultStyle.dp)
        contentItem: ColumnLayout {
            spacing: Math.round(16 * DefaultStyle.dp)
            RowLayout {
                spacing: Math.round(5 * DefaultStyle.dp)
                width: startCallPopup.width
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
                    Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                    icon.source:AppIcons.closeX
                    onClicked: startCallPopup.close()
                }
            }
            ListView {
                id: popuplist
                model: VariantList {
                    model: startCallPopup.contact && startCallPopup.contact.core.allAddresses || []
                }
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                spacing: Math.round(10 * DefaultStyle.dp)
                delegate: Item {
                    width: popuplist.width
                    height: Math.round(56 * DefaultStyle.dp)
                    ColumnLayout {
                        width: popuplist.width
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Math.round(10 * DefaultStyle.dp)
                        ColumnLayout {
                            spacing: Math.round(7 * DefaultStyle.dp)
                            Text {
                                Layout.leftMargin: Math.round(5 * DefaultStyle.dp)
                                text: modelData.label + " :"
                                font {
                                    pixelSize: Typography.p2.pixelSize
                                    weight: Typography.p2.weight
                                }
                            }
                            Text {
                                Layout.leftMargin: Math.round(5 * DefaultStyle.dp)
                                text: SettingsCpp.onlyDisplaySipUriUsername ? UtilsCpp.getUsername(modelData.address) : modelData.address
                                font {
                                    pixelSize: Typography.p1.pixelSize
                                    weight: Typography.p1.weight
                                }
                            }
                        }
                        Rectangle {
                            visible: index != popuplist.model.count - 1
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.max(Math.round(1 * DefaultStyle.dp), 1)
                            color: DefaultStyle.main2_200
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (startCallPopup.currentCall) startCallPopup.currentCall.core.lTransferCall(modelData.address)
                            else UtilsCpp.createCall(modelData.address, {'localVideoEnabled': startCallPopup.videoEnabled})
                            startCallPopup.close()
                        }
                    }
                }
            }
        }
    }

    function startCallWithContact(contact, videoEnabled, parentItem) {
        if (parentItem == undefined) parentItem = mainWindow.contentItem
        startCallPopup.parent = parentItem
        if (contact) {
            console.log("START CALL WITH", contact.core.fullName, "addresses count", contact.core.allAddresses.length)
            if (contact.core.allAddresses.length > 1) {
                startCallPopup.contact = contact
                startCallPopup.videoEnabled = videoEnabled
                startCallPopup.open()

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

    function transferCallToContact(call, contact, parentItem) {
        if (!call || !contact) return
        if (parentItem == undefined) parentItem = mainWindow.contentItem
        startCallPopup.parent = parentItem
        if (contact) {
            console.log("[AbstractWindow] Transfer call to", contact.core.fullName, "addresses count", contact.core.allAddresses.length, call)
            if (contact.core.allAddresses.length > 1) {
                startCallPopup.contact = contact
                startCallPopup.currentCall = call
                startCallPopup.open()

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
        spacing: Math.round(15 * DefaultStyle.dp)
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
        padding: Math.round(20 * DefaultStyle.dp)
        underlineColor: DefaultStyle.main1_500_main
        radius: Math.round(15 * DefaultStyle.dp)
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
            font.pixelSize: Math.round(14 * DefaultStyle.dp)
            // "%1 FPS"
            text: qsTr("fps_counter").arg(parent.fps)
            color: parent.fps < 30 ? DefaultStyle.danger_500main : DefaultStyle.main2_900
        }
    }
}
