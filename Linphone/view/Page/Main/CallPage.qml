import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone

AbstractMainPage {
	id: mainItem
	noItemButtonText: qsTr("Nouvel appel")
	emptyListText: qsTr("Historique d'appel vide")
	newItemIconSource: AppIcons.newCall

	onNoItemButtonPressed: listStackView.push(newCallItem)

	leftPanelContent: Item {
		Layout.fillWidth: true
		Layout.fillHeight: true
		Control.StackView {
			id: listStackView
			initialItem: listItem
			anchors.fill: parent
			anchors.leftMargin: 25
			anchors.rightMargin: 25
		}
		Component {
			id: listItem

			ColumnLayout {
				RowLayout {
					Layout.fillWidth: true
					Text {
						text: qsTr("Appels")
						color: DefaultStyle.mainPageTitleColor
						font.pointSize: DefaultStyle.mainPageTitleSize
						font.bold: true
					}
					Item {
						Layout.fillWidth: true
					}
					Control.Button {
						enabled: false
						background: Item {
						}
						contentItem: Image {
							source: AppIcons.verticalDots
						}
					}
					Control.Button {

						background: Item {
							visible: false
						}
						contentItem: Image {
							source: AppIcons.newCall
							width: 30
							sourceSize.width: 30
							fillMode: Image.PreserveAspectFit
						}
						onClicked: {
							console.log("[CallPage]User: create new call")
							listStackView.push(newCallItem)
						}
					}
				}
				Control.Control {
					id: listLayout
					Layout.fillWidth: true
					Layout.fillHeight: true

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
								font.bold: true
								visible: listView.count === 0
								Layout.alignment: Qt.AlignHCenter
								Layout.topMargin: 30
							}
							ListView {
								id: listView
								clip: true
								Layout.fillWidth: true
								Layout.fillHeight: true
								model: 0
								currentIndex: 0

								delegate: Item {
									required property int index
									width:listView.width
									height: 30
									// RectangleTest{}
									RowLayout {
										anchors.fill: parent
										Image {
											source: AppIcons.info
										}
										ColumnLayout {
											Text {
												text: "John Doe"
											}
											// RowLayout {
											// 	Image {
											// 		source: AppIcons.incomingCall
											// 	}
											// 	Text {
											// 		text: "info sur l'appel"
											// 	}
											// }
										}
										Item {
											Layout.fillWidth: true
										}
										Control.Button {
											implicitWidth: 30
											implicitHeight: 30
											background: Item {
												visible: false
											}
											contentItem: Image {
												source: AppIcons.phone
												width: 20
												sourceSize.width: 20
												fillMode: Image.PreserveAspectFit
											}
										}
									}
									MouseArea {
										hoverEnabled: true
										Rectangle {
											anchors.fill: parent
											opacity: 0.1
											radius: 15
											color: DefaultStyle.comboBoxHoverColor
											visible: parent.containsMouse
										}
										onPressed: listView.currentIndex = parent.index
									}
								}

								onCountChanged: mainItem.showDefaultItem = listView.count === 0

								Control.ScrollIndicator.vertical: Control.ScrollIndicator { }
							}
						}
					}
				}
			}
		}
		Component {
			id: newCallItem
			ColumnLayout {
				RowLayout {
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
						color: DefaultStyle.mainPageTitleColor
						font.pointSize: DefaultStyle.mainPageTitleSize
						font.bold: true
					}
					Item {
						Layout.fillWidth: true
					}
				}
				Control.Control {
					id: listLayout
					Layout.fillWidth: true
					Layout.fillHeight: true
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
							numericPad: numPad
						}
						Button {
							Layout.fillWidth: true
							leftPadding: 0
							topPadding: 0
							rightPadding: 0
							bottomPadding: 0
							background: Rectangle {
								color: DefaultStyle.groupCallButtonColor
								anchors.fill: parent
								radius: 50
							}
							contentItem: RowLayout {
								Image {
									source: AppIcons.groupCall
									Layout.preferredWidth: 35
									sourceSize.width: 35
									fillMode: Image.PreserveAspectFit
								}
								Text {
									text: "Appel de groupe"
									font.bold: true
								}
								Item {
									Layout.fillWidth: true
								}
								Image {
									source: AppIcons.rightArrow
								}
							}
						}
						ColumnLayout {
							ListView {
								Layout.fillHeight: true
								// call history
							}
						}
					}
				}
			}
		}

		Item {
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.right: parent.right
			height: numPad.height
			NumericPad {
				id: numPad
				// anchors.centerIn: parent
				width: parent.width
			}
		}
	}

	rightPanelContent: ColumnLayout {

	}
}