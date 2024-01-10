import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control

import Linphone

LoginLayout {
	id: mainItem
	signal startButtonPressed()

	titleContent: RowLayout {
		Text {
			id: welcome
			text: qsTr("Bienvenue")
			color: DefaultStyle.main2_800
			font {
				pixelSize: 96 * DefaultStyle.dp
				weight: 800 * DefaultStyle.dp
			}
			scaleLettersFactor: 1.1
		}
		Text {
			Layout.alignment: Qt.AlignBottom
			Layout.leftMargin: 10 * DefaultStyle.dp
			Layout.bottomMargin: 5 * DefaultStyle.dp
			color: DefaultStyle.main2_800
			text: qsTr("sur Linphone")
			font {
				pixelSize: 36 * DefaultStyle.dp
				weight: 800 * DefaultStyle.dp
			}
			scaleLettersFactor: 1.1
		}
		Item {
			Layout.fillWidth: true
		}
		Button {
			visible: carousel.currentIndex < (carousel.itemsCount - 1)
			flat: true
			background: Item {
				visible: false
			}
			contentItem: Text {
				text: qsTr("Passer")
				font {
					underline: true
					pixelSize: 13 * DefaultStyle.dp
					weight: 600 * DefaultStyle.dp
				}
			}
			onClicked: {
				console.debug("[WelcomePage] User: Click skip")
				mainItem.startButtonPressed()
			}
		}
	}
	centerContent: Item {
		id: centerLayout
		Layout.bottomMargin: 20 * DefaultStyle.dp
		Layout.fillWidth: false
		Layout.fillHeight: false
		Layout.leftMargin: 250 * DefaultStyle.dp
		Layout.topMargin: 165 * DefaultStyle.dp
		RowLayout {
			id: carouselLayout
			Image {
				id: carouselImg
				Layout.rightMargin: 40 * DefaultStyle.dp
				Layout.preferredWidth: 153.22 * DefaultStyle.dp
				Layout.preferredHeight: 156 * DefaultStyle.dp
				fillMode: Image.PreserveAspectFit
				source: carousel.currentIndex == 0 ? AppIcons.welcomeLinphoneLogo : carousel.currentIndex == 1 ? AppIcons.welcomeLock : AppIcons.welcomeOpenSource
			}
			Carousel {
				id: carousel
				itemsCount: slideRepeater.count
				itemsList: Repeater {
					id: slideRepeater
					model: [
					{title: qsTr("Linphone"), text: qsTr("Une application de communication <b>sécurisée</b>,<br> <b>open source</b> et <b>française</b>.")},
					{title: qsTr("Sécurisé"), text: qsTr("Vos communications sont en sécurité grâce aux <br><b>Chiffrement de bout en bout</b>.")},
					{title: qsTr("Open Source"), text: qsTr("Une application open source et un <b>service gratuit</b> <br>depuis <b>2001</b>")},
					]
					ColumnLayout {
						spacing: 15 * DefaultStyle.dp
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

		Button {
			anchors.top: carouselLayout.bottom
			anchors.right: carouselLayout.right
			anchors.topMargin: 20 * DefaultStyle.dp
			anchors.bottomMargin: 20 * DefaultStyle.dp
			anchors.leftMargin: (centerLayout.width - width) * DefaultStyle.dp
			y: centerLayout.implicitWidth - width
			text: carousel.currentIndex < (carousel.itemsCount - 1) ? qsTr("Suivant") : qsTr("Commencer")
			onClicked: { 
				if (carousel.currentIndex < 2) carousel.goToSlide(carousel.currentIndex + 1);
				else mainItem.startButtonPressed();
			}
		}
	}
} 
 
