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
			text: "Welcome"
			color: DefaultStyle.titleColor
			font.pointSize: DefaultStyle.title1FontPointSize
			font.bold: true
			scaleLettersFactor: 1.1
		}
		Text {
			Layout.alignment: Qt.AlignBottom
			Layout.leftMargin: 10
			Layout.bottomMargin: 5
			color: DefaultStyle.titleColor
			text: "in Linphone"
			font.pointSize: DefaultStyle.title2FontPointSize
			font.bold: true
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
				text: "Skip"
				font.underline: true
			}
			onClicked: {
				console.debug("[LoginItem] User: Click skip")
				mainItem.startButtonPressed()
			}
		}
	}
	centerContent: ColumnLayout {
		Layout.bottomMargin: 20
		RowLayout {
			Layout.leftMargin: 100
			Image {
				Layout.rightMargin: 40
				Layout.topMargin: 20
				Layout.preferredWidth: 100
				Layout.maximumWidth: 100
				fillMode: Image.PreserveAspectFit
				source: carousel.currentIndex == 0 ? AppIcons.welcomeLinphoneLogo : carousel.currentIndex == 1 ? AppIcons.welcomeLock : AppIcons.welcomeOpenSource
			}
			Carousel {
				id: carousel
				itemsCount: slideRepeater.count
				itemsList: Repeater {
					id: slideRepeater
					model: [
						{title: "Linphone", text: "Une application de communication <b>sécurisée</b>,<br> <b>open source</b> et <b>française</b>."},
						{title: "Sécurisé", text: "Vos communications sont en sécurité grâce aux <br><b>Chiffrement de bout en bout</b>."},
						{title: "Open Source", text: "Une application open source et un <b>service gratuit</b> <br>depuis <b>2001</b>"},
						]
					Item {
						ColumnLayout {
							anchors.verticalCenter: parent.verticalCenter
							spacing: 15
							Text {
								text: modelData.title
								font.bold: true
								font.pixelSize: 20
								scaleLettersFactor: 1.1
							}
							Text {
								Layout.maximumWidth: 361
								wrapMode: Text.WordWrap
								font.pixelSize: 11
								text: modelData.text
							}
						}
					}
				}
			}
		}

		Button {
			Layout.topMargin: 20
			Layout.bottomMargin: 20
			Layout.leftMargin: 361 - width
			Layout.alignment: Qt.AlignBottom
			text: carousel.currentIndex < (carousel.itemsCount - 1) ? "Next" : "Start"
			onClicked: { 
				if (carousel.currentIndex < 2) carousel.goToSlide(carousel.currentIndex + 1);
				else mainItem.startButtonPressed();
			}
		}
		Item {
			Layout.fillHeight: true
		}
	}
} 
 
