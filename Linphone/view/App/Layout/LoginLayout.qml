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
		anchors.rightMargin: 40 * DefaultStyle.dp
		anchors.leftMargin: 119 * DefaultStyle.dp
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: bottomMountains.top
		spacing: 3 * DefaultStyle.dp
		RowLayout {
			Layout.fillWidth: true
			Layout.preferredHeight: 102 * DefaultStyle.dp
			Layout.maximumHeight: 102 * DefaultStyle.dp
			// Layout.topMargin: 18
			// Layout.alignment: Qt.AlignRight | Qt.AlignTop
			Item {
				Layout.fillWidth: true
			}
			Button {
				Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
				// Layout.bottomMargin: 20
				background: Rectangle {
					color: "transparent"
				}
				contentItem: RowLayout {
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
			// Layout.bottomMargin: 20
		}
		ColumnLayout {
			id: centerLayout
		}
		Item {
			Layout.fillHeight: true
			Layout.fillWidth: true
		}
	}

	RowLayout {
		id: bottomMountains
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		Image {
			Layout.minimumHeight: 50 * DefaultStyle.dp
			Layout.preferredHeight: 80 * DefaultStyle.dp
			Layout.fillWidth: true
			source: AppIcons.belledonne
			fillMode: Image.Stretch
		}

	}
} 
 
