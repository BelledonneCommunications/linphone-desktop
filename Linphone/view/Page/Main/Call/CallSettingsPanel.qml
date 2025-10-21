import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Control.Page {
	id: mainItem
	property alias headerStack: headerStack
	property alias contentLoader: contentLoader
	property alias customHeaderButtons: customButtonLayout.children
	property int contentItemHeight: scrollview.height
	property bool closeButtonVisible: true
	property Item firstContentFocusableItem: undefined
	property Item lastContentFocusableItem: undefined
	clip: true

	property string headerTitleText
	property string headerSubtitleText
	property string headerValidateButtonText
	signal returnRequested()
	signal validateRequested()

    topPadding: Utils.getSizeWithScreenRatio(20)
    bottomPadding: Utils.getSizeWithScreenRatio(20)
    leftPadding: Utils.getSizeWithScreenRatio(17)
    rightPadding: Utils.getSizeWithScreenRatio(5)

	background: Rectangle {
		width: mainItem.width
		height: mainItem.height
		color: DefaultStyle.grey_100
        radius: Utils.getSizeWithScreenRatio(15)
	}
	
	header: Control.Control {
		id: pageHeader
		width: mainItem.width
        height: Utils.getSizeWithScreenRatio(67)
        leftPadding: Utils.getSizeWithScreenRatio(10)
        rightPadding: Utils.getSizeWithScreenRatio(10)
		background: Rectangle {
			id: headerBackground
			width: pageHeader.width
			height: pageHeader.height
			color: DefaultStyle.grey_0
            radius: Utils.getSizeWithScreenRatio(15)
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
                spacing: Utils.getSizeWithScreenRatio(10)
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
					//: Close %1 panel
					Accessible.name: qsTr("close_name_panel_accessible_button").arg(mainItem.headerTitleText)
					KeyNavigation.tab : firstContentFocusableItem ?? nextItemInFocusChain()
				}
			}
			RowLayout {
				Layout.alignment: Qt.AlignVCenter
                spacing: Utils.getSizeWithScreenRatio(10)
				Button {
					style: ButtonStyle.noBackgroundOrange
					icon.source: AppIcons.leftArrow
                    icon.width: Utils.getSizeWithScreenRatio(24)
                    icon.height: Utils.getSizeWithScreenRatio(24)
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
						color: DefaultStyle.main2_500_main
						font {
                            pixelSize: Utils.getSizeWithScreenRatio(12)
                            weight: Utils.getSizeWithScreenRatio(300)
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
	contentItem: Control.ScrollView {
		id: scrollview
		width: mainItem.width - mainItem.leftPadding - mainItem.rightPadding
		height: mainItem.height - mainItem.topPadding - mainItem.bottomPadding
		Control.ScrollBar.vertical: ScrollBar {
			id: scrollbar
			anchors.right: scrollview.right
			anchors.top: scrollview.top
			anchors.bottom: scrollview.bottom
			visible: contentControl.height > scrollview.height
		}
	    Control.ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
		Control.Control {
			id: contentControl
			rightPadding: scrollbar.width + Utils.getSizeWithScreenRatio(10)
			anchors.left: scrollview.left
			anchors.right: scrollview.right
			width: scrollview.width
			// parent: scrollview
			padding: 0
			contentItem: Loader {
				id: contentLoader
				width: contentControl.width - contentControl.rightPadding
			}
		}
	}
}
