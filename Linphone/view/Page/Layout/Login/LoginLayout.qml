/**
* Qml template used for welcome and login/register pages
**/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import ConstantsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Rectangle {
	id: mainItem
	property alias titleContent : titleLayout.children
	property alias centerContent : centerLayout.children
	color: DefaultStyle.grey_0

	component AboutLine: RowLayout {
		id: line
        spacing: Math.round(20 * DefaultStyle.dp)
		property var imageSource
		property string title
		property string text
		property bool enableMouseArea: false
		signal contentClicked()
		EffectImage {
            Layout.preferredWidth: Math.round(32 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(32 * DefaultStyle.dp)
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
                    pixelSize: Typography.b2.pixelSize
                    weight: Typography.b2.weight
				}
				horizontalAlignment: Layout.AlignLeft
			}
			Text {
				id: content
				Layout.fillWidth: true
				text: line.text
				color: DefaultStyle.main2_500main
                font.pixelSize: Math.round(14 * DefaultStyle.dp)
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
        width: Math.round(637 * DefaultStyle.dp)
        //: À propos de %1
        title: qsTr("help_about_title").arg(applicationName)
        bottomPadding: Math.round(10 * DefaultStyle.dp)
		buttons: []
		content: RowLayout {
			ColumnLayout {
                spacing: Math.round(17 * DefaultStyle.dp)
				Layout.alignment: Qt.AlignTop | Qt.AlignLeft
				AboutLine {
					imageSource: AppIcons.detective
                    //: "Politique de confidentialité"
                    title: qsTr("help_about_privacy_policy_title")
                    //: "Visiter notre potilique de confidentialité"
                    text: qsTr("help_about_privacy_policy_link")
					enableMouseArea: true
					onContentClicked: Qt.openUrlExternally(ConstantsCpp.PrivatePolicyUrl)
				}
				AboutLine {
					imageSource: AppIcons.info
                    //: "Version"
                    title: qsTr("help_about_version_title")
					text: Qt.application.version
				}
				AboutLine {
					imageSource: AppIcons.checkSquareOffset
                    //: "Licence"
                    title: qsTr("help_about_licence_title")
					text: applicationLicence
				}
				AboutLine {
					imageSource: AppIcons.copyright
                    //: "Copyright
                    title: qsTr("help_about_copyright_title")
					text: applicationVendor
				}
				Item {
					// Item to shift close button
                    Layout.preferredHeight: Math.round(10 * DefaultStyle.dp)
				}
			}
			MediumButton {
				Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                //: "Fermer"
                text: qsTr("close")
				style: ButtonStyle.main
				onClicked: aboutPopup.close()
			}
		}
	}

	ColumnLayout {
		anchors.fill: parent
        spacing: 0
        RowLayout {
			Layout.fillWidth: true
            Layout.topMargin: Math.round(Math.max(5 * DefaultStyle.dp,(25 - ((25/(DefaultStyle.defaultHeight - mainWindow.minimumHeight))*(DefaultStyle.defaultHeight-mainWindow.height))) * DefaultStyle.dp))
            Layout.rightMargin: Math.round(Math.max(5 * DefaultStyle.dp,(42 - ((42/(DefaultStyle.defaultWidth - mainWindow.minimumWidth))*(DefaultStyle.defaultWidth-mainWindow.width))) * DefaultStyle.dp))
			spacing: 0
			Item {
				Layout.fillWidth: true
			}
			BigButton {
				id: aboutButton
				Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
				icon.source: AppIcons.info
                text: qsTr("help_about_title").arg(applicationName)
				textSize: Typography.p1.pixelSize
				textWeight: Typography.p1.weight
				textColor: DefaultStyle.main2_500main
				onClicked: aboutPopup.open()
				style: ButtonStyle.noBackground
			}
		}

		RowLayout {
			id: titleLayout
			Layout.fillWidth: true
            Layout.topMargin: Math.round(Math.max(10 * DefaultStyle.dp,(40 - ((40/(DefaultStyle.defaultHeight - mainWindow.minimumHeight))*(DefaultStyle.defaultHeight-mainWindow.height))) * DefaultStyle.dp))
			spacing: 0
		}
		Item {
			id: centerLayout
			Layout.fillHeight: true
			Layout.fillWidth: true
            Layout.topMargin: Math.round(Math.max(15 * DefaultStyle.dp,(70 - ((70/(DefaultStyle.defaultHeight - mainWindow.minimumHeight))*(DefaultStyle.defaultHeight-mainWindow.height))) * DefaultStyle.dp))
            Layout.alignment: Qt.AlignBottom

		}
		Image {
			id: bottomMountains
			source: AppIcons.belledonne
			fillMode: Image.Stretch
			Layout.fillWidth: true
            Layout.preferredHeight: Math.round(108 * DefaultStyle.dp)
		}
	}

} 
 
