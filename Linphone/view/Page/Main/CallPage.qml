import QtQuick 2.15
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone
import UtilsCpp 1.0

AbstractMainPage {
	id: mainItem
	noItemButtonText: qsTr("Nouvel appel")
	emptyListText: qsTr("Historique d'appel vide")
	newItemIconSource: AppIcons.newCall

	property var selectedRowHistoryGui

	signal listViewUpdated()

	onSelectedRowHistoryGuiChanged: {
		if (selectedRowHistoryGui) rightPanelStackView.replace(contactDetailComp, Control.StackView.Immediate)
		else rightPanelStackView.replace(emptySelection, Control.StackView.Immediate)
	}
	rightPanelStackView.initialItem: emptySelection

	onNoItemButtonPressed: goToNewCall()

	showDefaultItem: listStackView.currentItem.listView && listStackView.currentItem.listView.count === 0 && listStackView.currentItem.listView.model.sourceModel.count === 0 || false

	function goToNewCall() {
		listStackView.push(newCallItem)
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
			clip: true
			initialItem: historyListItem
			anchors.fill: parent
			property int sideMargin: 25 * DefaultStyle.dp
			// anchors.leftMargin: 25
			// anchors.rightMargin: 25
		}
		Component {
			id: historyListItem

			ColumnLayout {
				spacing: 30 * DefaultStyle.dp
				property alias listView: historyListView
				RowLayout {
					spacing: 16 * DefaultStyle.dp
					Layout.fillWidth: true
					Layout.leftMargin: listStackView.sideMargin
					Layout.rightMargin: listStackView.sideMargin
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
							Connections {
								target: deleteHistoryPopup
								onAccepted: {
									historyListView.model.removeAllEntries()
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
						icon.width: 28 * DefaultStyle.dp
						icon.height: 28 * DefaultStyle.dp
						onClicked: {
							console.debug("[CallPage]User: create new call")
							listStackView.push(newCallItem)
						}
					}
				}
				ColumnLayout {
					SearchBar {
						id: searchBar
						Layout.fillWidth: true
						Layout.leftMargin: listStackView.sideMargin
						Layout.rightMargin: listStackView.sideMargin
						placeholderText: qsTr("Rechercher un appel")
					}
					RowLayout {
						Layout.topMargin: 30 * DefaultStyle.dp	
						Control.Control {
							id: listLayout
							Layout.fillWidth: true
							Layout.fillHeight: true
							Layout.leftMargin: listStackView.sideMargin
							Layout.rightMargin: listStackView.sideMargin

							background: Rectangle {
								anchors.fill: parent
							}
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
														property var remoteAddress: modelData ? UtilsCpp.getDisplayName(modelData.core.remoteAddress) : null
														text: remoteAddress ? remoteAddress.value : ""
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
													property var callObj
													background: Item {
														visible: false
													}
													icon.source: AppIcons.phone
													Layout.preferredWidth: 24 * DefaultStyle.dp
													Layout.preferredHeight: 24 * DefaultStyle.dp
													icon.width: 24 * DefaultStyle.dp
													icon.height: 24 * DefaultStyle.dp
													onClicked: {
														var addr = UtilsCpp.generateLinphoneSipAddress(modelData.core.remoteAddress)
														callObj = UtilsCpp.createCall(addr)
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
											onListViewUpdated: {
												historyListView.model.updateView()
											}
										}
										Control.ScrollBar.vertical: scrollbar
									}
								}
							}
						}
						Control.ScrollBar {
							id: scrollbar
							active: true
							policy: Control.ScrollBar.AsNeeded
							Layout.fillHeight: true
						}
					}
				}
			}
		}
		Component {
			id: newCallItem
			ColumnLayout {
				spacing: 30 * DefaultStyle.dp
				RowLayout {
					Layout.leftMargin: listStackView.sideMargin
					Layout.rightMargin: listStackView.sideMargin
					Button {
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
				CallContactsLists {
					Layout.fillWidth: true
					Layout.fillHeight: true
					// Layout.leftMargin: listStackView.sideMargin
					// Layout.rightMargin: listStackView.sideMargin
					groupCallVisible: true
					searchBarColor: DefaultStyle.grey_100
					property var callObj
					
					onCallButtonPressed: (address) => {
						callObj = UtilsCpp.createCall(UtilsCpp.generateLinphoneSipAddress(address))
						// var window = UtilsCpp.getCallsWindow()
					}
				}
			}
		}
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
			property var remoteName: mainItem.selectedRowHistoryGui ? UtilsCpp.getDisplayName(mainItem.selectedRowHistoryGui.core.remoteAddress) : null
			contactAddress: mainItem.selectedRowHistoryGui && mainItem.selectedRowHistoryGui.core.remoteAddress || ""
			contactName: remoteName ? remoteName.value : ""
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
				popup.contentItem: ColumnLayout {
					Button {
						background: Item {}
						contentItem: IconLabel {
							text: qsTr("Ajouter aux contacts")
							iconSource: AppIcons.plusCircle
						}
						onClicked: {
							detailOptions.close()
							mainItem.createContact(contactDetail.contactName, contactDetail.contactAddress)
						}
					}
					Button {
						background: Item {}
						contentItem: IconLabel {
							text: qsTr("Copier l'adresse SIP")
							iconSource: AppIcons.copy
						}
						onClicked: UtilsCpp.copyToClipboard(mainItem.selectedRowHistoryGui && mainItem.selectedRowHistoryGui.core.remoteAddress)
					}
					Button {
						background: Item {}
						enabled: false
						contentItem: IconLabel {
							text: qsTr("Bloquer")
							iconSource: AppIcons.empty
						}
						onClicked: console.debug("[CallPage.qml] TODO : block user")
					}
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
							onAccepted: {
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
