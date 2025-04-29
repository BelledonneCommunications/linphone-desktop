import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Basic as Control
import Linphone
import EnumsToStringCpp
import UtilsCpp
import SettingsCpp
import DesktopToolsCpp
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle

AbstractWindow {
    id: mainWindow
    flags: Qt.Window

    // modality: Qt.WindowModal
    property CallGui call

    property ConferenceGui conference: call && call.core.conference || null
    property bool isConference: call ? call.core.isConference : false

    property int conferenceLayout: call && call.core.conferenceVideoLayout || 0
    property bool localVideoEnabled: call && call.core.localVideoEnabled
    property bool remoteVideoEnabled: call && call.core.remoteVideoEnabled

    property bool callTerminatedByUser: false
    property var callState: call ? call.core.state : LinphoneEnums.CallState.Idle
    property var transferState: call && call.core.transferState

    onCallStateChanged: {
        if (callState === LinphoneEnums.CallState.Connected) {
            if (middleItemStackView.currentItem.objectName != "inCallItem") {
                middleItemStackView.replace(inCallItem)
                bottomButtonsLayout.visible = true
            }
            if (call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp
                    && !mainWindow.isConference && (!call.core.tokenVerified
                                                    || call.core.isMismatch)) {
                zrtpValidation.open()
            }
        } else if (callState === LinphoneEnums.CallState.Error
                   || callState === LinphoneEnums.CallState.End) {
            zrtpValidation.close()
            callEnded(call)
        }
    }

    onTransferStateChanged: {
        console.log("Transfer state:", transferState)
        if (mainWindow.transferState === LinphoneEnums.CallState.OutgoingInit) {
            var callsWin = UtilsCpp.getCallsWindow()
            if (!callsWin)
                return
            //: "Transfert en cours, veuillez patienter"
            callsWin.showLoadingPopup(qsTr("call_transfer_in_progress_toast"))
        } else if (mainWindow.transferState === LinphoneEnums.CallState.Error
                   || mainWindow.transferState === LinphoneEnums.CallState.End
                   || mainWindow.transferState === LinphoneEnums.CallState.Released
                   || mainWindow.transferState === LinphoneEnums.CallState.Connected) {
            var callsWin = UtilsCpp.getCallsWindow()
            callsWin.closeLoadingPopup()
            if (transferState === LinphoneEnums.CallState.Error)
                UtilsCpp.showInformationPopup(
                            qsTr("information_popup_error_title"),
                            //: "Le transfert d'appel a échoué"
                            qsTr("call_transfer_failed_toast"), false,
                            mainWindow)
            else if (transferState === LinphoneEnums.CallState.Connected) {
                var mainWin = UtilsCpp.getMainWindow()
                UtilsCpp.smartShowWindow(mainWin)
                mainWin.transferCallSucceed()
            }
        }
    }
    onClosing: close => {
                   DesktopToolsCpp.screenSaverStatus = true
                   if (callsModel.haveCall) {
                       close.accepted = false
                       terminateAllCallsDialog.open()
                   }
                   if (middleItemStackView.currentItem.objectName === "waitingRoom")
                   middleItemStackView.replace(inCallItem)
               }

    function changeLayout(layoutIndex) {
        if (layoutIndex == 0) {
            console.log("Set Grid layout")
            call.core.lSetConferenceVideoLayout(
                        LinphoneEnums.ConferenceLayout.Grid)
        } else if (layoutIndex == 1) {
            console.log("Set AS layout")
            call.core.lSetConferenceVideoLayout(
                        LinphoneEnums.ConferenceLayout.ActiveSpeaker)
        } else {
            console.log("Set audio-only layout")
            call.core.lSetConferenceVideoLayout(
                        LinphoneEnums.ConferenceLayout.AudioOnly)
        }
    }

    function endCall(callToFinish) {
        if (callToFinish)
            callToFinish.core.lTerminate()
        // var mainWin = UtilsCpp.getMainWindow()
        // mainWin.goToCallHistory()
    }
    function callEnded(call) {
        if (call && call.core.state === LinphoneEnums.CallState.Error) {
            middleItemStackView.replace(inCallItem)
        }
        if (!callsModel.haveCall) {
            if (call && call.core.isConference)
                UtilsCpp.closeCallsWindow()
            else {
                bottomButtonsLayout.setButtonsEnabled(false)
                autoCloseWindow.restart()
            }
        } else {
            if (middleItemStackView.currentItem.objectName === "waitingRoom") {
                middleItemStackView.replace(inCallItem)
            }
            mainWindow.call = callsModel.currentCall
        }
    }

    signal setUpConferenceRequested(ConferenceInfoGui conferenceInfo)
    function setupConference(conferenceInfo) {
        middleItemStackView.replace(waitingRoom)
        setUpConferenceRequested(conferenceInfo)
    }

    function joinConference(uri, options) {
        if (uri.length === 0)
            UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                                          //: "La conférence n'a pas pu démarrer en raison d'une erreur d'uri."
                                          qsTr("conference_error_empty_uri"),mainWindow)
        else {
            UtilsCpp.createCall(uri, options)
        }
    }
    function cancelJoinConference() {
        if (!callsModel.haveCall) {
            UtilsCpp.closeCallsWindow()
        } else {
            mainWindow.call = callsModel.currentCall
        }
        middleItemStackView.replace(inCallItem)
    }
    function cancelAfterJoin() {
        endCall(mainWindow.call)
    }

    Connections {
        enabled: !!mainWindow.call
        target: mainWindow.call && mainWindow.call.core
        function onSecurityUpdated() {
            if (mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp) {
                if (call.core.tokenVerified) {
                    zrtpValidation.close()
                    zrtpValidationToast.open()
                } else {
                    zrtpValidation.open()
                }
            } else {
                zrtpValidation.close()
            }
        }
        function onTokenVerified() {
            if (!zrtpValidation.isTokenVerified) {
                zrtpValidation.securityError = true
            } else
                zrtpValidation.close()
        }
    }

    Timer {
        id: autoCloseWindow
        interval: mainWindow.callTerminatedByUser ? 1500 : 2500
        onTriggered: {
            UtilsCpp.closeCallsWindow()
        }
    }

    Dialog {
        id: terminateAllCallsDialog
        onAccepted: {
            mainWindow.callTerminatedByUser = true
            call.core.lTerminateAllCalls()
        }
        width: Math.round(278 * DefaultStyle.dp)
        //: "Terminer tous les appels en cours ?"
        title: qsTr("call_close_window_dialog_title")
        //: "La fenêtre est sur le point d'être fermée. Cela terminera tous les appels en cours."
        text: qsTr("call_close_window_dialog_message")
    }

    CallProxy {
        id: callsModel
        sourceModel: AppCpp.calls
        onCurrentCallChanged: {
            if (currentCall) {
                mainWindow.call = currentCall
            }
        }
        onHaveCallChanged: {
            if (!haveCall) {
                mainWindow.callEnded()
            }
        }
    }

    component BottomButton: Button {
        id: bottomButton
        required property string enabledIcon
        property string disabledIcon
        enabled: call != undefined
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        checkable: true
        background: Rectangle {
            anchors.fill: parent
            color: bottomButton.enabled ? disabledIcon ? DefaultStyle.grey_500 : bottomButton.pressed || bottomButton.checked ? DefaultStyle.main2_400 : DefaultStyle.grey_500 : DefaultStyle.grey_600
            radius: Math.round(71 * DefaultStyle.dp)
        }
        icon.source: disabledIcon
                     && bottomButton.checked ? disabledIcon : enabledIcon
        icon.width: Math.round(32 * DefaultStyle.dp)
        icon.height: Math.round(32 * DefaultStyle.dp)
        contentImageColor: DefaultStyle.grey_0
    }
    ZrtpAuthenticationDialog {
        id: zrtpValidation
        call: mainWindow.call
        modal: true
        closePolicy: Popup.NoAutoClose
    }
    Timer {
        id: autoCloseZrtpToast
        interval: 4000
        onTriggered: {
            zrtpValidationToast.y = -zrtpValidationToast.height * 2
        }
    }
    Control.Control {
        id: zrtpValidationToast
        // width: Math.round(269 * DefaultStyle.dp)
        y: -height * 2
        z: 1
        topPadding: Math.round(8 * DefaultStyle.dp)
        bottomPadding: Math.round(8 * DefaultStyle.dp)
        leftPadding: Math.round(50 * DefaultStyle.dp)
        rightPadding: Math.round(50 * DefaultStyle.dp)
        anchors.horizontalCenter: parent.horizontalCenter
        clip: true
        function open() {
            if (mainWindow.isConference)
                return
            y = headerItem.height / 2
            autoCloseZrtpToast.restart()
        }
        Behavior on y {
            NumberAnimation {
                duration: 1000
            }
        }
        background: Rectangle {
            anchors.fill: parent
            color: DefaultStyle.grey_0
            border.color: DefaultStyle.info_500_main
            border.width: Math.max(Math.round(1 * DefaultStyle.dp), 1)
            radius: Math.round(50 * DefaultStyle.dp)
        }
        contentItem: RowLayout {
            // anchors.centerIn: parent
            Image {
                source: AppIcons.trusted
                Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                fillMode: Image.PreserveAspectFit
                Layout.fillWidth: true
            }
            Text {
                color: DefaultStyle.info_500_main
                //: "Appareil authentifié"
                text: qsTr("call_can_be_trusted_toast")
                Layout.fillWidth: true
                font {
                    pixelSize: Math.round(14 * DefaultStyle.dp)
                }
            }
        }
    }

    /************************* CONTENT ********************************/
    Rectangle {
        anchors.fill: parent
        color: DefaultStyle.grey_900
        Keys.onEscapePressed: {
            if (mainWindow.visibility == Window.FullScreen)
                mainWindow.showNormal()
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: Math.round(10 * DefaultStyle.dp)
            anchors.bottomMargin: Math.round(10 * DefaultStyle.dp)
            anchors.topMargin: Math.round(10 * DefaultStyle.dp)
            Item {
                id: headerItem
                Layout.margins: Math.round(10 * DefaultStyle.dp)
                Layout.leftMargin: Math.round(20 * DefaultStyle.dp)
                Layout.fillWidth: true
                Layout.minimumHeight: Math.round(25 * DefaultStyle.dp)
                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Math.round(10 * DefaultStyle.dp)
                    RowLayout {
                        spacing: Math.round(10 * DefaultStyle.dp)
                        EffectImage {
                            id: callStatusIcon
                            Layout.preferredWidth: Math.round(30 * DefaultStyle.dp)
                            Layout.preferredHeight: Math.round(30 * DefaultStyle.dp)
                            // TODO : change with broadcast or meeting icon when available
                            imageSource: !mainWindow.call ? AppIcons.meeting : (mainWindow.callState === LinphoneEnums.CallState.End || mainWindow.callState === LinphoneEnums.CallState.Released) ? AppIcons.endCall : (mainWindow.callState === LinphoneEnums.CallState.Paused || mainWindow.callState === LinphoneEnums.CallState.PausedByRemote) ? AppIcons.pause : mainWindow.conference ? AppIcons.usersThree : mainWindow.call.core.dir === LinphoneEnums.CallDir.Outgoing ? AppIcons.arrowUpRight : AppIcons.arrowDownLeft
                            colorizationColor: !mainWindow.call
                                               || mainWindow.call.core.paused
                                               || mainWindow.callState
                                               === LinphoneEnums.CallState.Paused
                                               || mainWindow.callState
                                               === LinphoneEnums.CallState.PausedByRemote
                                               || mainWindow.callState
                                               === LinphoneEnums.CallState.End
                                               || mainWindow.callState
                                               === LinphoneEnums.CallState.Released
                                               || mainWindow.conference ? DefaultStyle.danger_500main : mainWindow.call.core.dir === LinphoneEnums.CallDir.Outgoing ? DefaultStyle.info_500_main : DefaultStyle.success_500main
                            onColorizationColorChanged: {
                                callStatusIcon.active = !callStatusIcon.active
                                callStatusIcon.active = !callStatusIcon.active
                            }
                        }
                        ColumnLayout {
                            spacing: Math.round(6 * DefaultStyle.dp)
                            RowLayout {
                                spacing: Math.round(10 * DefaultStyle.dp)
                                Text {
                                    id: callStatusText
                                    property string remoteName: mainWindow.call ? qsTr("call_dir").arg(EnumsToStringCpp.dirToString(mainWindow.call.core.dir)) : ""
                                    Connections {
                                        target: mainWindow
                                        onCallStateChanged: {
                                            if (mainWindow.callState === LinphoneEnums.CallState.Connected || mainWindow.callState === LinphoneEnums.CallState.StreamsRunning)
                                               callStatusText.remoteName = mainWindow.call.core.remoteName
                                        }
                                    }

                                    text: (mainWindow.callState === LinphoneEnums.CallState.End || mainWindow.callState === LinphoneEnums.CallState.Released)
                                        //: Appel terminé
                                        ? qsTr("call_ended")
                                        : mainWindow.call && (mainWindow.call.core.paused)
                                            ? (mainWindow.conference
                                               //: Meeting paused
                                                ? qsTr("conference_paused")
                                                : mainWindow.callState === LinphoneEnums.CallState.PausedByRemote
                                                    //: Call paused by remote
                                                    ? qsTr("call_paused_by_remote")
                                                    //: Call paused
                                                    : qsTr("call_paused"))
                                            : mainWindow.conference
                                                ? mainWindow.conference.core.subject
                                                : remoteName
                                    color: DefaultStyle.grey_0
                                    font {
                                        pixelSize: Typography.h3.pixelSize
                                        weight: Typography.h3.weight
                                    }
                                }
                                Rectangle {
                                    visible: mainWindow.call
                                             && (mainWindow.callState
                                                 === LinphoneEnums.CallState.Connected
                                                 || mainWindow.callState
                                                 === LinphoneEnums.CallState.StreamsRunning)
                                    Layout.fillHeight: true
                                    Layout.topMargin: Math.round(10 * DefaultStyle.dp)
                                    Layout.bottomMargin: Math.round(2 * DefaultStyle.dp)
                                    Layout.preferredWidth: Math.round(2 * DefaultStyle.dp)
                                    color: DefaultStyle.grey_0
                                }
                                Text {
                                    text: mainWindow.call ? UtilsCpp.formatElapsedTime(
                                                                mainWindow.call.core.duration) : ""
                                    color: DefaultStyle.grey_0
                                    font {
                                        pixelSize: Typography.h3.pixelSize
                                        weight: Typography.h3.weight
                                    }
                                    visible: mainWindow.callState
                                             === LinphoneEnums.CallState.Connected
                                             || mainWindow.callState
                                             === LinphoneEnums.CallState.StreamsRunning
                                }
                                Text {
                                    Layout.leftMargin: Math.round(14 * DefaultStyle.dp)
                                    id: conferenceDate
                                    text: mainWindow.conferenceInfo ? mainWindow.conferenceInfo.core.getStartEndDateString(
                                                                          ) : ""
                                    color: DefaultStyle.grey_0
                                    font {
                                        pixelSize: Typography.p1.pixelSize
                                        weight: Typography.p1.weight
                                        capitalization: Font.Capitalize
                                    }
                                }
                            }
                            RowLayout {
                                id: securityStateLayout
                                spacing: Math.round(5 * DefaultStyle.dp)
                                visible: false
                                Connections {
                                    target: mainWindow
                                    function onCallStateChanged() {
                                        if (mainWindow.callState
                                                === LinphoneEnums.CallState.Connected)
                                            securityStateLayout.visible = true
                                        else if (mainWindow.callState
                                                 === LinphoneEnums.CallState.End
                                                 || mainWindow.callState
                                                 === LinphoneEnums.CallState.Released)
                                            securityStateLayout.visible = false
                                    }
                                }
                                BusyIndicator {
                                    visible: encryptionStatusText.text === qsTr("call_waiting_for_encryption_info")
                                    Layout.preferredWidth: Math.round(15 * DefaultStyle.dp)
                                    Layout.preferredHeight: Math.round(15 * DefaultStyle.dp)
                                    indicatorColor: DefaultStyle.grey_0
                                }
                                EffectImage {
                                    Layout.preferredWidth: Math.round(15 * DefaultStyle.dp)
                                    Layout.preferredHeight: Math.round(15 * DefaultStyle.dp)
                                    colorizationColor: mainWindow.call 
                                        ? mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Srtp 
                                            ? DefaultStyle.info_500_main 
                                            : mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp 
                                                ? mainWindow.call.core.isMismatch || !mainWindow.call.core.tokenVerified 
                                                    ? DefaultStyle.warning_600 
                                                    : DefaultStyle.info_500_main 
                                                : DefaultStyle.grey_0 
                                        : "transparent"
                                    visible: mainWindow.call
                                    imageSource: mainWindow.call
                                        ? mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Srtp
                                            ? AppIcons.lockSimple
                                            : mainWindow.call && mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp
                                                ? mainWindow.call.core.isMismatch || !mainWindow.call.core.tokenVerified
                                                    ? AppIcons.warningCircle
                                                    : AppIcons.lockKey
                                                : AppIcons.lockSimpleOpen
                                        : ""
                                }
                                Text {
                                    id: encryptionStatusText
                                    text: mainWindow.conference
                                        //: Appel chiffré de bout en bout
                                        ? qsTr("call_zrtp_end_to_end_encrypted")
                                        :mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Srtp
                                          //: Appel chiffré de point à point
                                            ? qsTr("call_srtp_point_to_point_encrypted")
                                            : mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp
                                                ? mainWindow.call.core.isMismatch || !mainWindow.call.core.tokenVerified
                                                  //: Vérification nécessaire
                                                    ? qsTr("call_zrtp_sas_validation_required")
                                                    : qsTr("call_zrtp_end_to_end_encrypted")
                                                : mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.None
                                                    //: "Appel non chiffré"
                                                    ? qsTr("call_not_encrypted")
                                                    //: "En attente de chiffrement"
                                                    : qsTr("call_waiting_for_encryption_info")
                                    color: mainWindow.conference || mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Srtp
                                        ? DefaultStyle.info_500_main
                                        : mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp
                                            ? mainWindow.call.core.isMismatch || !mainWindow.call.core.tokenVerified
                                                ? DefaultStyle.warning_600
                                                : DefaultStyle.info_500_main
                                            : DefaultStyle.grey_0
                                    font {
                                        pixelSize: Math.round(12 * DefaultStyle.dp)
                                        weight: Math.round(400 * DefaultStyle.dp)
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: {
                                            if (rightPanel.visible
                                                    && rightPanel.contentStackView.currentItem.objectName
                                                    === "encryptionPanel")
                                                rightPanel.visible = false
                                            else {
                                                rightPanel.visible = true
                                                rightPanel.replace(encryptionPanel)
                                            }
                                        }
                                    }
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    EffectImage {
                        Layout.preferredWidth: Math.round(32 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(32 * DefaultStyle.dp)
                        Layout.rightMargin: Math.round(30 * DefaultStyle.dp)
                        property int quality: mainWindow.call ? mainWindow.call.core.quality : 0
                        imageSource: quality >= 4 ? AppIcons.cellSignalFull : quality >= 3 ? AppIcons.cellSignalMedium : quality >= 2 ? AppIcons.cellSignalLow : AppIcons.cellSignalNone
                        colorizationColor: DefaultStyle.grey_0
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (rightPanel.visible
                                        && rightPanel.contentStackView.currentItem.objectName
                                        === "statsPanel")
                                    rightPanel.visible = false
                                else {
                                    rightPanel.visible = true
                                    rightPanel.replace(statsPanel)
                                }
                            }
                        }
                    }
                }

                Control.Control {
                    visible: mainWindow.call ? !!mainWindow.conference ? mainWindow.conference.core.isRecording : (mainWindow.call.core.recording || mainWindow.call.core.remoteRecording) : false
                    anchors.centerIn: parent
                    leftPadding: Math.round(14 * DefaultStyle.dp)
                    rightPadding: Math.round(14 * DefaultStyle.dp)
                    topPadding: Math.round(6 * DefaultStyle.dp)
                    bottomPadding: Math.round(6 * DefaultStyle.dp)
                    background: Rectangle {
                        anchors.fill: parent
                        color: DefaultStyle.grey_500
                        radius: Math.round(10 * DefaultStyle.dp)
                    }
                    contentItem: RowLayout {
                        spacing: Math.round(85 * DefaultStyle.dp)
                        RowLayout {
                            spacing: Math.round(15 * DefaultStyle.dp)
                            EffectImage {
                                imageSource: AppIcons.recordFill
                                colorizationColor: DefaultStyle.danger_500main
                                Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                                Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                            }
                            Text {
                                color: DefaultStyle.danger_500main
                                font.pixelSize: Math.round(14 * DefaultStyle.dp)
                                text: mainWindow.call
                                    ? mainWindow.call.core.recording
                                        ? mainWindow.conference
                                          //: "Vous enregistrez la réunion"
                                            ? qsTr("conference_user_is_recording")
                                              //: "Vous enregistrez l'appel"
                                            : qsTr("call_user_is_recording")
                                        : mainWindow.conference
                                            //: "Un participant enregistre la réunion"
                                            ? qsTr("conference_remote_is_recording")
                                            //: "%1 enregistre l'appel"
                                            : qsTr("call_remote_recording").arg(mainWindow.call.core.remoteName)
                                    : ""
                            }
                        }
                        BigButton {
                            visible: mainWindow.call
                                     && mainWindow.call.core.recording
                            //: "Arrêter l'enregistrement"
                            text: qsTr("call_stop_recording")
                            style: ButtonStyle.main
                            onPressed: mainWindow.call.core.lStopRecording()
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Math.round(23 * DefaultStyle.dp)
                Control.StackView {
                    id: middleItemStackView
                    initialItem: inCallItem
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                CallSettingsPanel {
                    id: rightPanel
                    Layout.fillHeight: true
                    Layout.rightMargin: Math.round(20 * DefaultStyle.dp)
                    Layout.preferredWidth: Math.round(393 * DefaultStyle.dp)
                    Layout.topMargin: Math.round(10 * DefaultStyle.dp)
                    property int currentIndex: 0
                    visible: false
                    function replace(id) {
                        rightPanel.customHeaderButtons = null
                        contentStackView.replace(id,
                                                 Control.StackView.Immediate)
                    }
                    headerStack.currentIndex: 0
                    contentStackView.initialItem: callListPanel
                    headerValidateButtonText: qsTr("add")

                    Binding on topPadding {
                        when: rightPanel.contentStackView.currentItem.objectName === "chatPanel"
                        value: 0
                    }
                    Binding on leftPadding {
                        when: rightPanel.contentStackView.currentItem.objectName === "chatPanel"
                        value: 0
                    }
                    Binding on rightPadding {
                        when: rightPanel.contentStackView.currentItem.objectName == "chatPanel"
                        value: 0
                    }

                    Item {
                        id: numericPadContainer
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: childrenRect.height
                    }
                }
            }

            Component {
                id: callTransferPanel
                NewCallForm {
                    id: newCallForm
                    //: "Transférer %1 à…"
                    Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("call_transfer_current_call_title").arg(mainWindow.call.core.remoteName)
                    Keys.onEscapePressed: event => {
                                              rightPanel.visible = false
                                              event.accepted = true
                                          }
                    groupCallVisible: false
                    displayCurrentCalls: true
                    searchBarColor: DefaultStyle.grey_0
                    searchBarBorderColor: DefaultStyle.grey_200
                    onContactClicked: contact => {
                                          var callsWin = UtilsCpp.getCallsWindow()
                                          if (contact)
                                          //: "Confirmer le transfert"
                                          callsWin.showConfirmationLambdaPopup(qsTr("call_transfer_confirm_dialog_tittle"),
                                                                               //: "Vous allez transférer %1 à %2."
                                                                               qsTr("call_transfer_confirm_dialog_message").arg(mainWindow.call.core.remoteName).arg(contact.core.fullName), "",
                                              function (confirmed) {
                                                  if (confirmed) {
                                                      mainWindow.transferCallToContact(mainWindow.call,contact,newCallForm)
                                                  }
                                              })
                                      }
                    onTransferCallToAnotherRequested: dest => {
                                                          var callsWin = UtilsCpp.getCallsWindow()
                                                          console.log("transfer to",dest)
                                                          callsWin.showConfirmationLambdaPopup(qsTr("call_transfer_confirm_dialog_tittle"),
                                                                                               qsTr("call_transfer_confirm_dialog_message").arg(mainWindow.call.core.remoteName).arg(dest.core.remoteName),"",
                                                                function (confirmed) {
                                                                  if (confirmed) {
                                                                      mainWindow.call.core.lTransferCallToAnother(dest.core.remoteAddress)
                                                                  }
                                                          })
                                                      }
                    numPadPopup: numPadPopup

                    NumericPadPopup {
                        id: numPadPopup
                        parent: numericPadContainer
                        width: parent.width
                        roundedBottom: true
                        lastRowVisible: false
                        visible: false
                        leftPadding: Math.round(40 * DefaultStyle.dp)
                        rightPadding: Math.round(40 * DefaultStyle.dp)
                        topPadding: Math.round(41 * DefaultStyle.dp)
                        bottomPadding: Math.round(18 * DefaultStyle.dp)
                        Component.onCompleted: parent.height = height
                    }
                }
            }
            Component {
                id: newCallPanel
                NewCallForm {
                    id: newCallForm
                    objectName: "newCallPanel"
                    //: "Nouvel appel"
                    Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("call_action_start_new_call")
                    groupCallVisible: false
                    searchBarColor: DefaultStyle.grey_0
                    searchBarBorderColor: DefaultStyle.grey_200
                    numPadPopup: numericPad
                    onContactClicked: contact => {
                                          mainWindow.startCallWithContact(
                                              contact, false, rightPanel)
                                      }
                    Connections {
                        target: mainWindow
                        function onCallChanged() {
                            if (newCallForm.Control.StackView.status === Control.StackView.Active)
                                rightPanel.visible = false
                        }
                    }

                    NumericPadPopup {
                        id: numericPad
                        width: parent.width
                        parent: numericPadContainer
                        roundedBottom: true
                        visible: newCallForm.searchBar.numericPadButton.checked
                        leftPadding: Math.round(40 * DefaultStyle.dp)
                        rightPadding: Math.round(40 * DefaultStyle.dp)
                        topPadding: Math.round(41 * DefaultStyle.dp)
                        bottomPadding: Math.round(18 * DefaultStyle.dp)
                        onLaunchCall: {
                            rightPanel.visible = false
                            UtilsCpp.createCall(newCallForm.searchBar.text)
                        }
                        Component.onCompleted: parent.height = height
                    }
                }
            }
            Component {
                id: dialerPanel
                Item {
                    id: dialerPanelContent
                    //: "Pavé numérique"
                    Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("call_action_show_dialer")
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    Keys.onEscapePressed: event => {
                                              rightPanel.visible = false
                                              event.accepted = true
                                          }
                    SearchBar {
                        anchors.leftMargin: Math.round(10 * DefaultStyle.dp)
                        anchors.rightMargin: Math.round(10 * DefaultStyle.dp)
                        anchors.bottom: numPad.top
                        anchors.bottomMargin: Math.round(41 * DefaultStyle.dp)
                        magnifierVisible: false
                        color: DefaultStyle.grey_0
                        borderColor: DefaultStyle.grey_200
                        placeholderText: ""
                        numericPadPopup: numPad
                        numericPadButton.visible: false
                        enabled: false
                    }
                    NumericPad {
                        id: numPad
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        currentCall: callsModel.currentCall
                        lastRowVisible: false
                        anchors.bottomMargin: Math.round(18 * DefaultStyle.dp)
                        onLaunchCall: {
                            UtilsCpp.createCall(dialerTextInput.text)
                        }
                        Component.onCompleted: parent.height = height
                    }
                }
            }
            Component {
                id: changeLayoutPanel
                ChangeLayoutForm {
                    //: "Modifier la disposition"
                    Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("call_action_change_layout")
                    Keys.onEscapePressed: event => {
                                              rightPanel.visible = false
                                              event.accepted = true
                                          }
                    call: mainWindow.call
                    onChangeLayoutRequested: index => {
                                                 mainWindow.changeLayout(index)
                                             }
                }
            }
            Component {
                id: callListPanel
                ColumnLayout {
                    Control.StackView.onActivated: {
                        //: "Liste d'appel"
                        rightPanel.headerTitleText = qsTr("call_action_go_to_calls_list")
                        rightPanel.customHeaderButtons = mergeCallPopupButton.createObject(
                                    rightPanel)
                    }
                    Keys.onEscapePressed: event => {
                                              rightPanel.visible = false
                                              event.accepted = true
                                          }
                    spacing: 0
                    Component {
                        id: mergeCallPopupButton
                        PopupButton {
                            visible: callsModel.count >= 2
                            id: popupbutton
                            popup.contentItem: IconLabelButton {
                                icon.source: AppIcons.arrowsMerge
                                icon.width: Math.round(32 * DefaultStyle.dp)
                                icon.height: Math.round(32 * DefaultStyle.dp)
                                //: call_action_merge_calls
                                text: qsTr("Merger tous les appels")
                                textSize: Math.round(14 * DefaultStyle.dp)
                                onClicked: {
                                    callsModel.lMergeAll()
                                    popupbutton.close()
                                }
                            }
                        }
                    }
                    RoundedPane {
                        Layout.fillWidth: true
                        Layout.maximumHeight: rightPanel.height
                        visible: callList.contentHeight > 0
                        leftPadding: Math.round(16 * DefaultStyle.dp)
                        rightPadding: Math.round(6 * DefaultStyle.dp)
                        topPadding: Math.round(15 * DefaultStyle.dp)
                        bottomPadding: Math.round(16 * DefaultStyle.dp)

                        Layout.topMargin: Math.round(15 * DefaultStyle.dp)
                        Layout.bottomMargin: Math.round(16 * DefaultStyle.dp)
                        Layout.leftMargin: Math.round(16 * DefaultStyle.dp)
                        Layout.rightMargin: Math.round(16 * DefaultStyle.dp)

                        contentItem: CallListView {
                            id: callList
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
            Component {
                id: chatPanel
                Item {
                    id: chatPanelContent
                    objectName: "chatPanel"
                    Control.StackView.onActivated: {
                        rightPanel.customHeaderButtons = chatView.callHeaderContent
                        rightPanel.headerTitleText = ""
                    }
                    Keys.onEscapePressed: event => {
                        rightPanel.visible = false
                        event.accepted = true
                    }
                    SelectedChatView {
                        id: chatView
                        anchors.fill: parent
                        call: mainWindow.call
                        property var chatObj: UtilsCpp.getCurrentCallChat(mainWindow.call)
                        chat: chatObj ? chatObj.value : null
                    }
                }
            }
            Component {
                id: settingsPanel
                Item {
                    Control.StackView.onActivated: {
                        //: "Paramètres"
                        rightPanel.headerTitleText = qsTr("call_action_go_to_settings")
                    }
                    Keys.onEscapePressed: event => {
                                              rightPanel.visible = false
                                              event.accepted = true
                                          }
                    MultimediaSettings {
                        id: inSettingsPanel
                        call: mainWindow.call
                        anchors.fill: parent
                        anchors.topMargin: Math.round(16 * DefaultStyle.dp)
                        anchors.bottomMargin: Math.round(16 * DefaultStyle.dp)
                        anchors.leftMargin: Math.round(17 * DefaultStyle.dp)
                        anchors.rightMargin: Math.round(17 * DefaultStyle.dp)
                    }
                }
            }
            Component {
                id: screencastPanel
                Item {
                    //: "Partage de votre écran"
                    Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("conference_action_screen_sharing")
                    Keys.onEscapePressed: event => {
                                              rightPanel.visible = false
                                              event.accepted = true
                                          }
                    ScreencastSettings {
                        anchors.fill: parent
                        anchors.topMargin: Math.round(16 * DefaultStyle.dp)
                        anchors.bottomMargin: Math.round(16 * DefaultStyle.dp)
                        anchors.leftMargin: Math.round(17 * DefaultStyle.dp)
                        anchors.rightMargin: Math.round(17 * DefaultStyle.dp)
                        call: mainWindow.call
                    }
                }
            }
            Component {
                id: participantListPanel
                Item {
                    objectName: "participantListPanel"
                    Keys.onEscapePressed: event => {
                                              rightPanel.visible = false
                                              event.accepted = true
                                          }
                    Control.StackView {
                        id: participantsStack
                        anchors.fill: parent
                        anchors.bottomMargin: Math.round(16 * DefaultStyle.dp)
                        anchors.leftMargin: Math.round(17 * DefaultStyle.dp)
                        anchors.rightMargin: Math.round(17 * DefaultStyle.dp)
                        initialItem: participantListComp
                        onCurrentItemChanged: rightPanel.headerStack.currentIndex
                                              = currentItem.Control.StackView.index
                        property list<string> selectedParticipants

                        Connections {
                            target: rightPanel
                            function onReturnRequested() {
                                participantsStack.pop()
                            }
                        }

                        Component {
                            id: participantListComp
                            ParticipantListView {
                                id: participantList
                                Component {
                                    id: headerbutton
                                    PopupButton {
                                        popup.contentItem: IconLabelButton {
                                            icon.source: AppIcons.shareNetwork
                                            //: Partager le lien de la réunion
                                            text: qsTr("conference_share_link_title")
                                            onClicked: {
                                                UtilsCpp.copyToClipboard(mainWindow.call.core.remoteAddress)
                                                //: Copié
                                                showInformationPopup(qsTr("copied"),
                                                //: Le lien de la réunion a été copié dans le presse-papier
                                                qsTr("information_popup_meeting_address_copied_to_clipboard"),true)
                                            }
                                        }
                                    }
                                }
                                Control.StackView.onActivated: {
                                    rightPanel.customHeaderButtons = headerbutton.createObject(rightPanel)
                                    //: "Participants (%1)"
                                    rightPanel.headerTitleText = qsTr("conference_participants_list_title").arg(count)
                                }
                                call: mainWindow.call
                                onAddParticipantRequested: participantsStack.push(addParticipantComp)
                                onCountChanged: {
                                    rightPanel.headerTitleText = qsTr("conference_participants_list_title").arg(count)
                                }
                                Connections {
                                    target: participantsStack
                                    function onCurrentItemChanged() {
                                        if (participantsStack.currentItem == participantList)
                                            rightPanel.headerTitleText = qsTr("conference_participants_list_title").arg(participantList.count)
                                    }
                                }
                                Connections {
                                    target: rightPanel
                                    function onValidateRequested() {
                                        participantList.model.addAddresses(
                                                    participantsStack.selectedParticipants)
                                        participantsStack.pop()
                                    }
                                }
                            }
                        }
                        Component {
                            id: addParticipantComp
                            AddParticipantsForm {
                                id: addParticipantLayout
                                searchBarColor: DefaultStyle.grey_0
                                searchBarBorderColor: DefaultStyle.grey_200
                                onSelectedParticipantsCountChanged: {
                                    rightPanel.headerSubtitleText = qsTr("group_call_participant_selected", '', selectedParticipantsCount).arg(selectedParticipantsCount)
                                    participantsStack.selectedParticipants = selectedParticipants
                                }
                                Connections {
                                    target: participantsStack
                                    function onCurrentItemChanged() {
                                        if (participantsStack.currentItem == addParticipantLayout) {
                                            rightPanel.headerTitleText = qsTr("meeting_schedule_add_participants_title")
                                            rightPanel.headerSubtitleText = qsTr("group_call_participant_selected", '', addParticipantLayout.selectedParticipants.length).arg(addParticipantLayout.selectedParticipants.length)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Component {
                id: encryptionPanel
                EncryptionSettings {
                    objectName: "encryptionPanel"
                    call: mainWindow.call
                    Control.StackView.onActivated: {
                        //: Chiffrement
                        rightPanel.headerTitleText = qsTr("call_encryption_title")
                    }
                    onEncryptionValidationRequested: zrtpValidation.open()
                }
            }
            Component {
                id: statsPanel
                CallStatistics {
                    objectName: "statsPanel"
                    Control.StackView.onActivated: {
                        //: Statistiques
                        rightPanel.headerTitleText = qsTr("call_stats_title")
                    }
                    call: mainWindow.call
                }
            }
            Component {
                id: waitingRoom
                WaitingRoom {
                    id: waitingRoomIn
                    objectName: "waitingRoom"
                    Layout.alignment: Qt.AlignCenter
                    onSettingsButtonCheckedChanged: {
                        if (settingsButtonChecked) {
                            rightPanel.visible = true
                            rightPanel.replace(settingsPanel)
                        } else {
                            rightPanel.visible = false
                        }
                    }
                    Binding {
                        target: callStatusIcon
                        when: middleItemStackView.currentItem.objectName === "waitingRoom"
                        property: "imageSource"
                        value: AppIcons.usersThree
                    }
                    Binding {
                        target: callStatusText
                        when: middleItemStackView.currentItem.objectName === "waitingRoom"
                        property: "text"
                        value: waitingRoomIn.conferenceInfo ? waitingRoomIn.conferenceInfo.core.subject : ''
                    }
                    Binding {
                        target: conferenceDate
                        when: middleItemStackView.currentItem.objectName === "waitingRoom"
                        property: "text"
                        value: waitingRoomIn.conferenceInfo ? waitingRoomIn.conferenceInfo.core.startEndDateString : ''
                    }
                    Connections {
                        target: rightPanel
                        function onVisibleChanged() {
                            if (!visible)
                                waitingRoomIn.settingsButtonChecked = false
                        }
                    }
                    Connections {
                        target: mainWindow
                        function onSetUpConferenceRequested(conferenceInfo) {
                            waitingRoomIn.conferenceInfo = conferenceInfo
                        }
                    }
                    onJoinConfRequested: uri => {
                                             mainWindow.joinConference(uri, {
                                                                           "microEnabled": microEnabled,
                                                                           "localVideoEnabled": localVideoEnabled
                                                                       })
                                         }
                    onCancelJoiningRequested: mainWindow.cancelJoinConference()
                    onCancelAfterJoinRequested: mainWindow.cancelAfterJoin()
                }
            }
            Component {
                id: inCallItem
                Loader {
                    property string objectName: "inCallItem"
                    asynchronous: true
                    sourceComponent: Item {
                        CallLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Math.round(20 * DefaultStyle.dp)
                            anchors.rightMargin: rightPanel.visible ? 0 : Math.round(10 * DefaultStyle.dp) // Grid and AS have 10 in right margin (so apply -10 here)
                            anchors.topMargin: Math.round(10 * DefaultStyle.dp)
                            call: mainWindow.call
                            callTerminatedByUser: mainWindow.callTerminatedByUser
                        }
                    }
                }
            }

            RowLayout {
                id: bottomButtonsLayout
                Layout.alignment: Qt.AlignHCenter
                spacing: Math.round(58 * DefaultStyle.dp)
                visible: middleItemStackView.currentItem.objectName == "inCallItem"

                function refreshLayout() {
                    if (mainWindow.callState === LinphoneEnums.CallState.Connected
                            || mainWindow.callState === LinphoneEnums.CallState.StreamsRunning
                            || mainWindow.callState === LinphoneEnums.CallState.Paused
                            || mainWindow.callState === LinphoneEnums.CallState.PausedByRemote) {
                        connectedCallButtons.visible = bottomButtonsLayout.visible
                        moreOptionsButton.visible = bottomButtonsLayout.visible
                        bottomButtonsLayout.layoutDirection = Qt.RightToLeft
                    } else if (mainWindow.callState === LinphoneEnums.CallState.OutgoingInit) {
                        connectedCallButtons.visible = false
                        bottomButtonsLayout.layoutDirection = Qt.LeftToRight
                        moreOptionsButton.visible = false
                    }
                }

                Connections {
                    target: mainWindow
                    function onCallStateChanged() {
                        bottomButtonsLayout.refreshLayout()
                    }
                    function onCallChanged() {
                        bottomButtonsLayout.refreshLayout()
                    }
                }
                function setButtonsEnabled(enabled) {
                    for (var i = 0; i < children.length; ++i) {
                        children[i].enabled = false
                    }
                }
                BigButton {
                    Layout.row: 0
                    icon.width: Math.round(32 * DefaultStyle.dp)
                    icon.height: Math.round(32 * DefaultStyle.dp)
                    //: "Terminer l'appel"
                    ToolTip.text: qsTr("call_action_end_call")
                    Layout.preferredWidth: Math.round(75 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                    radius: Math.round(71 * DefaultStyle.dp)
                    style: ButtonStyle.phoneRed
                    Layout.column: mainWindow.callState == LinphoneEnums.CallState.OutgoingInit
                                   || mainWindow.callState
                                   == LinphoneEnums.CallState.OutgoingProgress
                                   || mainWindow.callState
                                   == LinphoneEnums.CallState.OutgoingRinging
                                   || mainWindow.callState
                                   == LinphoneEnums.CallState.OutgoingEarlyMedia
                                   || mainWindow.callState == LinphoneEnums.CallState.IncomingReceived ? 0 : bottomButtonsLayout.columns - 1
                    onClicked: {
                        mainWindow.callTerminatedByUser = true
                        mainWindow.endCall(mainWindow.call)
                    }
                }
                RowLayout {
                    id: connectedCallButtons
                    visible: false
                    Layout.row: 0
                    Layout.column: 1
                    spacing: Math.round(10 * DefaultStyle.dp)
                    CheckableButton {
                        id: pauseButton
                        Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                        icon.width: Math.round(32 * DefaultStyle.dp)
                        icon.height: Math.round(32 * DefaultStyle.dp)
                        //: "Reprendre l'appel"
                        ToolTip.text: checked ? qsTr("call_action_resume_call")
                                                //: "Mettre l'appel en pause"
                                              : qsTr("call_action_pause_call")
                        background: Rectangle {
                            anchors.fill: parent
                            radius: Math.round(71 * DefaultStyle.dp)
                            color: parent.enabled ? parent.checked ? DefaultStyle.success_500main : parent.pressed ? DefaultStyle.main2_400 : DefaultStyle.grey_500 : DefaultStyle.grey_600
                        }
                        enabled: mainWindow.conference
                                 || mainWindow.callState != LinphoneEnums.CallState.PausedByRemote
                        icon.source: enabled
                                     && checked ? AppIcons.play : AppIcons.phonePause
                        checked: mainWindow.call
                                 && mainWindow.callState == LinphoneEnums.CallState.Paused
                                 || mainWindow.callState == LinphoneEnums.CallState.Pausing
                                 || (!mainWindow.conference
                                     && mainWindow.callState
                                     == LinphoneEnums.CallState.PausedByRemote)
                        onClicked: {
                            mainWindow.call.core.lSetPaused(
                                        !mainWindow.call.core.paused)
                        }
                    }
                    CheckableButton {
                        id: transferCallButton
                        visible: !mainWindow.conference
                        icon.source: AppIcons.transferCall
                        Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                        icon.width: Math.round(32 * DefaultStyle.dp)
                        icon.height: Math.round(32 * DefaultStyle.dp)
                        contentImageColor: DefaultStyle.grey_0
                        //: "Transférer l'appel"
                        ToolTip.text: qsTr("call_action_transfer_call")
                        onCheckedChanged: {
                            console.log("checked transfer changed", checked)
                            if (checked) {
                                rightPanel.visible = true
                                rightPanel.replace(callTransferPanel)
                            } else {
                                rightPanel.visible = false
                            }
                        }
                        Connections {
                            target: rightPanel
                            function onVisibleChanged() {
                                if (!rightPanel.visible)
                                    transferCallButton.checked = false
                            }
                        }
                    }
                    CheckableButton {
                        id: newCallButton
                        checkable: true
                        icon.source: AppIcons.newCall
                        Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                        icon.width: Math.round(32 * DefaultStyle.dp)
                        icon.height: Math.round(32 * DefaultStyle.dp)
                        //: "Initier un nouvel appel"
                        ToolTip.text: qsTr("call_action_start_new_call_hint")
                        onCheckedChanged: {
                            console.log("checked newcall changed", checked)
                            if (checked) {
                                rightPanel.visible = true
                                rightPanel.replace(newCallPanel)
                            } else {
                                rightPanel.visible = false
                            }
                        }
                        Connections {
                            target: rightPanel
                            function onVisibleChanged() {
                                if (!rightPanel.visible)
                                    newCallButton.checked = false
                            }
                        }
                    }
                    CheckableButton {
                        id: callListButton
                        Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                        checkable: true
                        icon.source: AppIcons.callList
                        icon.width: Math.round(32 * DefaultStyle.dp)
                        icon.height: Math.round(32 * DefaultStyle.dp)
                        //: "Afficher la liste d'appels"
                        ToolTip.text: qsTr("call_display_call_list_hint")
                        onCheckedChanged: {
                            if (checked) {
                                rightPanel.visible = true
                                rightPanel.replace(callListPanel)
                            } else {
                                rightPanel.visible = false
                            }
                        }
                        Connections {
                            target: rightPanel
                            function onVisibleChanged() {
                                if (!rightPanel.visible)
                                    newCallButton.checked = false
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.row: 0
                    Layout.column: mainWindow.callState == LinphoneEnums.CallState.OutgoingInit
                                   || mainWindow.callState
                                   == LinphoneEnums.CallState.OutgoingProgress
                                   || mainWindow.callState
                                   == LinphoneEnums.CallState.OutgoingRinging
                                   || mainWindow.callState
                                   == LinphoneEnums.CallState.OutgoingEarlyMedia
                                   || mainWindow.callState == LinphoneEnums.CallState.IncomingReceived ? bottomButtonsLayout.columns - 1 : 0
                    spacing: Math.round(10 * DefaultStyle.dp)
                    CheckableButton {
                        id: videoCameraButton
                        visible: SettingsCpp.videoEnabled
                        enabled: mainWindow.conferenceInfo
                                 || (mainWindow.callState === LinphoneEnums.CallState.Connected
                                     || mainWindow.callState
                                     === LinphoneEnums.CallState.StreamsRunning)
                        iconUrl: AppIcons.videoCamera
                        checkedIconUrl: AppIcons.videoCameraSlash
                        //: "Désactiver la vidéo"
                        //: "Activer la vidéo"
                        ToolTip.text: mainWindow.localVideoEnabled ? qsTr("call_deactivate_video_hint") : qsTr("call_activate_video_hint")
                        checked: !mainWindow.localVideoEnabled
                        Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                        icon.width: Math.round(32 * DefaultStyle.dp)
                        icon.height: Math.round(32 * DefaultStyle.dp)
                        onClicked: mainWindow.call.core.lSetLocalVideoEnabled(
                                       !mainWindow.call.core.localVideoEnabled)
                    }
                    CheckableButton {
                        iconUrl: AppIcons.microphone
                        ToolTip.text: mainWindow.call && mainWindow.call.core.microphoneMuted
                            //: "Activer le micro"
                            ? qsTr("call_activate_microphone")
                            //: "Désactiver le micro"
                            : qsTr("call_deactivate_microphone")
                        checkedIconUrl: AppIcons.microphoneSlash
                        checked: mainWindow.call
                                 && mainWindow.call.core.microphoneMuted
                        Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                        icon.width: Math.round(32 * DefaultStyle.dp)
                        icon.height: Math.round(32 * DefaultStyle.dp)
                        onClicked: mainWindow.call.core.lSetMicrophoneMuted(
                                       !mainWindow.call.core.microphoneMuted)
                    }
                    CheckableButton {
                        iconUrl: AppIcons.screencast
                        visible: !!mainWindow.conference
                        //: Partager l'écran…
                        ToolTip.text: qsTr("call_share_screen_hint")
                        Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                        icon.width: Math.round(32 * DefaultStyle.dp)
                        icon.height: Math.round(32 * DefaultStyle.dp)
                        onCheckedChanged: {
                            if (checked) {
                                rightPanel.visible = true
                                rightPanel.replace(screencastPanel)
                            } else {
                                rightPanel.visible = false
                            }
                        }
                    }
                    CheckableButton {
                        iconUrl: AppIcons.chatTeardropText
                        //: Open chat…
                        ToolTip.text: qsTr("call_open_chat_hint")
                        Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                        icon.width: Math.round(32 * DefaultStyle.dp)
                        icon.height: Math.round(32 * DefaultStyle.dp)
                        onCheckedChanged: {
                            if (checked) {
                                rightPanel.visible = true
                                rightPanel.replace(chatPanel)
                            } else {
                                rightPanel.visible = false
                            }
                        }
                    }
                    CheckableButton {
                        visible: false
                        checkable: false
                        iconUrl: AppIcons.handWaving
                        //: "Lever la main"
                        ToolTip.text: qsTr("call_rise_hand_hint")
                        Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                        icon.width: Math.round(32 * DefaultStyle.dp)
                        icon.height: Math.round(32 * DefaultStyle.dp)
                    }
                    CheckableButton {
                        visible: false
                        iconUrl: AppIcons.smiley
                        //: "Envoyer une réaction"
                        ToolTip.text: qsTr("call_send_reaction_hint")
                        Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                        icon.width: Math.round(32 * DefaultStyle.dp)
                        icon.height: Math.round(32 * DefaultStyle.dp)
                    }
                    CheckableButton {
                        id: participantListButton
                        //: "Gérer les participants"
                        ToolTip.text: qsTr("call_manage_participants_hint")
                        visible: mainWindow.conference
                        iconUrl: AppIcons.usersTwo
                        Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                        icon.width: Math.round(32 * DefaultStyle.dp)
                        icon.height: Math.round(32 * DefaultStyle.dp)
                        onCheckedChanged: {
                            if (checked) {
                                rightPanel.visible = true
                                rightPanel.replace(participantListPanel)
                            } else {
                                rightPanel.visible = false
                            }
                        }
                        Connections {
                            target: rightPanel
                            onVisibleChanged: if (!rightPanel.visible)
                                                  participantListButton.checked = false
                        }
                    }
                    PopupButton {
                        id: moreOptionsButton
                        //: "Plus d'options…"
                        ToolTip.text: qsTr("call_more_options_hint")
                        Layout.preferredWidth: Math.round(55 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(55 * DefaultStyle.dp)
                        popup.topPadding: Math.round(20 * DefaultStyle.dp)
                        popup.bottomPadding: Math.round(20 * DefaultStyle.dp)
                        popup.leftPadding: Math.round(10 * DefaultStyle.dp)
                        popup.rightPadding: Math.round(10 * DefaultStyle.dp)
                        style: ButtonStyle.checkable
                        icon.width: Math.round(32 * DefaultStyle.dp)
                        icon.height: Math.round(32 * DefaultStyle.dp)

                        Connections {
                            target: moreOptionsButton.popup
                            function onOpened() {
                                moreOptionsButton.popup.y = -moreOptionsButton.popup.height
                                        - moreOptionsButton.popup.padding
                            }
                        }
                        popup.contentItem: ColumnLayout {
                            id: optionsList
                            spacing: Math.round(5 * DefaultStyle.dp)

                            IconLabelButton {
                                Layout.fillWidth: true
                                visible: mainWindow.conference
                                icon.source: AppIcons.squaresFour
                                icon.width: Math.round(32 * DefaultStyle.dp)
                                icon.height: Math.round(32 * DefaultStyle.dp)
                                //: "Modifier la disposition"
                                text: qsTr("call_action_change_conference_layout")
                                style: ButtonStyle.noBackground
                                onClicked: {
                                    rightPanel.visible = true
                                    rightPanel.replace(changeLayoutPanel)
                                    moreOptionsButton.close()
                                }
                            }
                            IconLabelButton {
                                Layout.fillWidth: true
                                icon.source: AppIcons.fullscreen
                                //: "Mode Plein écran"
                                text: qsTr("call_action_full_screen")
                                icon.width: Math.round(32 * DefaultStyle.dp)
                                icon.height: Math.round(32 * DefaultStyle.dp)
                                checkable: true
                                style: ButtonStyle.noBackground
                                Binding on checked {
                                    value: mainWindow.visibility === Window.FullScreen
                                }
                                onToggled: {
                                    if (checked) {
                                        mainWindow.showFullScreen()
                                    } else {
                                        mainWindow.showNormal()
                                    }
                                    moreOptionsButton.close()
                                }
                            }
                            IconLabelButton {
                                Layout.fillWidth: true
                                icon.source: AppIcons.dialer
                                text: qsTr("call_action_show_dialer")
                                icon.width: Math.round(32 * DefaultStyle.dp)
                                icon.height: Math.round(32 * DefaultStyle.dp)
                                style: ButtonStyle.noBackground
                                onClicked: {
                                    rightPanel.visible = true
                                    rightPanel.replace(dialerPanel)
                                    moreOptionsButton.close()
                                }
                            }
                            IconLabelButton {
                                Layout.fillWidth: true
                                checkable: true
                                style: ButtonStyle.noBackground
                                icon.width: Math.round(32 * DefaultStyle.dp)
                                icon.height: Math.round(32 * DefaultStyle.dp)
                                visible: mainWindow.call
                                         && !mainWindow.conference
                                         && !SettingsCpp.disableCallRecordings
                                enabled: mainWindow.call
                                         && mainWindow.call.core.recordable
                                icon.source: AppIcons.recordFill
                                checked: mainWindow.call
                                         && mainWindow.call.core.recording
                                hoveredImageColor: contentImageColor
                                contentImageColor: mainWindow.call
                                                   && mainWindow.call.core.recording ? DefaultStyle.danger_500main : DefaultStyle.main2_500main
                                text: mainWindow.call && mainWindow.call.core.recording
                                    //: "Terminer l'enregistrement"
                                    ? qsTr("call_action_stop_recording")
                                    //: "Enregistrer l'appel"
                                    : qsTr("call_action_record")
                                textColor: mainWindow.call
                                           && mainWindow.call.core.recording ? DefaultStyle.danger_500main : DefaultStyle.main2_500main
                                hoveredTextColor: textColor
                                onToggled: {
                                    if (mainWindow.call)
                                        if (mainWindow.call.core.recording)
                                            mainWindow.call.core.lStopRecording(
                                                        )
                                        else
                                            mainWindow.call.core.lStartRecording()
                                }
                            }
                            IconLabelButton {
                                Layout.fillWidth: true
                                checkable: true
                                style: ButtonStyle.noBackground
                                icon.width: Math.round(32 * DefaultStyle.dp)
                                icon.height: Math.round(32 * DefaultStyle.dp)
                                icon.source: !mainWindow.call
                                             || mainWindow.call.core.speakerMuted ? AppIcons.speakerSlash : AppIcons.speaker
                                contentImageColor: mainWindow.call
                                                   && mainWindow.call.core.speakerMuted ? DefaultStyle.danger_500main : DefaultStyle.main2_500main
                                hoveredImageColor: contentImageColor
                                text: mainWindow.call && mainWindow.call.core.speakerMuted
                                    //: "Activer le son"
                                    ? qsTr("call_activate_speaker_hint")
                                    //: "Désactiver le son"
                                    : qsTr("call_deactivate_speaker_hint")
                                textColor: mainWindow.call
                                           && mainWindow.call.core.speakerMuted ? DefaultStyle.danger_500main : DefaultStyle.main2_500main
                                hoveredTextColor: textColor
                                onCheckedChanged: {
                                    if (mainWindow.call)
                                        mainWindow.call.core.lSetSpeakerMuted(
                                                    !mainWindow.call.core.speakerMuted)
                                }
                            }
                            IconLabelButton {
                                Layout.fillWidth: true
                                icon.source: AppIcons.settings
                                icon.width: Math.round(32 * DefaultStyle.dp)
                                icon.height: Math.round(32 * DefaultStyle.dp)
                                //: "Paramètres"
                                text: qsTr("call_action_go_to_settings")
                                style: ButtonStyle.noBackground
                                onClicked: {
                                    rightPanel.visible = true
                                    rightPanel.replace(settingsPanel)
                                    moreOptionsButton.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
