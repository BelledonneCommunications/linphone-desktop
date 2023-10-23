import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control

import Linphone

LoginLayout {
	id: welcomePage
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
			font.pointSize: 18
			font.bold: true
			scaleLettersFactor: 1.1
		}
		Item {
			Layout.fillWidth: true
		}
		Control.Button {
			leftPadding: 13
			rightPadding: 13
			topPadding: 20
			bottomPadding: 20
			flat: true
			checkable: false
			background: Rectangle {
				color: "transparent"
				radius: 48
			}
			contentItem: Text {
				text: "Skip"
				font.underline: true
				color: DefaultStyle.defaultTextColor
			}
			onClicked: welcomePage.startButtonPressed();
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
				itemsList: [carousel0, carousel1, carousel2]
				Component {
					id: carousel0
					Item {
						ColumnLayout {
							anchors.verticalCenter: parent.verticalCenter
							Text {
								text: "Linphone"
								font.bold: true
								font.pixelSize: 20
								color: DefaultStyle.defaultTextColor
								scaleLettersFactor: 1.1
							}
							Text {
								Layout.maximumWidth: 361
								wrapMode: Text.WordWrap
								font.pixelSize: 11
								color: DefaultStyle.defaultTextColor
								text: "Une application de communication <b>sécurisée</b>,<br> <b>open source</b> et <b>française</b>. "
							}
						}
					}
				}
				Component {
					id: carousel1
					Item {
						ColumnLayout {
							anchors.verticalCenter: parent.verticalCenter
							Text {
								text: "Sécurisé"
								font.bold: true
								font.pixelSize: 20
								color: DefaultStyle.defaultTextColor
							}
							Text {
								Layout.maximumWidth: 361
								wrapMode: Text.WordWrap
								font.pixelSize: 11
								color: DefaultStyle.defaultTextColor
								text: "Vos communications sont en sécurité grâce aux <br><b>Chiffrement de bout en bout</b>."
							}
						}
					}
				}
				Component {
					id: carousel2
					Item {
						ColumnLayout {
							anchors.verticalCenter: parent.verticalCenter
							Text {
								text: "Open Source"
								font.bold: true
								font.pixelSize: 20
								color: DefaultStyle.defaultTextColor
							}
							Text {
								Layout.maximumWidth: 361
								wrapMode: Text.WordWrap
								font.pixelSize: 11
								color: DefaultStyle.defaultTextColor
								text: "Une application open source et un <b>service gratuit</b> depuis <b>2001</b>"
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
			text: carousel.currentIndex < (carousel.itemsList.length - 1) ? "Next" : "Start"
			onClicked: { 
				if (carousel.currentIndex < 2) carousel.goToSlide(carousel.currentIndex + 1);
				else welcomePage.startButtonPressed();
			}
		}
		Item {
			Layout.fillHeight: true
		}
	}
} 
 
