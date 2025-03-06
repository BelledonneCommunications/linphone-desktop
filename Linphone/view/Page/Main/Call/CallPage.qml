import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

AbstractMainPage {
    id: mainItem
    noItemButtonText: qsTr("Nouvel appel")
    emptyListText: qsTr("Historique d'appel vide")
    newItemIconSource: AppIcons.newCall

    property var selectedRowHistoryGui
    signal listViewUpdated

    onVisibleChanged: if (!visible) {
                          goToCallHistory()
                      }

    //Group call properties
    property ConferenceInfoGui confInfoGui
    property AccountProxy accounts: AccountProxy {
        id: accountProxy
        sourceModel: AppCpp.accounts
    }
    property AccountGui account: accountProxy.defaultAccount
    property var state: account && account.core?.registrationState || 0
    property bool isRegistered: account ? account.core?.registrationState
                                          == LinphoneEnums.RegistrationState.Ok : false
    property int selectedParticipantsCount
    signal startGroupCallRequested
    signal createCallFromSearchBarRequested
    signal createContactRequested(string name, string address)
    signal openNumPadRequest

    property alias numericPadPopup: numericPadPopupItem

    Connections {
        enabled: confInfoGui
        target: confInfoGui ? confInfoGui.core : null
        function onConferenceSchedulerStateChanged() {
            if (confInfoGui.core.schedulerState === LinphoneEnums.ConferenceSchedulerState.Ready) {
                listStackView.pop()
            }
        }
    }

    onSelectedRowHistoryGuiChanged: {
        if (selectedRowHistoryGui)
            rightPanelStackView.replace(contactDetailComp,
                                        Control.StackView.Immediate)
        else
            rightPanelStackView.replace(emptySelection,
                                        Control.StackView.Immediate)
    }
    rightPanelStackView.initialItem: emptySelection
    rightPanelStackView.width: Math.round(360 * DefaultStyle.dp)

    onNoItemButtonPressed: goToNewCall()

    showDefaultItem: listStackView.currentItem
                     && listStackView.currentItem.objectName == "historyListItem"
                     && listStackView.currentItem.listView.count === 0 || false

    function goToNewCall() {
        if (listStackView.currentItem
                && listStackView.currentItem.objectName != "newCallItem")
            listStackView.push(newCallItem)
    }
    function goToCallHistory() {
        if (listStackView.currentItem
                && listStackView.currentItem.objectName != "historyListItem")
            listStackView.replace(historyListItem)
    }

    Dialog {
        id: deleteHistoryPopup
        width: Math.round(278 * DefaultStyle.dp)
        text: qsTr("L'historique d'appel sera supprimé. Souhaitez-vous continuer ?")
    }
    Dialog {
        id: deleteForUserPopup
        width: Math.round(278 * DefaultStyle.dp)
        text: qsTr(
                  "L'historique d'appel de l'utilisateur sera supprimé. Souhaitez-vous continuer ?")
    }

    leftPanelContent: Item {
        id: leftPanel
        Layout.fillWidth: true
        Layout.fillHeight: true

        Control.StackView {
            id: listStackView
            anchors.fill: parent
            anchors.leftMargin: Math.round(45 * DefaultStyle.dp)
            clip: true
            initialItem: historyListItem
            focus: true
            onActiveFocusChanged: if (activeFocus) {
                                      currentItem.forceActiveFocus()
                                  }
        }

        Item {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: Math.round(402 * DefaultStyle.dp)
            NumericPadPopup {
                id: numericPadPopupItem
                width: parent.width
                height: parent.height
                visible: false
                onLaunchCall: {
                    mainItem.createCallFromSearchBarRequested()
                    // TODO : auto completion instead of sip linphone
                }
            }
        }
    }

    Component {
        id: historyListItem
        FocusScope {
            objectName: "historyListItem"
            property alias listView: historyListView
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                RowLayout {
                    id: titleCallLayout
                    spacing: Math.round(16 * DefaultStyle.dp)
                    Text {
                        text: qsTr("Appels")
                        color: DefaultStyle.main2_700
                        font.pixelSize: Typography.h2.pixelSize
                        font.weight: Typography.h2.weight
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    PopupButton {
                        id: removeHistory
                        width: Math.round(24 * DefaultStyle.dp)
                        height: Math.round(24 * DefaultStyle.dp)
                        focus: true
                        popup.x: 0
                        KeyNavigation.right: newCallButton
                        KeyNavigation.down: listStackView
                        popup.contentItem: ColumnLayout {
                            IconLabelButton {
                                Layout.fillWidth: true
                                focus: visible
                                text: qsTr("Supprimer l'historique")
                                icon.source: AppIcons.trashCan
                                style: ButtonStyle.hoveredBackgroundRed
                                onClicked: {
                                    removeHistory.close()
                                    deleteHistoryPopup.open()
                                }
                            }
                        }
                        Connections {
                            target: deleteHistoryPopup
                            onAccepted: {
                                if (listStackView.currentItem.listView)
                                    listStackView.currentItem.listView.model.removeAllEntries()
                            }
                        }
                    }
                    Button {
                        id: newCallButton
                        style: ButtonStyle.noBackground
                        icon.source: AppIcons.newCall
                        Layout.preferredWidth: Math.round(28 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(28 * DefaultStyle.dp)
                        Layout.rightMargin: Math.round(39 * DefaultStyle.dp)
                        icon.width: Math.round(28 * DefaultStyle.dp)
                        icon.height: Math.round(28 * DefaultStyle.dp)
                        KeyNavigation.left: removeHistory
                        KeyNavigation.down: listStackView
                        onClicked: {
                            console.debug("[CallPage]User: create new call")
                            listStackView.push(newCallItem)
                        }
                    }
                }
                SearchBar {
                    id: searchBar
                    Layout.fillWidth: true
                    Layout.topMargin: Math.round(18 * DefaultStyle.dp)
                    Layout.rightMargin: Math.round(39 * DefaultStyle.dp)
                    placeholderText: qsTr("Rechercher un appel")
                    visible: historyListView.count !== 0 || text.length !== 0
                    focus: true
                    KeyNavigation.up: newCallButton
                    KeyNavigation.down: historyListView
                    Binding {
                        target: mainItem
                        property: "showDefaultItem"
                        when: searchBar.text.length != 0
                        value: false
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Control.Control {
                        id: listLayout
                        anchors.fill: parent
                        anchors.rightMargin: Math.round(39 * DefaultStyle.dp)
                        padding: 0
                        background: Item {}
                        contentItem: ColumnLayout {
                            Text {
                                visible: historyListView.count === 0
                                Layout.alignment: Qt.AlignHCenter
                                Layout.topMargin: Math.round(137 * DefaultStyle.dp)
                                text: qsTr("Aucun appel%1").arg(
                                          searchBar.text.length != 0 ? " correspondant" : "")
                                font {
                                    pixelSize: Typography.h4.pixelSize
                                    weight: Typography.h4.weight
                                }
                            }
                            CallHistoryListView {
                                id: historyListView
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.topMargin: Math.round(38 * DefaultStyle.dp)
                                searchBar: searchBar
                                Control.ScrollBar.vertical: scrollbar

                                Connections {
                                    target: mainItem
                                    function onListViewUpdated() {
                                        historyListView.model.reload()
                                    }
                                }
                                onCurrentIndexChanged: {
                                    mainItem.selectedRowHistoryGui = model.getAt(
                                                currentIndex)
                                }
                                onCountChanged: {
                                    mainItem.selectedRowHistoryGui = model.getAt(
                                                currentIndex)
                                }
                            }
                        }
                    }
                    ScrollBar {
                        id: scrollbar
                        visible: historyListView.contentHeight > parent.height
                        active: visible
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.rightMargin: Math.round(8 * DefaultStyle.dp)
                        policy: Control.ScrollBar.AsNeeded
                    }
                }
            }
        }
    }

    Component {
        id: newCallItem
        FocusScope {
            objectName: "newCallItem"
            width: parent?.width
            height: parent?.height
            Control.StackView.onActivated: {
                callContactsList.forceActiveFocus()
            }
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                RowLayout {
                    spacing: Math.round(10 * DefaultStyle.dp)
                    Button {
                        Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                        style: ButtonStyle.noBackground
                        icon.source: AppIcons.leftArrow
                        focus: true
                        KeyNavigation.down: listStackView
                        onClicked: {
                            console.debug(
                                        "[CallPage]User: return to call history")
                            listStackView.pop()
                            listStackView.forceActiveFocus()
                        }
                    }
                    Text {
                        text: qsTr("Nouvel appel")
                        color: DefaultStyle.main2_700
                        font.pixelSize: Typography.h2.pixelSize
                        font.weight: Typography.h2.weight
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                }
                NewCallForm {
                    id: callContactsList
                    Layout.topMargin: Math.round(18 * DefaultStyle.dp)
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    focus: true
                    numPadPopup: numericPadPopupItem
                    groupCallVisible: true
                    searchBarColor: DefaultStyle.grey_100
                    onContactClicked: contact => {
                                          mainWindow.startCallWithContact(
                                              contact, false, callContactsList)
                                      }
                    onGroupCallCreationRequested: {
                        console.log("groupe call requetsed")
                        listStackView.push(groupCallItem)
                    }
                    Connections {
                        target: mainItem
                        function onCreateCallFromSearchBarRequested() {
                            UtilsCpp.createCall(callContactsList.searchBar.text)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: groupCallItem
        FocusScope {
            objectName: "groupCallItem"
            Control.StackView.onActivated: {
                addParticipantsLayout.forceActiveFocus()
            }
            ColumnLayout {
                spacing: 0
                anchors.fill: parent
                RowLayout {
                    spacing: Math.round(10 * DefaultStyle.dp)
                    visible: !SettingsCpp.disableMeetingsFeature
                    Button {
                        id: backGroupCallButton
                        style: ButtonStyle.noBackgroundOrange
                        icon.source: AppIcons.leftArrow
                        Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                        KeyNavigation.down: listStackView
                        KeyNavigation.right: groupCallButton
                        KeyNavigation.left: groupCallButton
                        onClicked: {
                            listStackView.pop()
                            listStackView.currentItem?.forceActiveFocus()
                        }
                    }
                    ColumnLayout {
                        spacing: Math.round(3 * DefaultStyle.dp)
                        Text {
                            text: qsTr("Appel de groupe")
                            color: DefaultStyle.main1_500_main
                            maximumLineCount: 1
                            font {
                                pixelSize: Math.round(18 * DefaultStyle.dp)
                                weight: Typography.h4.weight
                            }
                            Layout.fillWidth: true
                        }
                        Text {
                            text: qsTr("%1 participant%2 sélectionné").arg(
                                      mainItem.selectedParticipantsCount).arg(
                                      mainItem.selectedParticipantsCount > 1 ? "s" : "")
                            color: DefaultStyle.main2_500main
                            maximumLineCount: 1
                            font {
                                pixelSize: Math.round(12 * DefaultStyle.dp)
                                weight: Math.round(300 * DefaultStyle.dp)
                            }
                            Layout.fillWidth: true
                        }
                    }
                    SmallButton {
                        id: groupCallButton
                        enabled: mainItem.selectedParticipantsCount.length != 0
                        Layout.rightMargin: Math.round(21 * DefaultStyle.dp)
                        text: qsTr("Lancer")
                        style: ButtonStyle.main
                        KeyNavigation.down: listStackView
                        KeyNavigation.left: backGroupCallButton
                        KeyNavigation.right: backGroupCallButton
                        onClicked: {
                            mainItem.startGroupCallRequested()
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
                        text: qsTr("Nom du groupe")
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Text {
                        font.pixelSize: Math.round(12 * DefaultStyle.dp)
                        font.weight: Math.round(300 * DefaultStyle.dp)
                        text: qsTr("Requis")
                    }
                }
                TextField {
                    id: groupCallName
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
                    onSelectedParticipantsCountChanged: mainItem.selectedParticipantsCount
                                                        = selectedParticipantsCount
                    focus: true
                    Connections {
                        target: mainItem
                        function onStartGroupCallRequested() {
                            if (groupCallName.text.length === 0) {
                                UtilsCpp.showInformationPopup(
                                            qsTr("Erreur"), qsTr(
                                                "Un nom doit être donné à l'appel de groupe"),
                                            false)
                            } else if (!mainItem.isRegistered) {
                                UtilsCpp.showInformationPopup(
                                            qsTr("Erreur"),
                                            qsTr("Vous n'etes pas connecté"),
                                            false)
                            } else {
                                mainItem.confInfoGui = Qt.createQmlObject(
                                            'import Linphone
ConferenceInfoGui{
}', mainItem)
                                mainItem.confInfoGui.core.subject = groupCallName.text
                                mainItem.confInfoGui.core.isScheduled = false
                                mainItem.confInfoGui.core.addParticipants(
                                            addParticipantsLayout.selectedParticipants)
                                mainItem.confInfoGui.core.save()
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: emptySelection
        Item {
            objectName: "emptySelection"
        }
    }
    Component {
        id: contactDetailComp
        FocusScope {
            //            width: parent?.width
            //            height: parent?.height
            CallHistoryLayout {
                id: contactDetail
                anchors.fill: parent
                anchors.topMargin: Math.round(45 * DefaultStyle.dp)
                anchors.bottomMargin: Math.round(45 * DefaultStyle.dp)
                visible: mainItem.selectedRowHistoryGui != undefined
                callHistoryGui: selectedRowHistoryGui

                property var contactObj: UtilsCpp.findFriendByAddress(
                                             specificAddress)

                contact: contactObj && contactObj.value || null
                specificAddress: callHistoryGui
                                 && callHistoryGui.core.remoteAddress || ""

                buttonContent: PopupButton {
                    id: detailOptions
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    popup.x: width
                    popup.contentItem: FocusScope {
                        implicitHeight: detailsButtons.implicitHeight
                        implicitWidth: detailsButtons.implicitWidth
                        Keys.onPressed: event => {
                                            if (event.key == Qt.Key_Left
                                                || event.key == Qt.Key_Escape) {
                                                detailOptions.popup.close()
                                                event.accepted = true
                                            }
                                        }
                        ColumnLayout {
                            id: detailsButtons
                            anchors.fill: parent
                            IconLabelButton {
                                Layout.fillWidth: true
                                property bool isLdap: contactDetail.contact?.core?.isLdap
                                                      || false
                                property bool isCardDAV: contactDetail.contact?.core?.isCardDAV
                                                         || false
                                text: contactDetail.contact ? qsTr("Voir le contact") : qsTr(
                                                                  "Ajouter aux contacts")
                                icon.source: AppIcons.plusCircle
                                icon.width: Math.round(32 * DefaultStyle.dp)
                                icon.height: Math.round(32 * DefaultStyle.dp)
                                visible: !isLdap && !isCardDAV
                                onClicked: {
                                    detailOptions.close()
                                    if (contactDetail.contact)
                                        mainWindow.displayContactPage(
                                                    contactDetail.contactAddress)
                                    else
                                        mainItem.createContactRequested(
                                                    contactDetail.contactName,
                                                    contactDetail.contactAddress)
                                }
                            }
                            IconLabelButton {
                                Layout.fillWidth: true
                                text: qsTr("Copier l'adresse SIP")
                                icon.source: AppIcons.copy
                                icon.width: Math.round(32 * DefaultStyle.dp)
                                icon.height: Math.round(32 * DefaultStyle.dp)
                                onClicked: {
                                    detailOptions.close()
                                    var success = UtilsCpp.copyToClipboard(
                                                mainItem.selectedRowHistoryGui
                                                && mainItem.selectedRowHistoryGui.core.remoteAddress)
                                    if (success)
                                        UtilsCpp.showInformationPopup(
                                                    qsTr("Copié"), qsTr(
                                                        "L'adresse a été copiée dans le presse-papier"),
                                                    true)
                                    else
                                        UtilsCpp.showInformationPopup(
                                                    qsTr("Erreur"), qsTr(
                                                        "Erreur lors de la copie de l'adresse"),
                                                    false)
                                }
                            }
                            // IconLabelButton {
                            // 	background: Item {}
                            // 	enabled: false
                            // 	contentItem: IconLabel {
                            // 		text: qsTr("Bloquer")
                            // 		iconSource: AppIcons.empty
                            // 	}
                            // 	onClicked: console.debug("[CallPage.qml] TODO : block user")
                            // }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Math.round(2 * DefaultStyle.dp)
                                color: DefaultStyle.main2_400
                            }

                            IconLabelButton {
                                Layout.fillWidth: true
                                text: qsTr("Supprimer l'historique")
                                icon.source: AppIcons.trashCan
                                icon.width: Math.round(32 * DefaultStyle.dp)
                                icon.height: Math.round(32 * DefaultStyle.dp)
                                style: ButtonStyle.hoveredBackgroundRed
                                Connections {
                                    target: deleteForUserPopup
                                    function onAccepted() {
                                        detailListView.model.removeEntriesWithFilter(
                                                    detailListView.searchText)
                                        mainItem.listViewUpdated()
                                    }
                                }
                                onClicked: {
                                    detailOptions.close()
                                    deleteForUserPopup.open()
                                }
                            }
                        }
                    }
                }
                detailContent: Item {
                    Layout.preferredWidth: Math.round(360 * DefaultStyle.dp)
                    Layout.fillHeight: true
                    RoundedPane {
                        id: detailControl
                        width: parent.width
                        height: Math.min(
                                    parent.height,
                                    detailListView.contentHeight) + topPadding + bottomPadding
                        background: Rectangle {
                            id: detailListBackground
                            anchors.fill: parent
                            color: DefaultStyle.grey_0
                            radius: Math.round(15 * DefaultStyle.dp)
                        }

                        contentItem: CallHistoryListView {
                            id: detailListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: Math.round(14 * DefaultStyle.dp)
                            clip: true
                            searchText: mainItem.selectedRowHistoryGui ? mainItem.selectedRowHistoryGui.core.remoteAddress : ""
                            busyIndicatorSize: Math.round(40 * DefaultStyle.dp)

                            delegate: Item {
                                width: detailListView.width
                                height: Math.round(56 * DefaultStyle.dp)
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: Math.round(20 * DefaultStyle.dp)
                                    anchors.rightMargin: Math.round(20 * DefaultStyle.dp)
                                    anchors.verticalCenter: parent.verticalCenter
                                    ColumnLayout {
                                        Layout.alignment: Qt.AlignVCenter
                                        RowLayout {
                                            EffectImage {
                                                id: statusIcon
                                                imageSource: modelData.core.status
                                                             === LinphoneEnums.CallStatus.Declined
                                                             || modelData.core.status === LinphoneEnums.CallStatus.DeclinedElsewhere || modelData.core.status === LinphoneEnums.CallStatus.Aborted || modelData.core.status === LinphoneEnums.CallStatus.EarlyAborted ? AppIcons.arrowElbow : modelData.core.isOutgoing ? AppIcons.arrowUpRight : AppIcons.arrowDownLeft
                                                colorizationColor: modelData.core.status === LinphoneEnums.CallStatus.Declined || modelData.core.status === LinphoneEnums.CallStatus.DeclinedElsewhere || modelData.core.status === LinphoneEnums.CallStatus.Aborted || modelData.core.status === LinphoneEnums.CallStatus.EarlyAborted || modelData.core.status === LinphoneEnums.CallStatus.Missed ? DefaultStyle.danger_500main : modelData.core.isOutgoing ? DefaultStyle.info_500_main : DefaultStyle.success_500main
                                                Layout.preferredWidth: Math.round(16 * DefaultStyle.dp)
                                                Layout.preferredHeight: Math.round(16 * DefaultStyle.dp)
                                                transform: Rotation {
                                                    angle: modelData.core.isOutgoing
                                                           && (modelData.core.status === LinphoneEnums.CallStatus.Declined || modelData.core.status === LinphoneEnums.CallStatus.DeclinedElsewhere || modelData.core.status === LinphoneEnums.CallStatus.Aborted || modelData.core.status === LinphoneEnums.CallStatus.EarlyAborted) ? 180 : 0
                                                    origin {
                                                        x: statusIcon.width / 2
                                                        y: statusIcon.height / 2
                                                    }
                                                }
                                            }
                                            Text {
                                                text: modelData.core.status === LinphoneEnums.CallStatus.Missed ? qsTr("Appel manqué") : modelData.core.isOutgoing ? qsTr("Appel sortant") : qsTr("Appel entrant")
                                                font {
                                                    pixelSize: Typography.p1.pixelSize
                                                    weight: Typography.p1.weight
                                                }
                                            }
                                        }
                                        Text {
                                            text: UtilsCpp.formatDate(
                                                      modelData.core.date)
                                            color: modelData.core.status === LinphoneEnums.CallStatus.Missed ? DefaultStyle.danger_500main : DefaultStyle.main2_500main
                                            font {
                                                pixelSize: Math.round(12 * DefaultStyle.dp)
                                                weight: Math.round(300 * DefaultStyle.dp)
                                            }
                                        }
                                    }
                                    Item {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: UtilsCpp.formatElapsedTime(
                                                  modelData.core.duration,
                                                  false)
                                        font {
                                            pixelSize: Math.round(12 * DefaultStyle.dp)
                                            weight: Math.round(300 * DefaultStyle.dp)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }

    component IconLabel: RowLayout {
        id: iconLabel
        property string text
        property string iconSource
        property color colorizationColor: DefaultStyle.main2_500main
        EffectImage {
            imageSource: iconLabel.iconSource
            Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
            fillMode: Image.PreserveAspectFit
            colorizationColor: iconLabel.colorizationColor
        }
        Text {
            text: iconLabel.text
            color: iconLabel.colorizationColor
            font {
                pixelSize: Typography.p1.pixelSize
                weight: Typography.p1.weight
            }
        }
    }
}
