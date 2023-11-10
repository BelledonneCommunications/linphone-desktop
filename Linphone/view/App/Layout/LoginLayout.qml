/**
* Qml template used for welcome and login/register pages
**/

import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control

import Linphone

Item {
	id: mainItem
	property alias titleContent : titleLayout.children
	property alias centerContent : centerLayout.children

	ColumnLayout {
		anchors.rightMargin: 30
		anchors.leftMargin: 80
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: bottomMountains.top
		spacing: 20
		ColumnLayout {
			Layout.fillWidth: true
			Layout.preferredHeight: 50
			Layout.topMargin: 18
			Layout.alignment: Qt.AlignRight | Qt.AlignTop
			Control.Button {
				Layout.alignment: Qt.AlignRight
				Layout.bottomMargin: 20
				background: Rectangle {
					color: "transparent"
				}
				contentItem: RowLayout {
					Image {
						fillMode: Image.PreserveAspectFit
						source: AppIcons.info
					}
					Text {
						Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
						text: "About"
						font.pixelSize: 12
						color: DefaultStyle.aboutButtonTextColor
					}
				}
				onClicked: console.debug("[LoginLayout]User: open about popup")
			}
				
		}

		RowLayout {
			id: titleLayout
			Layout.bottomMargin: 20
		}
		ColumnLayout {
			id: centerLayout
			Layout.fillHeight: true
		}
		
	}

	RowLayout {
		id: bottomMountains
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		Image {
			Layout.minimumHeight: 50
			Layout.preferredHeight: 80
			Layout.fillWidth: true
			source: AppIcons.belledonne
			fillMode: Image.Stretch
		}

	}
} 
 
