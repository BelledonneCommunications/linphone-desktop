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
	property Component rightPanelContent
	property bool showDefaultItem: true
	onShowDefaultItemChanged: stackView.replace(showDefaultItem ? defaultItem : rightPanel)
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
			Control.StackView {
				id: stackView
				initialItem: defaultItem
				anchors.fill: parent
				Layout.alignment: Qt.AlignCenter
			}
			Component {
				id: defaultItem
				ColumnLayout {
					Item {
						Layout.fillHeight: true
					}
					ColumnLayout {
						Layout.fillHeight: true
						Layout.fillWidth: true
						visible: mainItem.showDefaultItem
						// anchors.centerIn: parent
						Layout.alignment: Qt.AlignHCenter
						spacing: 25
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
									effect.brightness: 1
									image.source: mainItem.newItemIconSource
									image.width: 20
									image.fillMode: Image.PreserveAspectFit
								}
								Text {
									text: mainItem.noItemButtonText
									wrapMode: Text.WordWrap
									color: DefaultStyle.buttonTextColor
									font {
										bold: true
										pointSize: DefaultStyle.buttonTextSize
										family: DefaultStyle.defaultFont
									}
								}
							}
							onPressed: mainItem.noItemButtonPressed()
						}
					}
					Item {
						Layout.fillHeight: true
					}
				}
			}
		}
	}
}
				
