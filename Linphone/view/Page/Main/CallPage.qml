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

	onNoItemButtonPressed: goToNewCall()

	showDefaultItem: listStackView.currentItem.listView ? listStackView.currentItem.listView.count === 0 : true

	function goToNewCall() {
		listStackView.push(newCallItem)
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
				RowLayout {
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
						popup.x: 0
						popup.padding: 10 * DefaultStyle.dp
						popup.contentItem: Button {
							background: Item{}
							contentItem: RowLayout {
								EffectImage {
									image.source: AppIcons.trashCan
									width: 24 * DefaultStyle.dp
									height: 24 * DefaultStyle.dp
									Layout.preferredWidth: 24 * DefaultStyle.dp
									Layout.preferredHeight: 24 * DefaultStyle.dp
									image.fillMode: Image.PreserveAspectFit
									colorizationColor: DefaultStyle.danger_500main
								}
								Text {
									text: qsTr("Supprimmer l’historique")
									color: DefaultStyle.danger_500main
									font {
										pixelSize: 14 * DefaultStyle.dp
										weight: 400 * DefaultStyle.dp
									}
								}
							}
							onClicked: {
								historyListView.model.removeAllEntries()
								removeHistory.closePopup()
							}
						}
					}
					Control.Button {

						background: Item {
							visible: false
						}
						contentItem: Image {
							source: AppIcons.newCall
							width: 30 * DefaultStyle.dp
							sourceSize.width: 30 * DefaultStyle.dp
							fillMode: Image.PreserveAspectFit
						}
						onClicked: {
							console.debug("[CallPage]User: create new call")
							listStackView.push(newCallItem)
						}
					}
				}
				RowLayout {
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
							SearchBar {
								id: searchBar
								Layout.alignment: Qt.AlignTop
								Layout.fillWidth: true
								placeholderText: qsTr("Rechercher un appel")
							}
							ColumnLayout {
								Text {
									text: qsTr("Aucun appel")
									font {
										pixelSize: 16 * DefaultStyle.dp
										weight: 800 * DefaultStyle.dp
									}
									visible: historyListView.count === 0
									Layout.alignment: Qt.AlignHCenter
									Layout.topMargin: 30 * DefaultStyle.dp
								}
								ListView {
									id: historyListView
									clip: true
									Layout.fillWidth: true
									Layout.fillHeight: true
									Layout.topMargin: 30 * DefaultStyle.dp
									model: CallHistoryProxy{
										filterText: searchBar.text
									}
									currentIndex: -1
									onCurrentIndexChanged: {
										mainItem.selectedRowHistoryGui = model.getAt(currentIndex)
									}
									spacing: 10 * DefaultStyle.dp
									highlightMoveDuration: 10
									highlightMoveVelocity: -1
									// highlightFollowsCurrentItem: true
									highlight: Rectangle {
										x: historyListView.x
										width: historyListView.width
										height: historyListView.height
										color: DefaultStyle.main2_100
										y: historyListView.currentItem? historyListView.currentItem.y : 0
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
												Layout.alignment: Qt.AlignVCenter
												Text {
													property var remoteAddress: modelData ? UtilsCpp.getDisplayName(modelData.core.remoteAddress) : undefined
													text: remoteAddress ? remoteAddress.value : ""
													font {
														pixelSize: 14 * DefaultStyle.dp
														weight: 400 * DefaultStyle.dp
													}
												}
												RowLayout {
													Image {
														source: modelData.core.status === LinphoneEnums.CallStatus.Declined
														|| modelData.core.status === LinphoneEnums.CallStatus.DeclinedElsewhere
														|| modelData.core.status === LinphoneEnums.CallStatus.Aborted
														|| modelData.core.status === LinphoneEnums.CallStatus.EarlyAborted
															? modelData.core.isOutgoing 
																? AppIcons.outgoingCallRejected 
																: AppIcons.incomingCallRejected
															: modelData.core.status === LinphoneEnums.CallStatus.Missed
																? modelData.core.isOutgoing
																	? AppIcons.outgoingCallMissed 
																	: AppIcons.incomingCallMissed
																: modelData.core.isOutgoing
																	? AppIcons.outgoingCall 
																	: AppIcons.incomingCall
														Layout.preferredWidth: 5 * DefaultStyle.dp
														Layout.preferredHeight: 5 * DefaultStyle.dp
														sourceSize.width: 5 * DefaultStyle.dp
														sourceSize.height: 5 * DefaultStyle.dp
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
											Item {
												Layout.fillWidth: true
											}
											Control.Button {
												implicitWidth: 24 * DefaultStyle.dp
												implicitHeight: 24 * DefaultStyle.dp
												Layout.rightMargin: 5 * DefaultStyle.dp
												padding: 0
												background: Item {
													visible: false
												}
												contentItem: Image {
													source: AppIcons.phone
													width: 24 * DefaultStyle.dp
													sourceSize.width: 24 * DefaultStyle.dp
													fillMode: Image.PreserveAspectFit
												}
												onClicked: {
													var addr = modelData.core.remoteAddress
													var addressEnd = "@sip.linphone.org"
													if (!addr.endsWith(addressEnd)) addr += addressEnd
													var callVarObject = UtilsCpp.createCall(addr)
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
											onPressed: {
												historyListView.currentIndex = model.index
											}
										}
									}

									onCountChanged: {
										mainItem.showDefaultItem = historyListView.count === 0 && historyListView.visible
									}

									onVisibleChanged: {
										mainItem.showDefaultItem = historyListView.count === 0 && historyListView.visible
										if (!visible) currentIndex = -1
									}

									Connections {
										target: mainItem
										onShowDefaultItemChanged: mainItem.showDefaultItem = mainItem.showDefaultItem && historyListView.count === 0 && historyListView.visible
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
						Layout.fillHeight: true
					}
				}
			}
		}
		Component {
			id: newCallItem
			ColumnLayout {
				Control.StackView.onActivating: {
					mainItem.showDefaultItem = false
				}
				Control.StackView.onDeactivating: mainItem.showDefaultItem = true
				RowLayout {
					Layout.leftMargin: listStackView.sideMargin
					Layout.rightMargin: listStackView.sideMargin
					Control.Button {
						background: Item {
						}
						contentItem: Image {
							source: AppIcons.returnArrow
						}
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
				ContactsList {
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.maximumWidth: parent.width
					groupCallVisible: true
					searchBarColor: DefaultStyle.grey_100
					
					onCallButtonPressed: (address) => {
						var addressEnd = "@sip.linphone.org"
						if (!address.endsWith(addressEnd)) address += addressEnd
						var callVarObject = UtilsCpp.createCall(address)
						// var window = UtilsCpp.getCallsWindow()
					}
				}
			}
		}
	}

	rightPanelContent: RowLayout {
		Layout.fillWidth: true
		Layout.fillHeight: true
		visible: mainItem.selectedRowHistoryGui != undefined
		Layout.topMargin: 45 * DefaultStyle.dp
		
		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
		ColumnLayout {
			spacing: 30 * DefaultStyle.dp
			Layout.fillWidth: true
			Layout.fillHeight: true

			Item {
				Layout.preferredHeight: detailAvatar.height
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignHCenter
				Avatar {
					id: detailAvatar
					anchors.centerIn: parent
					width: 100 * DefaultStyle.dp
					height: 100 * DefaultStyle.dp
					address: mainItem.selectedRowHistoryGui ? mainItem.selectedRowHistoryGui.core.remoteAddress : ""
				}
				PopupButton {
					id: detailOptions
					anchors.left: detailAvatar.right
					anchors.leftMargin: 30 * DefaultStyle.dp
					anchors.verticalCenter: parent.verticalCenter
					popup.x: width
					popup.contentItem: ColumnLayout {
						Button {
							background: Item {}
							contentItem: IconLabel {
								text: qsTr("Ajouter aux contacts")
								iconSource: AppIcons.plusCircle
							}
							onClicked: console.debug("[CallPage.qml] TODO : add to contact")
						}
						Button {
							background: Item {}
							contentItem: IconLabel {
								text: qsTr("Copier l'adresse SIP")
								iconSource: AppIcons.copy
							}
							onClicked: console.debug("[CallPage.qml] TODO : copy SIP address")
						}
						Button {
							background: Item {}
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
							onClicked: {
								detailListView.model.removeEntriesWithFilter()
								detailListView.currentIndex = -1 // reset index for ui
								detailOptions.closePopup()
							}
						}
					}
				}
			}
			ColumnLayout {
				Layout.alignment: Qt.AlignHCenter
				Layout.fillWidth: true
				Text {
					property var remoteAddress: mainItem.selectedRowHistoryGui ? UtilsCpp.getDisplayName(mainItem.selectedRowHistoryGui.core.remoteAddress) : undefined
					Layout.alignment: Qt.AlignHCenter
					text: remoteAddress ? remoteAddress.value : ""
					horizontalAlignment: Text.AlignHCenter
					font {
						pixelSize: 14 * DefaultStyle.dp
						weight: 400 * DefaultStyle.dp
					}
				}
				Text {
					text: mainItem.selectedRowHistoryGui ? mainItem.selectedRowHistoryGui.core.remoteAddress : ""
					horizontalAlignment: Text.AlignHCenter
					font {
						pixelSize: 12 * DefaultStyle.dp
						weight: 300 * DefaultStyle.dp
					}
				}
				Text {
					// connection status
				}
			}
			RowLayout {
				spacing: 40 * DefaultStyle.dp
				Layout.alignment: Qt.AlignHCenter
				Layout.fillWidth: true
				// Layout.fillHeight: true
				Item {Layout.fillWidth: true}
				LabelButton {
					Layout.preferredWidth: 24 * DefaultStyle.dp//image.width
					Layout.preferredHeight: image.height
					image.source: AppIcons.phone
					label: qsTr("Appel")
					button.onClicked: {
						var addr = mainItem.selectedRowHistoryGui.core.remoteAddress
						var addressEnd = "@sip.linphone.org"
						if (!addr.endsWith(addressEnd)) addr += addressEnd
						UtilsCpp.createCall(addr)
				}
				}
				LabelButton {
					Layout.preferredWidth: image.width
					Layout.preferredHeight: image.height
					image.source: AppIcons.chatTeardropText
					label: qsTr("Message")
					button.onClicked: console.debug("[CallPage.qml] TODO : open conversation")
				}
				LabelButton {
					Layout.preferredWidth: image.width
					Layout.preferredHeight: image.height
					image.source: AppIcons.videoCamera
					label: qsTr("Appel Video")
					button.onClicked: {
						var addr = mainItem.selectedRowHistoryGui.core.remoteAddress
						var addressEnd = "@sip.linphone.org"
						if(!addr.endsWith(addressEnd)) addr += addressEnd
						UtilsCpp.createCall(addr)
						console.log("[CallPage.qml] TODO : enable video")
					}
				}
				Item {Layout.fillWidth: true}

			}
			
			Control.Control {
				id: detailControl
				Layout.preferredWidth: detailListView.width + leftPadding + rightPadding
				implicitHeight: 430 * DefaultStyle.dp + topPadding + bottomPadding

				Layout.alignment: Qt.AlignHCenter
				Layout.topMargin: 30 * DefaultStyle.dp

				topPadding: 16 * DefaultStyle.dp
				bottomPadding: 21 * DefaultStyle.dp
				leftPadding: 17 * DefaultStyle.dp
				rightPadding: 17 * DefaultStyle.dp

				background: Rectangle {
					id: detailListBackground
					width: parent.width
					height: detailListView.height
					color: DefaultStyle.grey_0
					radius: 15 * DefaultStyle.dp
				}
				ListView {
					id: detailListView
					width: 360 * DefaultStyle.dp
					height: Math.min(detailControl.implicitHeight, contentHeight)
					anchors.centerIn: detailListBackground
					anchors.bottomMargin: 21 * DefaultStyle.dp
					spacing: 10 * DefaultStyle.dp
					clip: true

					onCountChanged: {
						mainItem.listViewUpdated()
					}

					model: CallHistoryProxy {
						filterText: mainItem.selectedRowHistoryGui ? mainItem.selectedRowHistoryGui.core.remoteAddress : ""
					}
					delegate: Item {
						width:detailListView.width
						height: 56 * DefaultStyle.dp
						// anchors.topMargin: 5 * DefaultStyle.dp
						// anchors.bottomMargin: 5 * DefaultStyle.dp
						RowLayout {
							anchors.fill: parent
							ColumnLayout {
								Layout.alignment: Qt.AlignVCenter
								RowLayout {
									Image {
										source: modelData.core.status === LinphoneEnums.CallStatus.Declined
										|| modelData.core.status === LinphoneEnums.CallStatus.DeclinedElsewhere
										|| modelData.core.status === LinphoneEnums.CallStatus.Aborted
										|| modelData.core.status === LinphoneEnums.CallStatus.EarlyAborted
											? modelData.core.isOutgoing 
												? AppIcons.outgoingCallRejected 
												: AppIcons.incomingCallRejected
											: modelData.core.status === LinphoneEnums.CallStatus.Missed
												? modelData.core.isOutgoing
													? AppIcons.outgoingCallMissed 
													: AppIcons.incomingCallMissed
												: modelData.core.isOutgoing
													? AppIcons.outgoingCall 
													: AppIcons.incomingCall
										Layout.preferredWidth: 6.67 * DefaultStyle.dp
										Layout.preferredHeight: 6.67 * DefaultStyle.dp
										sourceSize.width: 6.67 * DefaultStyle.dp
										sourceSize.height: 6.67 * DefaultStyle.dp
									}
									Text {
										Component.onCompleted: console.log("status", modelData.core.status)
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
		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
	}

	component LabelButton: ColumnLayout {
		id: labelButton
		property alias image: buttonImg
		property alias button: button
		property string label
		spacing: 8 * DefaultStyle.dp
		Button {
			id: button
			Layout.alignment: Qt.AlignHCenter
			Layout.preferredWidth: 56 * DefaultStyle.dp
			Layout.preferredHeight: 56 * DefaultStyle.dp
			topPadding: 16 * DefaultStyle.dp
			bottomPadding: 16 * DefaultStyle.dp
			leftPadding: 16 * DefaultStyle.dp
			rightPadding: 16 * DefaultStyle.dp
			background: Rectangle {
				anchors.fill: parent
				radius: 40 * DefaultStyle.dp
				color: DefaultStyle.main2_200
			}
			contentItem: Image {
				id: buttonImg
				source: labelButton.source
				width: 24 * DefaultStyle.dp
				height: 24 * DefaultStyle.dp
				fillMode: Image.PreserveAspectFit
				sourceSize.width: 24 * DefaultStyle.dp
				sourceSize.height: 24 * DefaultStyle.dp
			}
		}
		Text {
			Layout.alignment: Qt.AlignHCenter
			text: labelButton.label
			font {
				pixelSize: 14 * DefaultStyle.dp
				weight: 400 * DefaultStyle.dp
			}
		}
	}

	component IconLabel: RowLayout {
		id: iconLabel
		property string text
		property string iconSource
		property color colorizationColor: DefaultStyle.main2_500main
		EffectImage {
			image.source: iconLabel.iconSource
			width: 24 * DefaultStyle.dp
			height: 24 * DefaultStyle.dp
			Layout.preferredWidth: 24 * DefaultStyle.dp
			Layout.preferredHeight: 24 * DefaultStyle.dp
			image.fillMode: Image.PreserveAspectFit
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
