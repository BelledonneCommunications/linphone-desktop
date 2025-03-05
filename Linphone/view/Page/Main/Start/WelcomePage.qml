import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

LoginLayout {
	id: mainItem
	signal startButtonPressed()

	titleContent: [
		Text {
			id: welcome
            //: "Bienvenue"
            text: qsTr("welcome_page_title")
			Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: Math.round(132 * DefaultStyle.dp)
			color: DefaultStyle.main2_800
			font {
                pixelSize: Math.round(96 * DefaultStyle.dp)
                weight: Typography.h4.weight
            }
			scaleLettersFactor: 1.1
		},
		Text {
			Layout.alignment: Qt.AlignBottom
            Layout.leftMargin: Math.round(29 * DefaultStyle.dp)
            Layout.bottomMargin: Math.round(19 * DefaultStyle.dp)
			color: DefaultStyle.main2_800
            //: "sur %1"
            text: qsTr("welcome_page_subtitle").arg(applicationName)
			font {
                pixelSize: Typography.h1.pixelSize
                weight: Typography.h1.weight
			}
			scaleLettersFactor: 1.1
		},
		Item {
			Layout.fillWidth: true
		},
		SmallButton {
			visible: carousel.currentIndex < (carousel.itemsCount - 1)
			flat: true
            Layout.rightMargin: Math.round(50 * DefaultStyle.dp)
			Layout.alignment: Qt.AlignVCenter | Layout.AlignRight
			style: ButtonStyle.noBackground
            //: "Passer"
            text: qsTr("welcome_carousel_skip")
			underline: true
			onClicked: {
				console.debug("[WelcomePage] User: Click skip")
				mainItem.startButtonPressed()
			}
		}
	]
	centerContent: ColumnLayout {
        spacing: Math.round(76 * DefaultStyle.dp)
		anchors.left: parent.left
		anchors.top: parent.top
        anchors.leftMargin: Math.round(308 * DefaultStyle.dp)
        anchors.topMargin: Math.round(166 * DefaultStyle.dp)

		RowLayout {
			id: carouselLayout
            spacing: Math.round(76 * DefaultStyle.dp)
			Image {
				id: carouselImg
                // Layout.rightMargin: Math.round(40 * DefaultStyle.dp)
                Layout.preferredWidth: Math.round(153.22 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(155.9 * DefaultStyle.dp)
				fillMode: Image.PreserveAspectFit
				source: carousel.currentIndex == 0 ? AppIcons.welcomeLinphoneLogo : carousel.currentIndex == 1 ? AppIcons.welcomeLock : AppIcons.welcomeOpenSource
			}
			Carousel {
				id: carousel
                Layout.leftMargin: Math.round(75.78 * DefaultStyle.dp)
				itemsCount: slideRepeater.count
				itemsList: Repeater {
					id: slideRepeater
					model: [
                        //: "Une application de communication <b>sécurisée</b>,<br> <b>open source</b> et <b>française</b>."
                    {title: applicationName, text: qsTr("welcome_page_1_message")},
                        //: "Sécurisé"
                    {title: qsTr("welcome_page_2_title"),
                            //: "Vos communications sont en sécurité grâce aux <br><b>Chiffrement de bout en bout</b>."
                            text: qsTr("welcome_page_2_message")},
                        //: "Open Source"
                    {title: qsTr("welcome_page_3_title"),
                            //: "Une application open source et un <b>service gratuit</b> <br>depuis <b>2001</b>"
                            text: qsTr("welcome_page_3_message")}
					]
					ColumnLayout {
                        spacing: Math.round(10 * DefaultStyle.dp)
						Text {
							id: title
							text: modelData.title
							font {
                                pixelSize: Typography.h2.pixelSize
                                weight: Typography.h2.weight
							}
						}
						Text {
							id: txt
                            Layout.maximumWidth: Math.round(361 * DefaultStyle.dp)
                            wrapMode: Text.WordWrap
                            font {
                                pixelSize: Typography.p1.pixelSize
                                weight: Typography.p1.weight
                            }
							text: modelData.text
						}
					}
				}
			}
		}

		BigButton {
            Layout.leftMargin: Math.round(509 * DefaultStyle.dp)
            style: ButtonStyle.main
            //: "Suivant"
            text: carousel.currentIndex < (carousel.itemsCount - 1) ? qsTr("next")
                                                                      //: "Commencer"
                                                                    : qsTr("start")
			onClicked: {
				if (carousel.currentIndex < carousel.itemsCount - 1) carousel.goToSlide(carousel.currentIndex + 1);
				else mainItem.startButtonPressed();
			}
		}
	}
} 
 
