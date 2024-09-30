import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone

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

	topPadding: 16 * DefaultStyle.dp
	// bottomPadding: 16 * DefaultStyle.dp

	background: Rectangle {
		width: mainItem.width
		height: mainItem.height
		color: DefaultStyle.grey_100
		radius: 15 * DefaultStyle.dp
	}
	
	header: Control.Control {
		id: pageHeader
		width: mainItem.width
		height: 56 * DefaultStyle.dp
		leftPadding: 10 * DefaultStyle.dp
		rightPadding: 10 * DefaultStyle.dp
		background: Rectangle {
			id: headerBackground
			width: pageHeader.width
			height: pageHeader.height
			color: DefaultStyle.grey_0
			radius: 15 * DefaultStyle.dp
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
				spacing: 10 * DefaultStyle.dp
				Text {
					text: mainItem.headerTitleText
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.alignment: Qt.AlignVCenter
					verticalAlignment: Text.AlignVCenter
					color: DefaultStyle.main1_500_main
					font {
						pixelSize: 16 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
					}
				}
				RowLayout {
					id: customButtonLayout
				}
				Button {
					id: closeButton
					visible: mainItem.closeButtonVisible
					background: Item {
						visible: false
					}
					icon.source: AppIcons.closeX
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
					icon.width: 24 * DefaultStyle.dp
					icon.height: 24 * DefaultStyle.dp
					onClicked: mainItem.visible = false
				}
			}
			RowLayout {
				Layout.alignment: Qt.AlignVCenter
				spacing: 10 * DefaultStyle.dp
				Button {
					background: Item{}
					icon.source: AppIcons.leftArrow
					icon.width: 24 * DefaultStyle.dp
					icon.height: 24 * DefaultStyle.dp
					contentImageColor: DefaultStyle.main1_500_main
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
							pixelSize: 16 * DefaultStyle.dp
							weight: 800 * DefaultStyle.dp
						}
					}
					Text {
					Layout.alignment: Qt.AlignVCenter
					verticalAlignment: Text.AlignVCenter

						text: mainItem.headerSubtitleText
						color: DefaultStyle.main2_500main
						font {
							pixelSize: 12 * DefaultStyle.dp
							weight: 300 * DefaultStyle.dp
						}
					}
				}
				Item {
					Layout.fillWidth: true
					Layout.fillHeight: true
				}
				Button {
					text: mainItem.headerValidateButtonText
					textSize: 13 * DefaultStyle.dp
					textWeight: 600 * DefaultStyle.dp
					onClicked: mainItem.validateRequested()
					topPadding: 6 * DefaultStyle.dp
					bottomPadding: 6 * DefaultStyle.dp
					leftPadding: 12 * DefaultStyle.dp
					rightPadding: 12 * DefaultStyle.dp
				}
			}
		}
	}
	contentItem: Control.StackView {
		id: contentStackView
	}
}
