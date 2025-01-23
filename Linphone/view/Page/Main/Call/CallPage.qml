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
		Loader {
			id: titleLoader
			anchors.left: parent.left
			anchors.leftMargin: 45 * DefaultStyle.dp
			anchors.right: parent.right
			asynchronous: false
			onActiveFocusChanged:{
				if(activeFocus && item){
					item.forceActiveFocus()
				}
			}
		}

		Control.StackView {
			id: listStackView
			anchors.top: titleLoader.bottom
			anchors.topMargin: 18 * DefaultStyle.dp
			anchors.left: parent.left
			anchors.leftMargin: 45 * DefaultStyle.dp
			anchors.right: parent.right
			anchors.bottom: parent.bottom
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
		id: historyListTitle
		FocusScope{
			objectName: "historyListTitle"
			width: parent.width
			height: titleCallLayout.implicitHeight
			RowLayout {
				id: titleCallLayout
				anchors.fill: parent
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
		}
	}
	Component {
		id: historyListItem
		FocusScope{
			objectName: "historyListItem"
			property alias listView: historyListView
			Control.StackView.onActivated: titleLoader.sourceComponent = historyListTitle
			ColumnLayout {
				anchors.fill: parent
				SearchBar {
					id: searchBar
					Layout.fillWidth: true
					Layout.rightMargin: 39 * DefaultStyle.dp
					placeholderText: qsTr("Rechercher un appel")
                    visible: historyListView.count !== 0 || text.length !== 0
					focus: true
					KeyNavigation.up: titleLoader
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
								ListView {
									id: historyListView
									clip: true
									Layout.fillWidth: true
									Layout.fillHeight: true
									model: CallHistoryProxy {
										id: callHistoryProxy
										filterText: searchBar.text
										onFilterTextChanged: maxDisplayItems = initialDisplayItems
										initialDisplayItems: Math.max(20, 2 * historyListView.height / (56 * DefaultStyle.dp))
										displayItemsStep: 3 * initialDisplayItems / 2
									}
									cacheBuffer: contentHeight>0 ? contentHeight : 0// cache all items
									flickDeceleration: 10000
									spacing: 10 * DefaultStyle.dp
																		
									Keys.onPressed: (event) => {
										if(event.key == Qt.Key_Escape){
											console.log("Back")
											searchBar.forceActiveFocus()
											event.accepted = true
										}
									}
									// remove binding loop
									onContentHeightChanged: Qt.callLater(function(){
										historyListView.cacheBuffer = Math.max(contentHeight,0)
									})
									onActiveFocusChanged: if(activeFocus && currentIndex < 0 && count > 0) currentIndex = 0
									onCountChanged: {
										if(currentIndex < 0 && count > 0){
											historyListView.currentIndex = 0	// Select first item after loading model
										}
										if(atYBeginning)
											positionViewAtBeginning()// Stay at beginning
									}
									Connections {
										target: deleteHistoryPopup
										function onAccepted() {
											historyListView.model.removeAllEntries()
										}
									}
									Connections{
										target: mainItem
										function onListViewUpdated(){
											callHistoryProxy.reload()
										}
									}
									onAtYEndChanged: {
										if(atYEnd && count > 0){
											 callHistoryProxy.displayMore()
										}
									}
//----------------------------------------------------------------
									function moveToCurrentItem(){
										if( historyListView.currentIndex >= 0)
											Utils.updatePosition(historyListView, historyListView)
									}
									onCurrentItemChanged: {
										moveToCurrentItem()
									}
									// Update position only if we are moving to current item and its position is changing.
									property var _currentItemY: currentItem?.y
									on_CurrentItemYChanged: if(_currentItemY && moveAnimation.running){
										moveToCurrentItem()
									}
									Behavior on contentY{
										NumberAnimation {
										id: moveAnimation
											duration: 500
											easing.type: Easing.OutExpo
											alwaysRunToEnd: true
										}
									}
//----------------------------------------------------------------
									
									onCurrentIndexChanged: {
										mainItem.selectedRowHistoryGui = model.getAt(currentIndex)
									}
									onVisibleChanged: {
										if (!visible) currentIndex = -1
									}
									// Qt bug: sometimes, containsMouse may not be send and update on each MouseArea.
									// So we need to use this variable to switch off all hovered items.
									property int lastMouseContainsIndex: -1
									delegate: FocusScope {
										width:historyListView.width
										height: 56 * DefaultStyle.dp
										visible: !!modelData
										
										RowLayout {
											z: 1
											anchors.fill: parent
											anchors.leftMargin: 10 * DefaultStyle.dp
											spacing: 10 * DefaultStyle.dp
											Avatar {
												id: historyAvatar
												property var contactObj: UtilsCpp.findFriendByAddress(modelData.core.remoteAddress)
												contact: contactObj?.value || null
												_address: modelData.core.conferenceInfo
															? modelData.core.conferenceInfo.core.subject
															: modelData.core.remoteAddress
												width: 45 * DefaultStyle.dp
												height: 45 * DefaultStyle.dp
												isConference: modelData.core.isConference
											}
											ColumnLayout {
												Layout.fillHeight: true
												Layout.fillWidth: true
												spacing: 5 * DefaultStyle.dp
												Text {
													id: friendAddress
													Layout.fillWidth: true
													maximumLineCount: 1
													text: historyAvatar.displayNameVal
													font {
														pixelSize: 14 * DefaultStyle.dp
														weight: 400 * DefaultStyle.dp
														capitalization: Font.Capitalize
													}
												}
												RowLayout {
													spacing: 6 * DefaultStyle.dp
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
														text: UtilsCpp.formatDate(modelData.core.date)
														font {
															pixelSize: 12 * DefaultStyle.dp
															weight: 300 * DefaultStyle.dp
														}
													}
												}
											}
											BigButton {
												style: ButtonStyle.noBackground
												icon.source: AppIcons.phone
												focus: true
												activeFocusOnTab: false
												onClicked: {
													if (modelData.core.isConference) {
														var callsWindow = UtilsCpp.getCallsWindow()
														callsWindow.setupConference(modelData.core.conferenceInfo)
														UtilsCpp.smartShowWindow(callsWindow)
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
											focus: true
											onContainsMouseChanged: {
												if(containsMouse)
													historyListView.lastMouseContainsIndex = index
												else if( historyListView.lastMouseContainsIndex == index)
													historyListView.lastMouseContainsIndex = -1
											}	
											Rectangle {
												anchors.fill: parent
												opacity: 0.7
												radius: 8 * DefaultStyle.dp
												color: historyListView.currentIndex === index ? DefaultStyle.main2_200 : DefaultStyle.main2_100
												visible: historyListView.lastMouseContainsIndex === index || historyListView.currentIndex === index
											}
											onPressed: {
												historyListView.currentIndex = model.index
												historyListView.forceActiveFocus()
											}
										}
									}
									
									Control.ScrollBar.vertical: scrollbar
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
		id: newCallTitle
		FocusScope{
			objectName: "newCallTitle"
			width: parent.width
			height: parent.height
			RowLayout {
				anchors.fill: parent
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
		}
	}
	Component {
		id: newCallItem
		FocusScope{
			objectName: "newCallItem"
			width: parent?.width
			height: parent?.height
			Control.StackView.onActivated:{
				titleLoader.sourceComponent = newCallTitle
				callContactsList.forceActiveFocus()
			}
			
			ColumnLayout {
				anchors.fill: parent
				NewCallForm {
					id: callContactsList
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
		id: groupCallTitle
		FocusScope{
			objectName: "groupCallTitle"
			width: parent.width
			height: parent.height
			RowLayout {
				anchors.fill: parent
				spacing: 10 * DefaultStyle.dp
				visible: !SettingsCpp.disableMeetingsFeature
				Button {
					id: backGroupCallButton
					style: ButtonStyle.noBackgroundOrange
					icon.source: AppIcons.leftArrow
					Layout.leftMargin: 21 * DefaultStyle.dp
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
					KeyNavigation.down: listStackView
					KeyNavigation.right: groupCallButton
					KeyNavigation.left: groupCallButton
					onClicked: {
						listStackView.pop()
						titleLoader.item.forceActiveFocus()
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
		}
	}

	Component {
		id: groupCallItem
		FocusScope{
			objectName: "groupCallItem"
			Control.StackView.onActivated: {
				titleLoader.sourceComponent = groupCallTitle
				addParticipantsLayout.forceActiveFocus()
			}
			ColumnLayout {
				spacing: 5 * DefaultStyle.dp
				anchors.fill: parent
				RowLayout {
					spacing: 0
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
			objectName: "contactDetailComp"
			width: parent?.width
			height: parent?.height
			CallHistoryLayout {
				id: contactDetail
				anchors.fill: parent
				anchors.topMargin: 45 * DefaultStyle.dp
				anchors.bottomMargin: 45 * DefaultStyle.dp
				visible: mainItem.selectedRowHistoryGui != undefined

				property var contactObj: UtilsCpp.findFriendByAddress(specificAddress)

				contact: contactObj && contactObj.value || null
				conferenceInfo: mainItem.selectedRowHistoryGui && mainItem.selectedRowHistoryGui.core.conferenceInfo || null
				specificAddress: mainItem.selectedRowHistoryGui && mainItem.selectedRowHistoryGui.core.remoteAddress || ""

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
								property bool isLdap: contactDetail.contact?.core?.isLdap
								property bool isCardDAV: contactDetail.contact?.core?.isCardDAV
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
				}
				detailContent: RoundedPane {
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
							id: detailsHistoryProxy
							filterText: mainItem.selectedRowHistoryGui ? mainItem.selectedRowHistoryGui.core.remoteAddress : ""
							onFilterTextChanged: maxDisplayItems = initialDisplayItems
							initialDisplayItems: Math.max(20, 2 * detailListView.height / (56 * DefaultStyle.dp))
							displayItemsStep: 3 * initialDisplayItems / 2
						}
						onAtYEndChanged: if(atYEnd) detailsHistoryProxy.displayMore()
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
