/**
* Qml template used for welcome and login/register pages
**/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import ConstantsCpp

Rectangle {
	id: mainItem
	property alias titleContent : titleLayout.children
	property alias centerContent : centerLayout.children
	color: DefaultStyle.grey_0

	component AboutLine: RowLayout {
		id: line
		spacing: 20 * DefaultStyle.dp
		property var imageSource
		property string title
		property string text
		property bool enableMouseArea: false
		signal contentClicked()
		EffectImage {
			Layout.preferredWidth: 32 * DefaultStyle.dp
			Layout.preferredHeight: 32 * DefaultStyle.dp
			imageSource: parent.imageSource
			colorizationColor: DefaultStyle.main1_500_main
		}
		ColumnLayout {
			spacing: 0
			Text {
				Layout.fillWidth: true
				text: line.title
				color: DefaultStyle.main2_600
				font {
					pixelSize: 15 * DefaultStyle.dp
					weight: 600 * DefaultStyle.dp
				}
				horizontalAlignment: Layout.AlignLeft
			}
			Text {
				id: content
				Layout.fillWidth: true
				text: line.text
				color: DefaultStyle.main2_500main
				font.pixelSize: 14 * DefaultStyle.dp
				horizontalAlignment: Layout.AlignLeft
				Keys.onPressed: (event)=> {
					if (event.key == Qt.Key_Space || event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
						line.contentClicked(undefined)
						event.accepted = true;
					}
				}
				MouseArea {
					id: privateMouseArea
					enabled: line.enableMouseArea
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
					onClicked: line.contentClicked()
				}
			}
		}
		// Item {Layout.fillWidth: true}
	}

	Dialog {
		id: aboutPopup
		anchors.centerIn: parent
		width: 637 * DefaultStyle.dp
		title: qsTr("À propos de Linphone")
		bottomPadding: 10 * DefaultStyle.dp
		buttons: []
		content: RowLayout {
			ColumnLayout {
				spacing: 17 * DefaultStyle.dp
				Layout.alignment: Qt.AlignTop | Qt.AlignLeft
				AboutLine {
					imageSource: AppIcons.detective
					title: qsTr("Politique de confidentialité")
					text: qsTr("Visiter notre potilique de confidentialité")
					enableMouseArea: true
					onContentClicked: Qt.openUrlExternally(ConstantsCpp.PrivatePolicyUrl)
				}
				AboutLine {
					imageSource: AppIcons.info
					title: qsTr("Version")
					text: Qt.application.version
				}
				AboutLine {
					imageSource: AppIcons.checkSquareOffset
					title: qsTr("Licence")
					text: applicationLicence
				}
				AboutLine {
					imageSource: AppIcons.copyright
					title: qsTr("Copyright")
					text: applicationVendor
				}
				Item {
					// Item to shift close button
					Layout.preferredHeight: 10 * DefaultStyle.dp
				}
			}
			MediumButton {
				Layout.alignment: Qt.AlignRight | Qt.AlignBottom
				text: qsTr("Fermer")
				style: ButtonStyle.main
				onClicked: aboutPopup.close()
			}
		}
	}

	ColumnLayout {
		id: contentLayout
		anchors.fill: parent
		spacing: 0
		RowLayout {
			Layout.fillWidth: true
			Layout.preferredHeight: 102 * DefaultStyle.dp
			Layout.rightMargin: 42 * DefaultStyle.dp
			spacing: 0
			Item {
				Layout.fillWidth: true
			}
			BigButton {
				id: aboutButton
				Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
				icon.source: AppIcons.info
				text: qsTr("À propos")
				textSize: Typography.p1.pixelSize
				textWeight: Typography.p1.weight
				textColor: DefaultStyle.main2_500main
				onClicked: aboutPopup.open()
				style: ButtonStyle.noBackground
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
			source: AppIcons.belledonne
			fillMode: Image.Stretch
			Layout.fillWidth: true
			Layout.preferredHeight: 108 * DefaultStyle.dp
		}
	}

} 
 
