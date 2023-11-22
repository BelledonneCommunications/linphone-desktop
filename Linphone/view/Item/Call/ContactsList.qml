import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects

import Linphone

Item {
	id: mainItem
	property int sideMargin: 25
	property int topMargin: 5
	property bool groupCallVisible
	property color searchBarColor: DefaultStyle.contactListSearchBarColor
	property color searchBarBorderColor: "transparent"
	signal callButtonPressed(string address)
	clip: true
	Control.Control {
		id: listLayout
		anchors.fill: parent
		anchors.leftMargin: mainItem.sideMargin
		anchors.rightMargin: mainItem.sideMargin
		anchors.topMargin: mainItem.topMargin
		background: Item {
			anchors.fill: parent
		}
		contentItem: ColumnLayout {
			anchors.fill: parent
			spacing: 10
			SearchBar {
				id: searchBar
				Layout.alignment: Qt.AlignTop
				Layout.fillWidth: true
				Layout.maximumWidth: mainItem.width
				color: mainItem.searchBarColor
				borderColor: mainItem.searchBarBorderColor
				placeholderText: qsTr("Rechercher un contact")
				numericPad: numPad
			}
			Button {
				visible: mainItem.groupCallVisible
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

			RowLayout {
				visible: searchBar.text.length > 0 // && contactList.count === 0 (pas trouvé dans la liste)
				Layout.maximumWidth: parent.width
				Layout.fillWidth: true
				Text {
					text: searchBar.text
					maximumLineCount: 1
					elide: Text.ElideRight
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
					onClicked: {
						mainItem.callButtonPressed(searchBar.text)
					}
				}
			}
			ColumnLayout {
				ListView {
					id: contactList
					Layout.fillWidth: true
					Layout.fillHeight: true
					// call history
					model: 30
					delegate: Item {
						required property int index
						width:contactList.width
						height: 30
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
							onClicked: contactList.currentIndex = parent.index
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
			onLaunchCall: {
				var callVarObject = UtilsCpp.createCall(searchBar.text + "@sip.linphone.org")
				// TODO : auto completion instead of sip linphone
				var windowComp = Qt.createComponent("OngoingCallPage.qml")
				var callWindow = windowComp.createObject({callVarObject: callVarObject})
				callWindow.show()
			}
		}
	}
}