import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone
import UtilsCpp
import SettingsCpp

AbstractMainPage {
	id: mainItem
	noItemButtonText: qsTr("Nouvel appel")
	emptyListText: qsTr("Aucun appel")
	newItemIconSource: AppIcons.newCall

	property var selectedRowHistoryGui
	signal listViewUpdated()

	//Group call properties
	property ConferenceInfoGui confInfoGui
	property AccountProxy accounts: AccountProxy{id: accountProxy}
	property AccountGui account: accountProxy.defaultAccount
	property var state: account && account.core.registrationState || 0
	property bool isRegistered: account ? account.core.registrationState == LinphoneEnums.RegistrationState.Ok : false
	property int selectedParticipantsCount
	signal startGroupCallRequested()
	signal createCallFromSearchBarRequested()
	signal createContactRequested(string name, string address)

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

	showDefaultItem: listStackView.currentItem.listView && listStackView.currentItem.listView.count === 0 && listStackView.currentItem.listView.model.sourceModel.count === 0 || false

	function goToNewCall() {
		listStackView.push(newCallItem)
	}
	function goToCallHistory() {
		listStackView.pop()
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

		Loader {
			id: titleLoader
			anchors.left: parent.left
			anchors.right: parent.right
		}

		Control.StackView {
			id: listStackView
			clip: true
			initialItem: historyListItem
			anchors.top: titleLoader.bottom
			anchors.topMargin: 18 * DefaultStyle.dp
			anchors.left: parent.left
			anchors.leftMargin: 45 * DefaultStyle.dp
			anchors.right: parent.right
			anchors.bottom: parent.bottom
		}

		Item {
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.right: parent.right
			height: 402 * DefaultStyle.dp
			NumericPad {
				id: numericPad
				width: parent.width
				height: parent.height
				onLaunchCall: {
					mainItem.createCallFromSearchBarRequested()
					// TODO : auto completion instead of sip linphone
				}
			}
		}
	}

	Component {
		id: historyListTitle
		RowLayout {
			spacing: 16 * DefaultStyle.dp
			Text {
				text: qsTr("Appels")
				Layout.leftMargin: 45 * DefaultStyle.dp
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
				popup.x: 0
				popup.padding: 10 * DefaultStyle.dp
				popup.contentItem: Button {
					background: Item{}
					contentItem: RowLayout {
						EffectImage {
							imageSource: AppIcons.trashCan
							width: 24 * DefaultStyle.dp
							height: 24 * DefaultStyle.dp
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							fillMode: Image.PreserveAspectFit
							colorizationColor: DefaultStyle.danger_500main
						}
						Text {
							text: qsTr("Supprimer l’historique")
							color: DefaultStyle.danger_500main
							font {
								pixelSize: 14 * DefaultStyle.dp
								weight: 400 * DefaultStyle.dp
							}
						}
					}
					onClicked: {
						removeHistory.close()
						deleteHistoryPopup.open()
					}
				}
			}
			Button {
				background: Item {}
				icon.source: AppIcons.newCall
				Layout.preferredWidth: 28 * DefaultStyle.dp
				Layout.preferredHeight: 28 * DefaultStyle.dp
				Layout.rightMargin: 39 * DefaultStyle.dp
				icon.width: 28 * DefaultStyle.dp
				icon.height: 28 * DefaultStyle.dp
				onClicked: {
					console.debug("[CallPage]User: create new call")
					listStackView.push(newCallItem)
				}
			}
		}
	}
	Component {
		id: historyListItem
		ColumnLayout {
			Control.StackView.onActivated: titleLoader.sourceComponent = historyListTitle
			property alias listView: historyListView
			SearchBar {
				id: searchBar
				Layout.fillWidth: true
				Layout.rightMargin: 39 * DefaultStyle.dp
				placeholderText: qsTr("Rechercher un appel")
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
					ColumnLayout {
						anchors.fill: parent
						ColumnLayout {
							Text {
								text: qsTr("Aucun appel")
								font {
									pixelSize: 16 * DefaultStyle.dp
									weight: 800 * DefaultStyle.dp
								}
								visible: historyListView.count === 0
								Layout.alignment: Qt.AlignHCenter
								Binding on text {
									when: searchBar.text.length !== 0
									value: qsTr("Aucun appel correspondant")
									restoreMode: Binding.RestoreBindingOrValue
								}
							}
							ListView {
								id: historyListView
								clip: true
								Layout.fillWidth: true
								Layout.fillHeight: true
								model: CallHistoryProxy {
									filterText: searchBar.text
								}
								
								currentIndex: -1
								flickDeceleration: 10000
								spacing: 10 * DefaultStyle.dp

								Connections {
									target: deleteHistoryPopup
									function onAccepted() {
										historyListView.model.removeAllEntries()
									}
								}

								delegate: Item {
									width:historyListView.width
									height: 56 * DefaultStyle.dp
									anchors.topMargin: 5 * DefaultStyle.dp
									anchors.bottomMargin: 5 * DefaultStyle.dp
									RowLayout {
										z: 1
										anchors.fill: parent
										Item {
											Layout.preferredWidth: historyAvatar.width
											Layout.preferredHeight: historyAvatar.height
											Layout.leftMargin: 5 * DefaultStyle.dp
											MultiEffect {
												source: historyAvatar
												anchors.fill: historyAvatar
												shadowEnabled: true
												shadowBlur: 1
												shadowColor: DefaultStyle.grey_900
												shadowOpacity: 0.1
											}
											Avatar {
												id: historyAvatar
												address: modelData.core.remoteAddress
												width: 45 * DefaultStyle.dp
												height: 45 * DefaultStyle.dp
											}
										}
										ColumnLayout {
											Layout.fillHeight: true
											Layout.fillWidth: true
											spacing: 5 * DefaultStyle.dp
											Text {
												id: friendAddress
												Layout.fillWidth: true
												maximumLineCount: 1
												text: modelData.core.displayName
												font {
													pixelSize: 14 * DefaultStyle.dp
													weight: 400 * DefaultStyle.dp
												}
											}
											RowLayout {
												spacing: 3 * DefaultStyle.dp
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
													Layout.preferredWidth: 12 * DefaultStyle.dp
													Layout.preferredHeight: 12 * DefaultStyle.dp
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
													// text: modelData.core.date
													text: UtilsCpp.formatDateElapsedTime(modelData.core.date)
													font {
														pixelSize: 12 * DefaultStyle.dp
														weight: 300 * DefaultStyle.dp
													}
												}
											}
										}
										Button {
											Layout.rightMargin: 5 * DefaultStyle.dp
											padding: 0
											background: Item {
												visible: false
											}
											icon.source: AppIcons.phone
											Layout.preferredWidth: 24 * DefaultStyle.dp
											Layout.preferredHeight: 24 * DefaultStyle.dp
											icon.width: 24 * DefaultStyle.dp
											icon.height: 24 * DefaultStyle.dp
											onClicked: {
												if (modelData.core.isConference) {
													var callsWindow = UtilsCpp.getCallsWindow()
													callsWindow.setupConference(modelData.core.conferenceInfo)
													callsWindow.show()
												}
												else {
													UtilsCpp.createCall(modelData.core.remoteAddress)
												}
											}
										}
									}
									MouseArea {
										hoverEnabled: true
										anchors.fill: parent
										Rectangle {
											anchors.fill: parent
											opacity: 0.1
											color: DefaultStyle.main2_500main
											visible: parent.containsMouse
										}
										Rectangle {
											anchors.fill: parent
											visible: historyListView.currentIndex === model.index
											color: DefaultStyle.main2_100
										}
										onPressed: {
											historyListView.currentIndex = model.index
										}
									}
								}
								onCurrentIndexChanged: {
									positionViewAtIndex(currentIndex, ListView.Visible)
									mainItem.selectedRowHistoryGui = model.getAt(currentIndex)
								}
								onCountChanged: mainItem.selectedRowHistoryGui = model.getAt(currentIndex)
								onVisibleChanged: {
									if (!visible) currentIndex = -1
								}

								Connections {
									target: mainItem
									function onListViewUpdated() {
										historyListView.model.updateView()
									}
								}
								Control.ScrollBar.vertical: scrollbar
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

	Component {
		id: newCallTitle
		RowLayout {
			Button {
				Layout.leftMargin: 45 * DefaultStyle.dp
				background: Item {
				}
				Layout.preferredWidth: 24 * DefaultStyle.dp
				Layout.preferredHeight: 24 * DefaultStyle.dp
				icon.source: AppIcons.leftArrow
				icon.width: 24 * DefaultStyle.dp
				icon.height: 24 * DefaultStyle.dp
				onClicked: {
					console.debug("[CallPage]User: return to call history")
					listStackView.pop()
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
	}
	Component {
		id: newCallItem
		ColumnLayout {
			Control.StackView.onActivated: titleLoader.sourceComponent = newCallTitle
			CallContactsLists {
				id: callContactsList
				Layout.fillWidth: true
				Layout.fillHeight: true
				numPad: numericPad
				groupCallVisible: true
				searchBarColor: DefaultStyle.grey_100
				onSelectedContactChanged: mainWindow.startCallWithContact(selectedContact, false, callContactsList)
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

	Component {
		id: groupCallTitle
		RowLayout {
			spacing: 10 * DefaultStyle.dp
			visible: !SettingsCpp.disableMeetingsFeature
			Button {
				background: Item{}
				icon.source: AppIcons.leftArrow
				contentImageColor: DefaultStyle.main1_500_main
				Layout.leftMargin: 21 * DefaultStyle.dp
				Layout.preferredWidth: 24 * DefaultStyle.dp
				Layout.preferredHeight: 24 * DefaultStyle.dp
				icon.width: 24 * DefaultStyle.dp
				icon.height: 24 * DefaultStyle.dp
				onClicked: listStackView.pop()
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
			Button {
				enabled: mainItem.selectedParticipantsCount.length != 0
				Layout.rightMargin: 21 * DefaultStyle.dp
				topPadding: 6 * DefaultStyle.dp
				bottomPadding: 6 * DefaultStyle.dp
				leftPadding: 12 * DefaultStyle.dp
				rightPadding: 12 * DefaultStyle.dp
				text: qsTr("Lancer")
				textSize: 13 * DefaultStyle.dp
				onClicked: {
					mainItem.startGroupCallRequested()
				}
			}
		}
	}

	Component {
		id: groupCallItem
		// RowLayout {
			AddParticipantsLayout {
			Control.StackView.onActivated: titleLoader.sourceComponent = groupCallTitle
				id: addParticipantsLayout
				onSelectedParticipantsCountChanged: mainItem.selectedParticipantsCount = selectedParticipantsCount
				nameGroupCall: true
				Connections {
					target: mainItem
					function onStartGroupCallRequested() {
						if (groupName.length === 0) {
							UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("Un nom doit être donné à l'appel de groupe"), false)
						} else if(!mainItem.isRegistered) {
							UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("Vous n'etes pas connecté"), false)
						} else {
							mainItem.confInfoGui = Qt.createQmlObject('import Linphone
																		ConferenceInfoGui{
																		}', mainItem)
							mainItem.confInfoGui.core.subject = addParticipantsLayout.groupName
							mainItem.confInfoGui.core.isScheduled = false
							mainItem.confInfoGui.core.addParticipants(addParticipantsLayout.selectedParticipants)
							mainItem.confInfoGui.core.save()
						}
					}
				}
			}
		// }
	}

	Component{
		id: emptySelection
		Item{}
	}
	Component {
		id: contactDetailComp
		ContactLayout {
			id: contactDetail
			visible: mainItem.selectedRowHistoryGui != undefined
			property var contactObj: UtilsCpp.findFriendByAddress(contactAddress)
			contact: contactObj && contactObj.value || null
			conferenceInfo: mainItem.selectedRowHistoryGui && mainItem.selectedRowHistoryGui.core.conferenceInfo || null
			contactAddress: mainItem.selectedRowHistoryGui && mainItem.selectedRowHistoryGui.core.remoteAddress || ""
			contactName: mainItem.selectedRowHistoryGui ? mainItem.selectedRowHistoryGui.core.displayName : ""
			anchors.top: rightPanelStackView.top
			anchors.bottom: rightPanelStackView.bottom
			anchors.topMargin: 45 * DefaultStyle.dp
			anchors.bottomMargin: 45 * DefaultStyle.dp
			buttonContent: PopupButton {
				id: detailOptions
				anchors.right: parent.right
				anchors.rightMargin: 30 * DefaultStyle.dp
				anchors.verticalCenter: parent.verticalCenter
				popup.x: width
				property var friendGuiObj: UtilsCpp.findFriendByAddress(contactDetail.contactAddress)
				property var friendGui: friendGuiObj ? friendGuiObj.value : null
				popup.contentItem: ColumnLayout {
					Button {
						background: Item {}
						contentItem: IconLabel {
							text: detailOptions.friendGui ? qsTr("Voir le contact") : qsTr("Ajouter aux contacts")
							iconSource: AppIcons.plusCircle
						}
						onClicked: {
							detailOptions.close()
							if (detailOptions.friendGui) mainWindow.displayContactPage(contactDetail.contactAddress)
							else mainItem.createContactRequested(contactDetail.contactName, contactDetail.contactAddress)
						}
					}
					Button {
						background: Item {}
						contentItem: IconLabel {
							text: qsTr("Copier l'adresse SIP")
							iconSource: AppIcons.copy
						}
						onClicked: {
							detailOptions.close()
							var success = UtilsCpp.copyToClipboard(mainItem.selectedRowHistoryGui && mainItem.selectedRowHistoryGui.core.remoteAddress)
							if (success) UtilsCpp.showInformationPopup(qsTr("Copié"), qsTr("L'adresse a été copiée dans le presse-papier"), true)
							else UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("Erreur lors de la copie de l'adresse"), false)
						}
					}
					// Button {
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
					Button {
						background: Item {}
						contentItem: IconLabel {
							text: qsTr("Supprimer l'historique")
							iconSource: AppIcons.trashCan
							colorizationColor: DefaultStyle.danger_500main
						}
						Connections {
							target: deleteForUserPopup
							function onAccepted() {
								detailListView.model.removeEntriesWithFilter()
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
			detailContent: RoundedBackgroundControl {
				id: detailControl
				Layout.preferredWidth: 360 * DefaultStyle.dp
				implicitHeight: 430 * DefaultStyle.dp + topPadding + bottomPadding

				background: Rectangle {
					id: detailListBackground
					width: parent.width
					height: detailListView.height
					color: DefaultStyle.grey_0
					radius: 15 * DefaultStyle.dp
				}

				ListView {
					id: detailListView
					width: parent.width
					height: Math.min(detailControl.implicitHeight, contentHeight)

					
					spacing: 20 * DefaultStyle.dp
					clip: true

					model: CallHistoryProxy {
						filterText: mainItem.selectedRowHistoryGui ? mainItem.selectedRowHistoryGui.core.remoteAddress : ""
					}

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
			Item{
				Layout.fillHeight: true
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
