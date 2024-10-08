/**
* Qml template used for welcome and login/register pages
**/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone

Rectangle {
	id: mainItem
	property alias titleContent : titleLayout.children
	property alias centerContent : centerLayout.children
	color: DefaultStyle.grey_0
	ColumnLayout {
		// anchors.leftMargin: 119 * DefaultStyle.dp
		id: contentLayout
		// anchors.top: parent.top
		// anchors.left: parent.left
		// anchors.right: parent.right
		anchors.fill: parent
		// anchors.bottom: bottomMountains.top
		spacing: 0
		RowLayout {
			Layout.fillWidth: true
			Layout.preferredHeight: 102 * DefaultStyle.dp
			Layout.rightMargin: 42 * DefaultStyle.dp
			spacing: 0
			Item {
				Layout.fillWidth: true
			}
			Button {
				id: aboutButton
				Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
				background: Item{}
				contentItem: RowLayout {
					spacing: 8 * DefaultStyle.dp
					Image {
						fillMode: Image.PreserveAspectFit
						source: AppIcons.info
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
					}
					Text {
						Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
						text: qsTr("À propos")
						font {
							underline: aboutButton.underline
							pixelSize: 14 * DefaultStyle.dp
							weight: 400 * DefaultStyle.dp
						}
						color: DefaultStyle.main2_500main
					}
				}
				onClicked: console.debug("[LoginLayout]User: open about popup")
			}
		}

		RowLayout {
			id: titleLayout
			Layout.preferredHeight: 131 * DefaultStyle.dp
			Layout.fillWidth: true
			spacing: 0
		}
		Item {
			id: centerLayout
			Layout.fillHeight: true
			Layout.fillWidth: true
		}
		Image {
			id: bottomMountains
			z: -1
			source: AppIcons.belledonne
			fillMode: Image.Stretch
			Layout.fillWidth: true
			Layout.preferredHeight: 108 * DefaultStyle.dp
		}
	}

} 
 
