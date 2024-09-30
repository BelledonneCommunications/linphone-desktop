/**
* Qml template used for overview pages : Calls, Contacts, Conversations, Meetings, Settings
**/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp

FocusScope {
	id: mainItem
	property string noItemButtonText
	property string newItemIconSource
	property string emptyListText
	property bool showDefaultItem: true
	property color rightPanelColor: DefaultStyle.grey_100
	property alias leftPanelContent: leftPanel.children
	property alias rightPanelStackView: rightPanelStackView
	property alias rightPanel: rightPanel
	signal noItemButtonPressed()

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
		spacing: 0
		ColumnLayout {
			id: leftPanel
			Layout.preferredWidth: 404 * DefaultStyle.dp
			Layout.fillWidth:false
			spacing:0
		}
		Rectangle {
			Layout.fillHeight: true
			Layout.preferredWidth: 1 * DefaultStyle.dp
			color: DefaultStyle.main2_200
		}
		Rectangle {
			id: rightPanel
			clip: true
			color: mainItem.rightPanelColor
			Layout.fillWidth: true
			Layout.fillHeight: true

			StackLayout {
				currentIndex: mainItem.showDefaultItem ? 0 : 1
				anchors.fill: parent
				ColumnLayout {
					id: defaultItem
					
					RowLayout {
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
			}
		}
	}
}
