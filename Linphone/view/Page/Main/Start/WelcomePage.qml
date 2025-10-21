import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

LoginLayout {
	id: mainItem
	signal startButtonPressed()

	titleContent: [
		Text {
			id: welcome
            //: "Bienvenue"
            text: qsTr("welcome_page_title")
			Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: Utils.getSizeWithScreenRatio(132)
			color: DefaultStyle.main2_800
			font {
                pixelSize: Utils.getSizeWithScreenRatio(96)
                weight: Typography.h4.weight
            }
			scaleLettersFactor: 1.1
		},
		Text {
			Layout.alignment: Qt.AlignBottom
            Layout.leftMargin: Utils.getSizeWithScreenRatio(29)
            Layout.bottomMargin: Utils.getSizeWithScreenRatio(19)
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
            Layout.rightMargin: Utils.getSizeWithScreenRatio(50)
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
        spacing: Utils.getSizeWithScreenRatio(76)
		anchors.left: parent.left
		anchors.top: parent.top
        anchors.leftMargin: Utils.getSizeWithScreenRatio(308)
        anchors.topMargin: Utils.getSizeWithScreenRatio(166)

		RowLayout {
			id: carouselLayout
            spacing: Utils.getSizeWithScreenRatio(76)
			Image {
				id: carouselImg
                // Layout.rightMargin: Utils.getSizeWithScreenRatio(40)
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(153)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(156)
				fillMode: Image.PreserveAspectFit
				source: carousel.currentIndex == 0 ? AppIcons.welcomeLinphoneLogo : carousel.currentIndex == 1 ? AppIcons.welcomeLock : AppIcons.welcomeOpenSource
			}
			Carousel {
				id: carousel
                Layout.leftMargin: Utils.getSizeWithScreenRatio(76)
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
                        spacing: Utils.getSizeWithScreenRatio(10)
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
                            Layout.maximumWidth: Utils.getSizeWithScreenRatio(361)
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
            Layout.leftMargin: Utils.getSizeWithScreenRatio(509)
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
 
