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

	Control.SplitView {
		id: splitView
		anchors.fill: parent
    	anchors.topMargin: Utils.getSizeWithScreenRatio(10)

		handle: Rectangle {
    		implicitWidth: Utils.getSizeWithScreenRatio(6)
			color: Control.SplitHandle.hovered ? DefaultStyle.main2_200 : DefaultStyle.grey_200
		}
		ColumnLayout {
			id: leftPanel
			spacing:0
			// Control.SplitView.fillWidth:false
			Control.SplitView.fillHeight: true
			Control.SplitView.preferredWidth: Utils.getSizeWithScreenRatio(404)
    		Control.SplitView.minimumWidth: Utils.getSizeWithScreenRatio(200)
    		Control.SplitView.maximumWidth: Utils.getSizeWithScreenRatio(500)
		}
		Rectangle {
			id: rightPanel
			clip: true
			color: mainItem.rightPanelColor
			Control.SplitView.fillWidth: true
			Control.SplitView.fillHeight: true

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
