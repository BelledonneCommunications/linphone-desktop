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
		anchors.fill: parent
		Layout.fillHeight: true
		ColumnLayout {
			Layout.rightMargin: 25
			RowLayout {
				Layout.fillWidth: true
				Layout.preferredHeight: 50
				Layout.topMargin: 20
				Layout.bottomMargin: 20
				Layout.alignment: Qt.AlignRight | Qt.AlignTop
				Control.Button {
					background: Rectangle {
						color: "transparent"
					}
					contentItem: Image {
						fillMode: Image.PreserveAspectFit
						source: AppIcons.info
					}
					onClicked: console.debug("[LoginLayout] User: open about popup")
				}

				Text {
					Layout.alignment: Qt.AlignRight |Qt.AlignVCenter
					text: "About"
					font.pixelSize: 12
					color: DefaultStyle.grayColor
				}
			}
			RowLayout {
				id: titleLayout
				Layout.leftMargin: 40
				Layout.bottomMargin: 20
			}
			ColumnLayout {
				id: centerLayout
				Layout.leftMargin: 40
				Layout.fillHeight: true
				Layout.topMargin: 20
			}
		}
		
		RowLayout {
			Layout.alignment: Qt.AlignBottom
			Image {
				Layout.minimumHeight: 80
				Layout.fillWidth: true
				source: AppIcons.belledonne
				fillMode: Image.Stretch
			}

		}
	}
} 
 
