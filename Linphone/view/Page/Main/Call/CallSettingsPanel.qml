import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Control.Page {
	id: mainItem
	property alias headerStack: headerStack
	property alias contentStackView: contentStackView
	property alias customHeaderButtons: customButtonLayout.children
	property bool closeButtonVisible: true
	clip: true

	property string headerTitleText
	property string headerSubtitleText
	property string headerValidateButtonText
	signal returnRequested()
	signal validateRequested()

    topPadding: Math.round(20 * DefaultStyle.dp)
    leftPadding: Math.round(17 * DefaultStyle.dp)
    rightPadding: Math.round(17 * DefaultStyle.dp)

	background: Rectangle {
		width: mainItem.width
		height: mainItem.height
		color: DefaultStyle.grey_100
        radius: Math.round(15 * DefaultStyle.dp)
	}
	
	header: Control.Control {
		id: pageHeader
		width: mainItem.width
        height: Math.round(67 * DefaultStyle.dp)
        leftPadding: Math.round(10 * DefaultStyle.dp)
        rightPadding: Math.round(10 * DefaultStyle.dp)
		background: Rectangle {
			id: headerBackground
			width: pageHeader.width
			height: pageHeader.height
			color: DefaultStyle.grey_0
            radius: Math.round(15 * DefaultStyle.dp)
			Rectangle {
				y: pageHeader.height/2
				height: pageHeader.height/2
				width: pageHeader.width
			}
		}
		contentItem: StackLayout {
			id: headerStack
			RowLayout {
				Layout.alignment: Qt.AlignVCenter
                spacing: Math.round(10 * DefaultStyle.dp)
				Text {
					text: mainItem.headerTitleText
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.alignment: Qt.AlignVCenter
					elide: Text.ElideRight
					maximumLineCount: 1
					verticalAlignment: Text.AlignVCenter
					color: DefaultStyle.main1_500_main
					font {
                        pixelSize: Typography.h4.pixelSize
                        weight: Typography.h4.weight
					}
				}
				RowLayout {
					id: customButtonLayout
				}
				RoundButton {
					id: closeButton
					visible: mainItem.closeButtonVisible
					style: ButtonStyle.noBackground
					icon.source: AppIcons.closeX
					onClicked: mainItem.visible = false
				}
			}
			RowLayout {
				Layout.alignment: Qt.AlignVCenter
                spacing: Math.round(10 * DefaultStyle.dp)
				Button {
					style: ButtonStyle.noBackgroundOrange
					icon.source: AppIcons.leftArrow
                    icon.width: Math.round(24 * DefaultStyle.dp)
                    icon.height: Math.round(24 * DefaultStyle.dp)
					onClicked: mainItem.returnRequested()
				}
				ColumnLayout {
					spacing: 0
					Text {
						Layout.alignment: Qt.AlignVCenter
						verticalAlignment: Text.AlignVCenter
						text: mainItem.headerTitleText
						color: DefaultStyle.main1_500_main
						font {
                            pixelSize: Typography.h4.pixelSize
                            weight: Typography.h4.weight
						}
					}
					Text {
					Layout.alignment: Qt.AlignVCenter
					verticalAlignment: Text.AlignVCenter

						text: mainItem.headerSubtitleText
						color: DefaultStyle.main2_500main
						font {
                            pixelSize: Math.round(12 * DefaultStyle.dp)
                            weight: Math.round(300 * DefaultStyle.dp)
						}
					}
				}
				Item {
					Layout.fillWidth: true
					Layout.fillHeight: true
				}
				SmallButton {
					style: ButtonStyle.main
					text: mainItem.headerValidateButtonText
					onClicked: mainItem.validateRequested()
				}
			}
		}
	}
	contentItem: Control.StackView {
		id: contentStackView
	}
}
