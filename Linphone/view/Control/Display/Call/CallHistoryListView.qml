import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import CustomControls 1.0
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ListView {
    id: mainItem
    clip: true
    keyNavigationEnabled: false // We will reimplement the keyNavigation
    activeFocusOnTab: true

    property SearchBar searchBar
    property bool loading: false
    property string searchText: searchBar?.text
    property real busyIndicatorSize: Utils.getSizeWithScreenRatio(60)
    property bool keyboardFocus: FocusHelper.keyboardFocus
    property bool lastFocusByNavigationKeyboard: false // Workaround to get the correct focusReason

    signal resultsReceived

    onResultsReceived: {
        loading = false
    }

    model: CallHistoryProxy {
        id: callHistoryProxy
        onListAboutToBeReset: loading = true
        filterText: mainItem.searchText
        onFilterTextChanged: maxDisplayItems = initialDisplayItems
        initialDisplayItems: Math.max(20, Math.round(2 * mainItem.height / Utils.getSizeWithScreenRatio(56)))
        displayItemsStep: 3 * initialDisplayItems / 2
        onModelAboutToBeReset: loading = true
        onModelReset: {
            mainItem.resultsReceived()
        }
    }
    flickDeceleration: 10000
    spacing: Utils.getSizeWithScreenRatio(10)

    Keys.onPressed: event => {
        if (event.key == Qt.Key_Escape) {
            console.log("Back")
            searchBar.forceActiveFocus(Qt.BacktabFocusReason)
            event.accepted = true
        }

        // Re-implement key navigation to have Qt.TabFocusReason and Qt.BacktabFocusReason instead of Qt.OtherFocusReason when using arrows to navigate in listView
        else if (event.key === Qt.Key_Up) {
            if(currentIndex === 0){
                searchBar.forceActiveFocus(Qt.BacktabFocusReason)
                lastFocusByNavigationKeyboard = false
            }else{
                decrementCurrentIndex()
                currentItem.forceActiveFocus(Qt.BacktabFocusReason) // The focusReason is created by QT later, need to create a workaround
                lastFocusByNavigationKeyboard = true
            }
            event.accepted = true
        }
        else if(event.key === Qt.Key_Down){
            incrementCurrentIndex()
            currentItem.forceActiveFocus(Qt.TabFocusReason) // The focusReason is created by QT later, need to create a workaround
            lastFocusByNavigationKeyboard = true
            event.accepted = true
        }
    }

    Component.onCompleted: cacheBuffer = Math.max(mainItem.height,0) //contentHeight>0 ? contentHeight : 0// cache all items
    // remove binding loop
    // onContentHeightChanged: Qt.callLater(function () {
    //     if (mainItem)
    //         mainItem.cacheBuffer = Math?.max(contentHeight, 0) || 0
    // })

    onActiveFocusChanged: if (activeFocus && currentIndex < 0 && count > 0) currentIndex = 0
    onCountChanged: {
        if (currentIndex < 0 && count > 0) {
            mainItem.currentIndex = 0 // Select first item after loading model
        }
        if (atYBeginning)
            positionViewAtBeginning() // Stay at beginning
    }
    Connections {
        target: deleteHistoryPopup
        function onAccepted() {
            mainItem.model.removeAllEntries()
        }
    }

    onAtYEndChanged: {
        if (atYEnd && count > 0) {
            callHistoryProxy.displayMore()
        }
    }
    //----------------------------------------------------------------
    function moveToCurrentItem() {
        if (mainItem.currentIndex >= 0)
            Utils.updatePosition(mainItem, mainItem)
    }
    onCurrentItemChanged: {
        moveToCurrentItem()
    }
    // Update position only if we are moving to current item and its position is changing.
    property var _currentItemY: currentItem?.y
    on_CurrentItemYChanged: if (_currentItemY && moveAnimation.running) {
        moveToCurrentItem()
    }
    Behavior on contentY {
        NumberAnimation {
            id: moveAnimation
            duration: 500
            easing.type: Easing.OutExpo
            alwaysRunToEnd: true
        }
    }

    //----------------------------------------------------------------

    BusyIndicator {
        anchors.horizontalCenter: mainItem.horizontalCenter
        visible: mainItem.loading
        height: visible ? mainItem.busyIndicatorSize : 0
        width: mainItem.busyIndicatorSize
        indicatorHeight: mainItem.busyIndicatorSize
        indicatorWidth: mainItem.busyIndicatorSize
        indicatorColor: DefaultStyle.main1_500_main
    }

    // Qt bug: sometimes, containsMouse may not be send and update on each MouseArea.
    // So we need to use this variable to switch off all hovered items.
    property int lastMouseContainsIndex: -1
    delegate: FocusScope {
        width: mainItem.width
        height: Utils.getSizeWithScreenRatio(56)
        Accessible.role: Accessible.ListItem

        RowLayout {
            z: 1
            anchors.fill: parent
            anchors.leftMargin: Utils.getSizeWithScreenRatio(10)
            spacing: Utils.getSizeWithScreenRatio(10)
            Avatar {
                id: historyAvatar
                property var contactObj: UtilsCpp.findFriendByAddress(modelData.core.remoteAddress)
                contact: contactObj?.value || null
                displayNameVal: modelData.core.displayName
                secured: securityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
                width: Utils.getSizeWithScreenRatio(45)
                height: Utils.getSizeWithScreenRatio(45)
                isConference: modelData.core.isConference
                shadowEnabled: false
                asynchronous: false
            }
            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: Utils.getSizeWithScreenRatio(5)
                Text {
                    Layout.fillWidth: true
                    maximumLineCount: 1
                    text: modelData.core.displayName
                    font {
                        pixelSize: Typography.p1.pixelSize
                        weight: Typography.p1.weight
                    }
                }
                RowLayout {
                    spacing: Utils.getSizeWithScreenRatio(6)
                    EffectImage {
                        id: statusIcon
                        imageSource: modelData.core.status === LinphoneEnums.CallStatus.Declined
                                     || modelData.core.status
                                     === LinphoneEnums.CallStatus.DeclinedElsewhere
                                     || modelData.core.status === LinphoneEnums.CallStatus.Aborted
                                     || modelData.core.status === LinphoneEnums.CallStatus.EarlyAborted ? AppIcons.arrowElbow : modelData.core.isOutgoing ? AppIcons.arrowUpRight : AppIcons.arrowDownLeft
                        colorizationColor: modelData.core.status
                                           === LinphoneEnums.CallStatus.Declined
                                           || modelData.core.status
                                           === LinphoneEnums.CallStatus.DeclinedElsewhere
                                           || modelData.core.status
                                           === LinphoneEnums.CallStatus.Aborted
                                           || modelData.core.status
                                           === LinphoneEnums.CallStatus.EarlyAborted
                                           || modelData.core.status === LinphoneEnums.CallStatus.Missed ? DefaultStyle.danger_500_main : modelData.core.isOutgoing ? DefaultStyle.info_500_main : DefaultStyle.success_500_main
                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(12)
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(12)
                        transform: Rotation {
                            angle: modelData.core.isOutgoing
                                   && (modelData.core.status === LinphoneEnums.CallStatus.Declined
                                       || modelData.core.status
                                       === LinphoneEnums.CallStatus.DeclinedElsewhere
                                       || modelData.core.status === LinphoneEnums.CallStatus.Aborted
                                       || modelData.core.status
                                       === LinphoneEnums.CallStatus.EarlyAborted) ? 180 : 0
                            origin {
                                x: statusIcon.width / 2
                                y: statusIcon.height / 2
                            }
                        }
                    }
                    Text {
                        // text: modelData.core.date
                        text: UtilsCpp.formatDate(modelData.core.date)
                        font {
                            pixelSize: Utils.getSizeWithScreenRatio(12)
                            weight: Utils.getSizeWithScreenRatio(300)
                        }
                    }
                }
            }
            BigButton {
                id: callButton
                visible: !modelData.core.isConference || !SettingsCpp.disableMeetingsFeature
                style: ButtonStyle.noBackground
                icon.source: AppIcons.phone
                focus: false
                activeFocusOnTab: false
                asynchronous: false
                
                //: Call %1
                Accessible.name: qsTr("call_name_accessible_button").arg(historyAvatar.displayNameVal)
                onClicked: {
                    if (modelData.core.isConference) {
                        var callsWindow = UtilsCpp.getOrCreateCallsWindow()
                        callsWindow.setupConference(
                                    modelData.core.conferenceInfo)
                        UtilsCpp.smartShowWindow(callsWindow)
                    } else {
                        UtilsCpp.createCall(modelData.core.remoteAddress)
                    }
                }
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Left){
                        backgroundMouseArea.forceActiveFocus(Qt.BacktabFocusReason)
                        lastFocusByNavigationKeyboard = true;
                    }
                }
                onActiveFocusChanged: {
                    if (!activeFocus) {
                        console.log("Unfocus button");
                        callButton.focus = false // Make sure to be unfocusable (could be when called by forceActiveFocus)
                        backgroundMouseArea.focus = true
                    }
                }
            }
        }
        MouseArea {
            id: backgroundMouseArea
            hoverEnabled: true
            anchors.fill: parent
            focus: true
            property bool keyboardFocus: FocusHelper.keyboardFocus || activeFocus && lastFocusByNavigationKeyboard

            //: %1 - %2 - %3 - right arrow for call-back button
            Accessible.name: qsTr("call_history_entry_accessible_name").arg(
                    //: "Appel manqué"
                    modelData.core.status === LinphoneEnums.CallStatus.Missed ? qsTr("notification_missed_call_title")
                    //: "Appel sortant"
                    : modelData.core.isOutgoing ? qsTr("call_outgoing")
                    //: "Appel entrant"
                    : qsTr("call_audio_incoming")
                ).arg(historyAvatar.displayNameVal).arg(UtilsCpp.formatDate(modelData.core.date))
            
            onContainsMouseChanged: {
                if (containsMouse)
                    mainItem.lastMouseContainsIndex = index
                else if (mainItem.lastMouseContainsIndex == index)
                    mainItem.lastMouseContainsIndex = -1
            }
            Rectangle {
                anchors.fill: parent
                opacity: 0.7
                radius: Utils.getSizeWithScreenRatio(8)
                color: mainItem.currentIndex
                       === index ? DefaultStyle.main2_200 : DefaultStyle.main2_100
				border.color: backgroundMouseArea.keyboardFocus ? DefaultStyle.main2_900 : "transparent"
				border.width: backgroundMouseArea.keyboardFocus ? Utils.getSizeWithScreenRatio(3) : 0
                visible: mainItem.lastMouseContainsIndex === index
                         || mainItem.currentIndex === index
            }
            onPressed: {
                mainItem.currentIndex = model.index
                mainItem.forceActiveFocus()
                mainItem.lastFocusByNavigationKeyboard = false
            }
            Keys.onPressed: event => {
                if(event.key === Qt.Key_Right){
                    callButton.forceActiveFocus(Qt.TabFocusReason)
                }
            }
        }
    }
}
