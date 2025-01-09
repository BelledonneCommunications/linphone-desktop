import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone

LoginLayout {
	id: mainItem
	signal startButtonPressed()

	titleContent: [
		Text {
			id: welcome
			text: qsTr("Bienvenue")
			Layout.alignment: Qt.AlignVCenter
			Layout.leftMargin: 132 * DefaultStyle.dp
			color: DefaultStyle.main2_800
			font {
				pixelSize: 96 * DefaultStyle.dp
				weight: 800 * DefaultStyle.dp
			}
			scaleLettersFactor: 1.1
		},
		Text {
			Layout.alignment: Qt.AlignBottom
			Layout.leftMargin: 29 * DefaultStyle.dp
			Layout.bottomMargin: 19 * DefaultStyle.dp
			color: DefaultStyle.main2_800
			text: qsTr("sur Linphone")
			font {
				pixelSize: 36 * DefaultStyle.dp
				weight: 800 * DefaultStyle.dp
			}
			scaleLettersFactor: 1.1
		},
		Item {
			Layout.fillWidth: true
		},
		SmallButton {
			visible: carousel.currentIndex < (carousel.itemsCount - 1)
			flat: true
			Layout.rightMargin: 50 * DefaultStyle.dp
			Layout.alignment: Qt.AlignVCenter | Layout.AlignRight
			style: ButtonStyle.noBackground
			text: qsTr("Passer")
			underline: true
			onClicked: {
				console.debug("[WelcomePage] User: Click skip")
				mainItem.startButtonPressed()
			}
		}
	]
	centerContent: ColumnLayout {
		spacing: 76 * DefaultStyle.dp
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.leftMargin: 308 * DefaultStyle.dp
		anchors.topMargin: 166 * DefaultStyle.dp

		RowLayout {
			id: carouselLayout
			spacing: 76 * DefaultStyle.dp
			Image {
				id: carouselImg
				// Layout.rightMargin: 40 * DefaultStyle.dp
				Layout.preferredWidth: 153.22 * DefaultStyle.dp
				Layout.preferredHeight: 155.9 * DefaultStyle.dp
				fillMode: Image.PreserveAspectFit
				source: carousel.currentIndex == 0 ? AppIcons.welcomeLinphoneLogo : carousel.currentIndex == 1 ? AppIcons.welcomeLock : AppIcons.welcomeOpenSource
			}
			Carousel {
				id: carousel
				Layout.leftMargin: 75.78 * DefaultStyle.dp
				itemsCount: slideRepeater.count
				itemsList: Repeater {
					id: slideRepeater
					model: [
					{title: qsTr("Linphone"), text: qsTr("Une application de communication <b>sécurisée</b>,<br> <b>open source</b> et <b>française</b>.")},
					{title: qsTr("Sécurisé"), text: qsTr("Vos communications sont en sécurité grâce aux <br><b>Chiffrement de bout en bout</b>.")},
					{title: qsTr("Open Source"), text: qsTr("Une application open source et un <b>service gratuit</b> <br>depuis <b>2001</b>")}
					]
					ColumnLayout {
						spacing: 10 * DefaultStyle.dp
						Text {
							id: title
							text: modelData.title
							font {
								pixelSize: 29 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
							}
						}
						Text {
							id: txt
							Layout.maximumWidth: 361 * DefaultStyle.dp
							wrapMode: Text.WordWrap
							font.pixelSize: 14 * DefaultStyle.dp
							font.weight: 400 * DefaultStyle.dp
							text: modelData.text
						}
					}
				}
			}
		}

		BigButton {
			Layout.leftMargin: 509 * DefaultStyle.dp
			style: ButtonStyle.main
			text: carousel.currentIndex < (carousel.itemsCount - 1) ? qsTr("Suivant") : qsTr("Commencer")
			onClicked: {
				if (carousel.currentIndex < carousel.itemsCount - 1) carousel.goToSlide(carousel.currentIndex + 1);
				else mainItem.startButtonPressed();
			}
		}
	}
} 
 
