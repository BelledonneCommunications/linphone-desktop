/**
* Qml template used for overview pages : Calls, Contacts, Conversations, Meetings
**/

import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls as Control

import Linphone


Item {
	id: mainItem
	property string noItemButtonText
	property string newItemIconSource
	property string emptyListText
	property alias leftPanelContent: leftPanel.children
	property var rightPanelContent: rightPanelItem.children
	property bool showDefaultItem: true
	// onShowDefaultItemChanged: stackView.replace(showDefaultItem ? defaultItem : rightPanelItem)
	signal noItemButtonPressed()

	Control.SplitView {
		id: splitView
		anchors.fill: parent

		handle: Rectangle {
			implicitWidth: 8
			color: Control.SplitHandle.hovered ? DefaultStyle.splitViewHoveredHandleColor : DefaultStyle.splitViewHandleColor
		}

		ColumnLayout {
			id: leftPanel
			Control.SplitView.preferredWidth: 280
		}
		Rectangle {
			id: rightPanel
			clip: true
			color: DefaultStyle.mainPageRightPanelBackgroundColor
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
						spacing: 25
						Item {
							Layout.fillWidth: true
						}
						ColumnLayout {
							Item {
								Layout.fillHeight: true
							}
							Image {
								Layout.alignment: Qt.AlignHCenter
								source: AppIcons.noItemImage
								Layout.preferredWidth: 250
								Layout.preferredHeight: 250
								fillMode: Image.PreserveAspectFit
							}
							Text {
								text: mainItem.emptyListText
								Layout.alignment: Qt.AlignHCenter
								font.bold: true
							}
							Button {
								Layout.alignment: Qt.AlignHCenter
								contentItem: RowLayout {
									Layout.alignment: Qt.AlignVCenter
									EffectImage {
										colorizationColor: DefaultStyle.grey_0
										image.source: mainItem.newItemIconSource
										image.width: 20
										image.fillMode: Image.PreserveAspectFit
									}
									Text {
										text: mainItem.noItemButtonText
										wrapMode: Text.WordWrap
										color: DefaultStyle.grey_0
										font {
											bold: true
											pointSize: DefaultStyle.buttonTextSize
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
				Item {
					id: rightPanelItem
					Layout.fillWidth: true
					Layout.fillHeight: true
				}
			}
		}
	}
}
				
