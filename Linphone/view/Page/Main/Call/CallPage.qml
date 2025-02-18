import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

AbstractMainPage {
	id: mainItem
	noItemButtonText: qsTr("Nouvel appel")
	emptyListText: qsTr("Historique d'appel vide")
	newItemIconSource: AppIcons.newCall

	property var selectedRowHistoryGui
	signal listViewUpdated()

	onVisibleChanged: if (!visible) {
		goToCallHistory()
	}

	//Group call properties
	property ConferenceInfoGui confInfoGui
	property AccountProxy  accounts: AccountProxy {
		id: accountProxy
		sourceModel: AppCpp.accounts
	}
	property AccountGui account: accountProxy.defaultAccount
	property var state: account && account.core?.registrationState || 0
	property bool isRegistered: account ? account.core?.registrationState == LinphoneEnums.RegistrationState.Ok : false
	property int selectedParticipantsCount
	signal startGroupCallRequested()
	signal createCallFromSearchBarRequested()
	signal createContactRequested(string name, string address)
	signal openNumPadRequest()
	
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
		if (selectedRowHistoryGui) rightPanelStackView.replace(contactDetailComp, Control.StackView.Immediate)
		else rightPanelStackView.replace(emptySelection, Control.StackView.Immediate)
	}
	rightPanelStackView.initialItem: emptySelection
	rightPanelStackView.width: 360 * DefaultStyle.dp

	onNoItemButtonPressed: goToNewCall()

	showDefaultItem: listStackView.currentItem && listStackView.currentItem.objectName == "historyListItem" && listStackView.currentItem.listView.count === 0 || false

	function goToNewCall() {
		if (listStackView.currentItem && listStackView.currentItem.objectName != "newCallItem") listStackView.push(newCallItem)
	}
	function goToCallHistory() {
		if (listStackView.currentItem && listStackView.currentItem.objectName != "historyListItem") listStackView.replace(historyListItem)
	}

	Dialog {
		id: deleteHistoryPopup
		width: 278 * DefaultStyle.dp
		text: qsTr("L'historique d'appel sera supprimé. Souhaitez-vous continuer ?")
	}
	Dialog {
		id: deleteForUserPopup
		width: 278 * DefaultStyle.dp
		text: qsTr("L'historique d'appel de l'utilisateur sera supprimé. Souhaitez-vous continuer ?")
	}

	leftPanelContent: Item {
		id: leftPanel
		Layout.fillWidth: true
		Layout.fillHeight: true

		Control.StackView {
			id: listStackView
			anchors.fill: parent
			anchors.leftMargin: 45 * DefaultStyle.dp
			clip: true
			initialItem: historyListItem
			focus: true
			onActiveFocusChanged: if(activeFocus){
				currentItem.forceActiveFocus()
			}
		}

		Item {
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.right: parent.right
			height: 402 * DefaultStyle.dp
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
		FocusScope{
			objectName: "historyListItem"
			property alias listView: historyListView
			ColumnLayout {
				anchors.fill: parent
				spacing: 0
				RowLayout {
					id: titleCallLayout
					spacing: 16 * DefaultStyle.dp
					Text {
						text: qsTr("Appels")
						color: DefaultStyle.main2_700
						font.pixelSize: 29 * DefaultStyle.dp
						font.weight: 800 * DefaultStyle.dp
					}
					Item {
						Layout.fillWidth: true
					}
					PopupButton {
						id: removeHistory
						width: 24 * DefaultStyle.dp
						height: 24 * DefaultStyle.dp
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
								if (listStackView.currentItem.listView) listStackView.currentItem.listView.model.removeAllEntries()
							}
						}
					}
					Button {
						id: newCallButton
						style: ButtonStyle.noBackground
						icon.source: AppIcons.newCall
						Layout.preferredWidth: 28 * DefaultStyle.dp
						Layout.preferredHeight: 28 * DefaultStyle.dp
						Layout.rightMargin: 39 * DefaultStyle.dp
						icon.width: 28 * DefaultStyle.dp
						icon.height: 28 * DefaultStyle.dp
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
					Layout.topMargin: 18 * DefaultStyle.dp
					Layout.rightMargin: 39 * DefaultStyle.dp
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
                    Layout.topMargin: 38 * DefaultStyle.dp
					Layout.fillWidth: true
					Layout.fillHeight: true
                    Control.Control {
                        id: listLayout
                        anchors.fill: parent
                        anchors.rightMargin: 39 * DefaultStyle.dp
	
                        background: Item{}
                        contentItem: ColumnLayout {
							Text {
								visible: historyListView.count === 0
								Layout.alignment: Qt.AlignHCenter
								text: qsTr("Aucun appel%1").arg(searchBar.text.length != 0 ? " correspondant" : "")
								font {
									pixelSize: 16 * DefaultStyle.dp
									weight: 800 * DefaultStyle.dp
								}
							}
							BusyIndicator {
								Layout.alignment: Qt.AlignCenter
								Layout.preferredHeight: visible ? 60 * DefaultStyle.dp : 0
								Layout.preferredWidth: 60 * DefaultStyle.dp
								indicatorHeight: 60 * DefaultStyle.dp
								indicatorWidth: 60 * DefaultStyle.dp
								visible: historyListView.loading
								indicatorColor: DefaultStyle.main1_500_main
							}
							CallHistoryListView {
								id: historyListView
								Layout.fillWidth: true
    							Layout.fillHeight: true
								searchBar: searchBar
								Connections{
									target: mainItem
									function onListViewUpdated(){
										historyListView.model.reload()
									}
								}
								onCurrentIndexChanged: {
									mainItem.selectedRowHistoryGui = model.getAt(currentIndex)
								}
								onCountChanged: {
									mainItem.selectedRowHistoryGui = model.getAt(currentIndex)
								}
							}
						}
                    }
                    ScrollBar {
                        id: scrollbar
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.rightMargin: 8 * DefaultStyle.dp
                        active: true
                        policy: Control.ScrollBar.AsNeeded
                    }
                }
			}
		}
	}

	Component {
		id: newCallItem
		FocusScope{
			objectName: "newCallItem"
			width: parent?.width
			height: parent?.height
			Control.StackView.onActivated:{
				callContactsList.forceActiveFocus()
			}
			ColumnLayout {
				anchors.fill: parent
				spacing: 0
				RowLayout {
					spacing: 10 * DefaultStyle.dp
					Button {
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
						style: ButtonStyle.noBackground
						icon.source: AppIcons.leftArrow
						focus: true
						KeyNavigation.down: listStackView
						onClicked: {
							console.debug("[CallPage]User: return to call history")
							listStackView.pop()
							listStackView.forceActiveFocus()
						}
					}
					Text {
						text: qsTr("Nouvel appel")
						color: DefaultStyle.main2_700
						font.pixelSize: 29 * DefaultStyle.dp
						font.weight: 800 * DefaultStyle.dp
					}
					Item {
						Layout.fillWidth: true
					}
				}
				NewCallForm {
					id: callContactsList
					Layout.topMargin: 18 * DefaultStyle.dp
					Layout.fillWidth: true
					Layout.fillHeight: true
					focus: true
					numPadPopup: numericPadPopupItem
					groupCallVisible: true
					searchBarColor: DefaultStyle.grey_100
					onContactClicked: (contact) => {
						mainWindow.startCallWithContact(contact, false, callContactsList)
					}
					onGroupCallCreationRequested: {
						console.log("groupe call requetsed")
						listStackView.push(groupCallItem)
					}
					Connections {
						target: mainItem
						function onCreateCallFromSearchBarRequested(){ UtilsCpp.createCall(callContactsList.searchBar.text)}
					}
				}
			}
		}
	}

	Component {
		id: groupCallItem
		FocusScope{
			objectName: "groupCallItem"
			Control.StackView.onActivated: {
				addParticipantsLayout.forceActiveFocus()
			}
			ColumnLayout {
				spacing: 0
				anchors.fill: parent
				RowLayout {
					spacing: 10 * DefaultStyle.dp
					visible: !SettingsCpp.disableMeetingsFeature
					Button {
						id: backGroupCallButton
						style: ButtonStyle.noBackgroundOrange
						icon.source: AppIcons.leftArrow
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
						KeyNavigation.down: listStackView
						KeyNavigation.right: groupCallButton
						KeyNavigation.left: groupCallButton
						onClicked: {
							listStackView.pop()
							listStackView.currentItem?.forceActiveFocus()
						}
					}
					ColumnLayout {
						spacing: 3 * DefaultStyle.dp
						Text {
							text: qsTr("Appel de groupe")
							color: DefaultStyle.main1_500_main
							maximumLineCount: 1
							font {
								pixelSize: 18 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
							}
							Layout.fillWidth: true
						}
						Text {
							text: qsTr("%1 participant%2 sélectionné").arg(mainItem.selectedParticipantsCount).arg(mainItem.selectedParticipantsCount > 1 ? "s" : "")
							color: DefaultStyle.main2_500main
							maximumLineCount: 1
							font {
								pixelSize: 12 * DefaultStyle.dp
								weight: 300 * DefaultStyle.dp
							}
							Layout.fillWidth: true
						}
					}
					SmallButton {
						id: groupCallButton
						enabled: mainItem.selectedParticipantsCount.length != 0
						Layout.rightMargin: 21 * DefaultStyle.dp
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
					Layout.topMargin: 18 * DefaultStyle.dp
					Layout.rightMargin: 38 * DefaultStyle.dp
					Text {
						font.pixelSize: 13 * DefaultStyle.dp
						font.weight: 700 * DefaultStyle.dp
						text: qsTr("Nom du groupe")
					}
					Item{Layout.fillWidth: true}
					Text {
						font.pixelSize: 12 * DefaultStyle.dp
						font.weight: 300 * DefaultStyle.dp
						text: qsTr("Requis")
					}
				}
				TextField {
					id: groupCallName
					Layout.fillWidth: true
					Layout.rightMargin: 38 * DefaultStyle.dp
					Layout.preferredHeight: 49 * DefaultStyle.dp
					focus: true
					KeyNavigation.down: addParticipantsLayout//participantList.count > 0 ? participantList : searchbar
				}
				AddParticipantsForm {
					id: addParticipantsLayout
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.topMargin: 15 * DefaultStyle.dp
					onSelectedParticipantsCountChanged: mainItem.selectedParticipantsCount = selectedParticipantsCount
					focus: true
					Connections {
						target: mainItem
						function onStartGroupCallRequested() {
							if (groupCallName.text.length === 0) {
								UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("Un nom doit être donné à l'appel de groupe"), false)
							} else if(!mainItem.isRegistered) {
								UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("Vous n'etes pas connecté"), false)
							} else {
								mainItem.confInfoGui = Qt.createQmlObject('import Linphone
																			ConferenceInfoGui{
																			}', mainItem)
								mainItem.confInfoGui.core.subject = groupCallName.text
								mainItem.confInfoGui.core.isScheduled = false
								mainItem.confInfoGui.core.addParticipants(addParticipantsLayout.selectedParticipants)
								mainItem.confInfoGui.core.save()
							}
						}
					}
				}
			}
		}
	}

	Component{
		id: emptySelection
		Item{objectName: "emptySelection"}
	}
	Component {
		id: contactDetailComp
		FocusScope{
			width: parent?.width
			height: parent?.height
			CallHistoryLayout {
				id: contactDetail
				anchors.fill: parent
				anchors.topMargin: 45 * DefaultStyle.dp
				anchors.bottomMargin: 45 * DefaultStyle.dp
				visible: mainItem.selectedRowHistoryGui != undefined
				callHistoryGui: selectedRowHistoryGui

				property var contactObj: UtilsCpp.findFriendByAddress(specificAddress)

				contact: contactObj && contactObj.value || null
				specificAddress: callHistoryGui && callHistoryGui.core.remoteAddress || ""

				buttonContent: PopupButton {
					id: detailOptions
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					popup.x: width
					popup.contentItem: FocusScope {
						implicitHeight: detailsButtons.implicitHeight
						implicitWidth: detailsButtons.implicitWidth
						Keys.onPressed: (event)=> {
							if (event.key == Qt.Key_Left || event.key == Qt.Key_Escape) {
								detailOptions.popup.close()
								event.accepted = true;
							}
						}
						ColumnLayout {
							id: detailsButtons
							anchors.fill: parent
							IconLabelButton {
								Layout.fillWidth: true
								property bool isLdap: contactDetail.contact?.core?.isLdap || false
								property bool isCardDAV: contactDetail.contact?.core?.isCardDAV || false
								text: contactDetail.contact ? qsTr("Voir le contact") : qsTr("Ajouter aux contacts")
								icon.source: AppIcons.plusCircle
								icon.width: 32 * DefaultStyle.dp
								icon.height: 32 * DefaultStyle.dp
								visible: !isLdap && !isCardDAV
								onClicked: {
									detailOptions.close()
									if (contactDetail.contact) mainWindow.displayContactPage(contactDetail.contactAddress)
									else mainItem.createContactRequested(contactDetail.contactName, contactDetail.contactAddress)
								}
							}
							IconLabelButton {
								Layout.fillWidth: true
								text: qsTr("Copier l'adresse SIP")
								icon.source: AppIcons.copy
								icon.width: 32 * DefaultStyle.dp
								icon.height: 32 * DefaultStyle.dp
								onClicked: {
									detailOptions.close()
									var success = UtilsCpp.copyToClipboard(mainItem.selectedRowHistoryGui && mainItem.selectedRowHistoryGui.core.remoteAddress)
									if (success) UtilsCpp.showInformationPopup(qsTr("Copié"), qsTr("L'adresse a été copiée dans le presse-papier"), true)
									else UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("Erreur lors de la copie de l'adresse"), false)
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
								Layout.preferredHeight: 2 * DefaultStyle.dp
								color: DefaultStyle.main2_400
							}
							
							IconLabelButton {
								Layout.fillWidth: true
								text: qsTr("Supprimer l'historique")
								icon.source: AppIcons.trashCan
								icon.width: 32 * DefaultStyle.dp
								icon.height: 32 * DefaultStyle.dp
								style: ButtonStyle.hoveredBackgroundRed
								Connections {
									target: deleteForUserPopup
									function onAccepted() {
										detailListView.model.removeEntriesWithFilter(detailListView.searchText)
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
				detailContent: RoundedPane {
					id: detailControl
					Layout.preferredWidth: 360 * DefaultStyle.dp
	
					background: Rectangle {
						id: detailListBackground
						anchors.fill: parent
						color: DefaultStyle.grey_0
						radius: 15 * DefaultStyle.dp
					}
					
					contentItem: StackLayout {
						currentIndex: detailListView.loading ? 0 : 1
						height: Math.min(430 * DefaultStyle.dp, detailListView.contentHeight)
						BusyIndicator {
							Layout.alignment: Qt.AlignCenter
							Layout.preferredHeight: visible ? 60 * DefaultStyle.dp : 0
							Layout.preferredWidth: 60 * DefaultStyle.dp
							indicatorHeight: 60 * DefaultStyle.dp
							indicatorWidth: 60 * DefaultStyle.dp
							indicatorColor: DefaultStyle.main1_500_main
						}
						CallHistoryListView {
							id: detailListView
							Layout.fillWidth: true
							Layout.preferredHeight: Math.min(detailControl.implicitHeight, contentHeight)
							spacing: 14 * DefaultStyle.dp
							clip: true
							searchText: mainItem.selectedRowHistoryGui ? mainItem.selectedRowHistoryGui.core.remoteAddress : ""
							
							delegate: Item {
								width:detailListView.width
								height: 56 * DefaultStyle.dp
								RowLayout {
									anchors.fill: parent
									anchors.leftMargin: 20 * DefaultStyle.dp
									anchors.rightMargin: 20 * DefaultStyle.dp
									anchors.verticalCenter: parent.verticalCenter
									ColumnLayout {
										Layout.alignment: Qt.AlignVCenter
										RowLayout {
											EffectImage {
												id: statusIcon
												imageSource: modelData.core.status === LinphoneEnums.CallStatus.Declined
												|| modelData.core.status === LinphoneEnums.CallStatus.DeclinedElsewhere
												|| modelData.core.status === LinphoneEnums.CallStatus.Aborted
												|| modelData.core.status === LinphoneEnums.CallStatus.EarlyAborted
													? AppIcons.arrowElbow
													: modelData.core.isOutgoing
														? AppIcons.arrowUpRight
														: AppIcons.arrowDownLeft
												colorizationColor: modelData.core.status === LinphoneEnums.CallStatus.Declined
												|| modelData.core.status === LinphoneEnums.CallStatus.DeclinedElsewhere
												|| modelData.core.status === LinphoneEnums.CallStatus.Aborted
												|| modelData.core.status === LinphoneEnums.CallStatus.EarlyAborted
												|| modelData.core.status === LinphoneEnums.CallStatus.Missed
													? DefaultStyle.danger_500main
													: modelData.core.isOutgoing
														? DefaultStyle.info_500_main
														: DefaultStyle.success_500main
												Layout.preferredWidth: 16 * DefaultStyle.dp
												Layout.preferredHeight: 16 * DefaultStyle.dp
												transform: Rotation {
													angle: modelData.core.isOutgoing && (modelData.core.status === LinphoneEnums.CallStatus.Declined
														|| modelData.core.status === LinphoneEnums.CallStatus.DeclinedElsewhere
														|| modelData.core.status === LinphoneEnums.CallStatus.Aborted
														|| modelData.core.status === LinphoneEnums.CallStatus.EarlyAborted) ? 180 : 0
													origin {
														x: statusIcon.width/2
														y: statusIcon.height/2
													}
												}
											}
											Text {
												text: modelData.core.status === LinphoneEnums.CallStatus.Missed
													? qsTr("Appel manqué")
													: modelData.core.isOutgoing
														? qsTr("Appel sortant")
														: qsTr("Appel entrant")
												font {
													pixelSize: 14 * DefaultStyle.dp
													weight: 400 * DefaultStyle.dp
												}
											}
										}
										Text {
											text: UtilsCpp.formatDate(modelData.core.date)
											color: modelData.core.status === LinphoneEnums.CallStatus.Missed? DefaultStyle.danger_500main : DefaultStyle.main2_500main
											font {
												pixelSize: 12 * DefaultStyle.dp
												weight: 300 * DefaultStyle.dp
											}
										}
									}
									Item {
										Layout.fillHeight: true
										Layout.fillWidth: true
									}
									Text {
										text: UtilsCpp.formatElapsedTime(modelData.core.duration, false)
										font {
											pixelSize: 12 * DefaultStyle.dp
											weight: 300 * DefaultStyle.dp
										}
									}
								}
							}
						}
					}
				}
				Item{
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
			Layout.preferredWidth: 24 * DefaultStyle.dp
			Layout.preferredHeight: 24 * DefaultStyle.dp
			fillMode: Image.PreserveAspectFit
			colorizationColor: iconLabel.colorizationColor
		}
		Text {
			text: iconLabel.text
			color: iconLabel.colorizationColor
			font {
				pixelSize: 14 * DefaultStyle.dp
				weight: 400 * DefaultStyle.dp
			}
		}
	}
}
