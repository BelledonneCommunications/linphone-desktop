/**
* Qml template used for overview pages : Calls, Contacts, Conversations, Meetings
**/

import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls as Control

import Linphone
import UtilsCpp

Item {
	id: mainItem
	property string noItemButtonText
	property string newItemIconSource
	property string emptyListText
	property alias leftPanelContent: leftPanel.children
	property alias rightPanelStackView: rightPanelStackView
	property alias contactEditionComp: contactEditionComp
	property alias rightPanel: rightPanel
	property bool showDefaultItem: true
	signal noItemButtonPressed()
	signal contactEditionClosed()

	function createContact(name, address) {
		var friendGui = Qt.createQmlObject('import Linphone
											FriendGui{
											}', mainItem)
		friendGui.core.givenName = UtilsCpp.getGivenNameFromFullName(name)
		friendGui.core.familyName = UtilsCpp.getFamilyNameFromFullName(name)
		friendGui.core.defaultAddress = address
		rightPanelStackView.push(contactEditionComp, {"contact": friendGui, "title": qsTr("Nouveau contact"), "saveButtonText": qsTr("Créer")})
	}

	function editContact(friendGui) {
		rightPanelStackView.push(contactEditionComp, {"contact": friendGui, "title": qsTr("Modifier contact"), "saveButtonText": qsTr("Enregistrer")})
	}

	// Control.SplitView {
	// 	id: splitView
	// 	anchors.fill: parent
	// 	anchors.topMargin: 10 * DefaultStyle.dp

	// 	handle: Rectangle {
	// 		implicitWidth: 8 * DefaultStyle.dp
	// 		color: Control.SplitHandle.hovered ? DefaultStyle.grey_200 : DefaultStyle.grey_100
	// 	}
	// 	ColumnLayout {
	// 		id: leftPanel
	// 		Control.SplitView.preferredWidth: 350 * DefaultStyle.dp
	// 		Control.SplitView.minimumWidth: 350 * DefaultStyle.dp
	// 	}
	// 	Rectangle {
	// 		id: rightPanel
	// 		clip: true
	// 		color: DefaultStyle.grey_100
	// 		StackLayout {
	// 			currentIndex: mainItem.showDefaultItem ? 0 : 1
	// 			anchors.fill: parent
	// 			ColumnLayout {
	// 				id: defaultItem
	// 				Layout.fillWidth: true
	// 				Layout.fillHeight: true
					
	// 				RowLayout {
	// 					Layout.fillHeight: true
	// 					Layout.fillWidth: true
	// 					Layout.alignment: Qt.AlignHCenter
	// 					Item {
	// 						Layout.fillWidth: true
	// 					}
	// 					ColumnLayout {
	// 						spacing: 30 * DefaultStyle.dp
	// 						Item {
	// 							Layout.fillHeight: true
	// 						}
	// 						Image {
	// 							Layout.alignment: Qt.AlignHCenter
	// 							source: AppIcons.noItemImage
	// 							Layout.preferredWidth: 359 * DefaultStyle.dp
	// 							Layout.preferredHeight: 314 * DefaultStyle.dp
	// 							fillMode: Image.PreserveAspectFit
	// 						}
	// 						Text {
	// 							text: mainItem.emptyListText
	// 							Layout.alignment: Qt.AlignHCenter
	// 							font {
	// 								pixelSize: 22 * DefaultStyle.dp
	// 								weight: 800 * DefaultStyle.dp
	// 							}
	// 						}
	// 						Button {
	// 							Layout.alignment: Qt.AlignHCenter
	// 							contentItem: RowLayout {
	// 								Layout.alignment: Qt.AlignVCenter
	// 								EffectImage {
	// 									colorizationColor: DefaultStyle.grey_0
	// 									source: mainItem.newItemIconSource
	// 									width: 24 * DefaultStyle.dp
	// 									height: 24 * DefaultStyle.dp
	// 									fillMode: Image.PreserveAspectFit
	// 								}
	// 								Text {
	// 									text: mainItem.noItemButtonText
	// 									wrapMode: Text.WordWrap
	// 									color: DefaultStyle.grey_0
	// 									font {
	// 										weight: 600 * DefaultStyle.dp
	// 										pixelSize: 18 * DefaultStyle.dp
	// 										family: DefaultStyle.defaultFont
	// 									}
	// 								}
	// 							}
	// 							onPressed: mainItem.noItemButtonPressed()
	// 						}
	// 						Item {
	// 							Layout.fillHeight: true
	// 						}
	// 					}
	// 					Item {
	// 						Layout.fillWidth: true
	// 					}
	// 				}
					
	// 			}
	// 			ColumnLayout {
	// 				id: rightPanelItem
	// 				Layout.fillWidth: true
	// 				Layout.fillHeight: true
	// 			}
	// 		}
	// 	}
	// }

	RowLayout {
		anchors.fill: parent
		anchors.topMargin: 10 * DefaultStyle.dp
		spacing: 0
		ColumnLayout {
			id: leftPanel
			Layout.preferredWidth: 403 * DefaultStyle.dp
			Layout.minimumWidth: 403 * DefaultStyle.dp
			Layout.fillHeight: true
			Layout.fillWidth: false
		}
		Rectangle {
			Layout.fillHeight: true
			Layout.preferredWidth: 1 * DefaultStyle.dp
			color: DefaultStyle.main2_200
		}
		Rectangle {
			id: rightPanel
			clip: true
			color: DefaultStyle.grey_100
			Layout.fillWidth: true
			Layout.fillHeight: true
			StackLayout {
				currentIndex: mainItem.showDefaultItem ? 0 : 1
				anchors.fill: parent
				ColumnLayout {
					id: defaultItem
					Layout.fillWidth: true
					Layout.fillHeight: true
					
					RowLayout {
						Layout.fillHeight: true
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignHCenter
						Item {
							Layout.fillWidth: true
						}
						ColumnLayout {
							spacing: 30 * DefaultStyle.dp
							Item {
								Layout.fillHeight: true
							}
							Image {
								Layout.alignment: Qt.AlignHCenter
								source: AppIcons.noItemImage
								Layout.preferredWidth: 359 * DefaultStyle.dp
								Layout.preferredHeight: 314 * DefaultStyle.dp
								fillMode: Image.PreserveAspectFit
							}
							Text {
								text: mainItem.emptyListText
								Layout.alignment: Qt.AlignHCenter
								font {
									pixelSize: 22 * DefaultStyle.dp
									weight: 800 * DefaultStyle.dp
								}
							}
							Button {
								Layout.alignment: Qt.AlignHCenter
								topPadding: 11 * DefaultStyle.dp
								bottomPadding: 11 * DefaultStyle.dp
								leftPadding: 20 * DefaultStyle.dp
								rightPadding: 20 * DefaultStyle.dp
								contentItem: RowLayout {
									Layout.alignment: Qt.AlignVCenter
									EffectImage {
										colorizationColor: DefaultStyle.grey_0
										imageSource: mainItem.newItemIconSource
										width: 24 * DefaultStyle.dp
										height: 24 * DefaultStyle.dp
										fillMode: Image.PreserveAspectFit
									}
									Text {
										text: mainItem.noItemButtonText
										wrapMode: Text.WordWrap
										color: DefaultStyle.grey_0
										font {
											weight: 600 * DefaultStyle.dp
											pixelSize: 18 * DefaultStyle.dp
											family: DefaultStyle.defaultFont
										}
									}
								}
								onPressed: mainItem.noItemButtonPressed()
							}
							Item {
								Layout.fillHeight: true
							}
						}
						Item {
							Layout.fillWidth: true
						}
					}
					
				}
				Control.StackView {
					id: rightPanelStackView
					Layout.fillWidth: true
					Layout.fillHeight: true
				}
				// We need this component here as it is used in multiple subPages (Call and Contact pages) 
				Component {
					id: contactEditionComp
					ContactEdition {
						property string objectName: "contactEdition"
						onCloseEdition: {
							rightPanelStackView.pop(Control.StackView.Immediate)
							mainItem.contactEditionClosed()
						}
					}
				}
			}
		}
	}
}
