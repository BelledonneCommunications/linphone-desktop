import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ListView {
    id: mainItem
    clip: true

    property SearchBar searchBar
    property bool loading: false
    property string searchText: searchBar?.text
    property real busyIndicatorSize: Math.round(60 * DefaultStyle.dp)

    signal resultsReceived

    onResultsReceived: {
        loading = false
        // contentY = 0
    }

    model: CallHistoryProxy {
        id: callHistoryProxy
        Component.onCompleted: {
            loading = true
        }
        filterText: mainItem.searchText
        onFilterTextChanged: maxDisplayItems = initialDisplayItems
        initialDisplayItems: Math.max(
                                 20,
                                 2 * mainItem.height / (Math.round(56 * DefaultStyle.dp)))
        displayItemsStep: 3 * initialDisplayItems / 2
        onModelReset: {
            mainItem.resultsReceived()
        }
    }
    flickDeceleration: 10000
    spacing: Math.round(10 * DefaultStyle.dp)

    Keys.onPressed: event => {
                        if (event.key == Qt.Key_Escape) {
                            console.log("Back")
                            searchBar.forceActiveFocus()
                            event.accepted = true
                        }
                    }

    Component.onCompleted: cacheBuffer = Math.max(
                               contentHeight,
                               0) //contentHeight>0 ? contentHeight : 0// cache all items
    // remove binding loop
    onContentHeightChanged: Qt.callLater(function () {
        if (mainItem)
            mainItem.cacheBuffer = Math?.max(contentHeight, 0) || 0
    })

    onActiveFocusChanged: if (activeFocus && currentIndex < 0 && count > 0)
                              currentIndex = 0
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
    onVisibleChanged: {
//        if (!visible)
//            currentIndex = -1
    }

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
        height: Math.round(56 * DefaultStyle.dp)
        RowLayout {
            z: 1
            anchors.fill: parent
            anchors.leftMargin: Math.round(10 * DefaultStyle.dp)
            spacing: Math.round(10 * DefaultStyle.dp)
            Avatar {
                id: historyAvatar
                property var contactObj: UtilsCpp.findFriendByAddress(
                                             modelData.core.remoteAddress)
                contact: contactObj?.value || null
                displayNameVal: modelData.core.displayName
                secured: securityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
                width: Math.round(45 * DefaultStyle.dp)
                height: Math.round(45 * DefaultStyle.dp)
                isConference: modelData.core.isConference
                shadowEnabled: false
                asynchronous: false
            }
            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: Math.round(5 * DefaultStyle.dp)
                Text {
                    id: friendAddress
                    Layout.fillWidth: true
                    maximumLineCount: 1
                    text: historyAvatar.displayNameVal
                    font {
                        pixelSize: Typography.p1.pixelSize
                        weight: Typography.p1.weight
                        capitalization: Font.Capitalize
                    }
                }
                RowLayout {
                    spacing: Math.round(6 * DefaultStyle.dp)
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
                                           || modelData.core.status === LinphoneEnums.CallStatus.Missed ? DefaultStyle.danger_500main : modelData.core.isOutgoing ? DefaultStyle.info_500_main : DefaultStyle.success_500main
                        Layout.preferredWidth: Math.round(12 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(12 * DefaultStyle.dp)
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
                            pixelSize: Math.round(12 * DefaultStyle.dp)
                            weight: Math.round(300 * DefaultStyle.dp)
                        }
                    }
                }
            }
            BigButton {
                style: ButtonStyle.noBackground
                icon.source: AppIcons.phone
                focus: true
                activeFocusOnTab: false
                asynchronous: false
                onClicked: {
                    if (modelData.core.isConference) {
                        var callsWindow = UtilsCpp.getCallsWindow()
                        callsWindow.setupConference(
                                    modelData.core.conferenceInfo)
                        UtilsCpp.smartShowWindow(callsWindow)
                    } else {
                        UtilsCpp.createCall(modelData.core.remoteAddress)
                    }
                }
            }
        }
        MouseArea {
            hoverEnabled: true
            anchors.fill: parent
            focus: true
            onContainsMouseChanged: {
                if (containsMouse)
                    mainItem.lastMouseContainsIndex = index
                else if (mainItem.lastMouseContainsIndex == index)
                    mainItem.lastMouseContainsIndex = -1
            }
            Rectangle {
                anchors.fill: parent
                opacity: 0.7
                radius: Math.round(8 * DefaultStyle.dp)
                color: mainItem.currentIndex
                       === index ? DefaultStyle.main2_200 : DefaultStyle.main2_100
                visible: mainItem.lastMouseContainsIndex === index
                         || mainItem.currentIndex === index
            }
            onPressed: {
                mainItem.currentIndex = model.index
                mainItem.forceActiveFocus()
            }
        }
    }
}
