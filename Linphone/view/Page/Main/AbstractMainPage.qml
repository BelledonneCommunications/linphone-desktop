/**
* Qml template used for overview pages : Calls, Contacts, Conversations, Meetings, Settings
**/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

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
	property int rightPanelStackTopMargin: 0
	property int rightPanelStackBottomMargin: 0
	signal noItemButtonPressed()

	// Control.SplitView {
	// 	id: splitView
	// 	anchors.fill: parent
    // 	anchors.topMargin: Utils.getSizeWithScreenRatio(10)

	// 	handle: Rectangle {
    // 		implicitWidth: Utils.getSizeWithScreenRatio(8)
	// 		color: Control.SplitHandle.hovered ? DefaultStyle.grey_200 : DefaultStyle.grey_100
	// 	}
	// 	ColumnLayout {
	// 		id: leftPanel
    // 		Control.SplitView.preferredWidth: Utils.getSizeWithScreenRatio(350)
    // 		Control.SplitView.minimumWidth: Utils.getSizeWithScreenRatio(350)
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
    // 						spacing: Utils.getSizeWithScreenRatio(30)
	// 						Item {
	// 							Layout.fillHeight: true
	// 						}
	// 						Image {
	// 							Layout.alignment: Qt.AlignHCenter
	// 							source: AppIcons.noItemImage
    // 							Layout.preferredWidth: Utils.getSizeWithScreenRatio(359)
    // 							Layout.preferredHeight: Utils.getSizeWithScreenRatio(314)
	// 							fillMode: Image.PreserveAspectFit
	// 						}
	// 						Text {
	// 							text: mainItem.emptyListText
	// 							Layout.alignment: Qt.AlignHCenter
	// 							font {
    // 								pixelSize: Utils.getSizeWithScreenRatio(22)
    // 								weight: Utils.getSizeWithScreenRatio(800)
	// 							}
	// 						}
	// 						Button {
	// 							Layout.alignment: Qt.AlignHCenter
	// 							contentItem: RowLayout {
	// 								Layout.alignment: Qt.AlignVCenter
	// 								EffectImage {
	// 									colorizationColor: DefaultStyle.grey_0
	// 									source: mainItem.newItemIconSource
    // 									width: Utils.getSizeWithScreenRatio(24)
    // 									height: Utils.getSizeWithScreenRatio(24)
	// 									fillMode: Image.PreserveAspectFit
	// 								}
	// 								Text {
	// 									text: mainItem.noItemButtonText
	// 									wrapMode: Text.WordWrap
	// 									color: DefaultStyle.grey_0
	// 									font {
    // 										weight: Utils.getSizeWithScreenRatio(600)
    // 										pixelSize: Utils.getSizeWithScreenRatio(18)
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
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(404)
			Layout.fillWidth:false
			spacing:0
		}
		Rectangle {
			Layout.fillHeight: true
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(1)
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
                            spacing: Utils.getSizeWithScreenRatio(30)
							Item {
								Layout.fillHeight: true
							}
							Image {
								Layout.alignment: Qt.AlignHCenter
								source: AppIcons.noItemImage
                                Layout.preferredWidth: Utils.getSizeWithScreenRatio(359)
                                Layout.preferredHeight: Utils.getSizeWithScreenRatio(314)
								fillMode: Image.PreserveAspectFit
							}
							Text {
								text: mainItem.emptyListText
								Layout.alignment: Qt.AlignHCenter
								font {
                                    pixelSize: Typography.h3.pixelSize
                                    weight: Typography.h3.weight
								}
							}
							BigButton {
								Layout.alignment: Qt.AlignHCenter
								icon.source: mainItem.newItemIconSource
								style: ButtonStyle.main
								text: mainItem.noItemButtonText
                                spacing: Utils.getSizeWithScreenRatio(8)
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
					Layout.topMargin: mainItem.rightPanelStackTopMargin
					Layout.bottomMargin: mainItem.rightPanelStackBottomMargin
					visible: false
				}
			}
		}
	}
}
