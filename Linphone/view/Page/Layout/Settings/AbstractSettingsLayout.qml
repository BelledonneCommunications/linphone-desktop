
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone

Rectangle {
	id: mainItem
	width: container.width
	height: container.height
	property string titleText
	property var contentModel
	property var topbarOptionalComponent
	property var model
	color: 'white'
	property var container
	property int contentHeight: contentRepeater.count > 0 ? contentRepeater.itemAt(0).height * contentRepeater.count : 0
	property int minimumWidthForSwitchintToRowLayout: 981 * DefaultStyle.dp
	property var useVerticalLayout
	function setResponsivityFlags() {
		var newValue = width < minimumWidthForSwitchintToRowLayout * DefaultStyle.dp
		if (useVerticalLayout != newValue) {
			useVerticalLayout = newValue
		}
	}
	onWidthChanged: {
		setResponsivityFlags()
    }
	Component.onCompleted: {
			setResponsivityFlags()
	}
	Control.ScrollView {
		id: scrollView
		height: parent.height
		width: parent.width - 2 * 45 * DefaultStyle.dp
		anchors.centerIn: parent
		contentHeight: (contentRepeater.height + header.height) + 20 * DefaultStyle.dp
		contentWidth: parent.width - 2 * 45 * DefaultStyle.dp
		Control.ScrollBar.vertical: ScrollBar {
			active: scrollView.contentHeight > container.height
			visible: scrollView.contentHeight > container.height
			interactive: true
			policy: Control.ScrollBar.AsNeeded
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.right: parent.right
			anchors.rightMargin: -15 * DefaultStyle.dp
		}
		Control.ScrollBar.horizontal: ScrollBar {
			active: false
		}
		ColumnLayout {
			id: header
			width: parent.width
			spacing: 10 * DefaultStyle.dp
			RowLayout {
				Layout.fillWidth: true
				Layout.topMargin: 20 * DefaultStyle.dp
				spacing: 5 * DefaultStyle.dp
				Layout.bottomMargin: 10 * DefaultStyle.dp
				Button {
					id: backButton
					Layout.preferredHeight: 24 * DefaultStyle.dp
					Layout.preferredWidth: 24 * DefaultStyle.dp
					icon.source: AppIcons.leftArrow
					width: 24 * DefaultStyle.dp
					height: 24 * DefaultStyle.dp
					focus: true
					visible: mainItem.container.depth > 1
					Layout.rightMargin: 41 * DefaultStyle.dp
					onClicked: {
						mainItem.container.pop()
					}
					background: Item {
						anchors.fill: parent
					}
				}
				Text {
					text: titleText
					color: DefaultStyle.main2_600
					font: Typography.h3
				}
				Item {
					Layout.fillWidth: true
				}
				Loader {
					Layout.alignment: Qt.AlignRight
					sourceComponent: mainItem.topbarOptionalComponent
					Layout.rightMargin: 34 * DefaultStyle.dp
				}
			}
			Repeater {
				id: contentRepeater
				model: mainItem.contentModel
				delegate: ColumnLayout {
					Rectangle {
						Layout.topMargin: (modelData.hideTopSeparator ? 0 : 16) * DefaultStyle.dp
						Layout.bottomMargin: 16 * DefaultStyle.dp
						Layout.fillWidth: true
						height: 1 * DefaultStyle.dp
						color: modelData.hideTopSeparator ? 'transparent' : DefaultStyle.main2_500main
					}
					GridLayout {
						rows: 1
						columns: mainItem.useVerticalLayout ? 1 : 2
						Layout.fillWidth: true
						Layout.preferredWidth: parent.width
						rowSpacing: (modelData.title.length > 0 || modelData.subTitle.length > 0 ? 20 : 0) * DefaultStyle.dp
						columnSpacing: 47 * DefaultStyle.dp
						ColumnLayout {
							Layout.preferredWidth: 341 * DefaultStyle.dp
							Layout.maximumWidth: 341 * DefaultStyle.dp
							spacing: 3 * DefaultStyle.dp
							Text {
								text: modelData.title
								visible: modelData.title.length > 0
								font: Typography.h4
								wrapMode: Text.WordWrap
								color: DefaultStyle.main2_600
								Layout.preferredWidth: parent.width
							}
							Text {
								text: modelData.subTitle
								visible: modelData.subTitle.length > 0
								font: Typography.p1s
								wrapMode: Text.WordWrap
								color: DefaultStyle.main2_600
								Layout.preferredWidth: parent.width
							}
							Item {
								Layout.fillHeight: true
							}
						}
						RowLayout {
							Layout.topMargin: (modelData.hideTopMargin ? 0 : (mainItem.useVerticalLayout ? 10 : 21)) * DefaultStyle.dp
							Layout.bottomMargin: 21 * DefaultStyle.dp
							Layout.leftMargin: (mainItem.useVerticalLayout ? 0 : 17) * DefaultStyle.dp
							Layout.preferredWidth: (modelData.customWidth > 0 ? modelData.customWidth : 545) * DefaultStyle.dp
							Layout.alignment: Qt.AlignRight
							Loader {
								Layout.fillWidth: true
								sourceComponent: modelData.contentComponent
							}
							Item {
								Layout.preferredWidth: (modelData.customRightMargin > 0 ? modelData.customRightMargin : 17) * DefaultStyle.dp
							}
						}
					}
				}
			}
		}
	}
}

