
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Rectangle {
	id: mainItem
	width: container.width
	height: container.height
	property string titleText
	property var contentModel
	property var topbarOptionalComponent
	property var model
	color: DefaultStyle.grey_0
	property var container
    // property real contentHeight: contentListView.contentHeight
    property real minimumWidthForSwitchintToRowLayout: Math.round(981 * DefaultStyle.dp)
	property var useVerticalLayout
	property bool saveButtonVisible: true
	signal save()
	signal undo()
	function setResponsivityFlags() {
        var newValue = width < minimumWidthForSwitchintToRowLayout
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
	Control.Control {
		id: header
		anchors.left: parent.left
		anchors.right: parent.right
        leftPadding: Math.round(45 * DefaultStyle.dp)
        rightPadding: Math.round(45 * DefaultStyle.dp)
		z: 1
		background: Rectangle {
			anchors.fill: parent
			color: DefaultStyle.grey_0
		}
		contentItem: ColumnLayout {
			RowLayout {
				Layout.fillWidth: true
                Layout.topMargin: Math.round(20 * DefaultStyle.dp)
                spacing: Math.round(5 * DefaultStyle.dp)
                Layout.bottomMargin: Math.round(10 * DefaultStyle.dp)
				Button {
					id: backButton
                    Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                    Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
					icon.source: AppIcons.leftArrow
					focus: true
					visible: mainItem.container.depth > 1
                    Layout.rightMargin: Math.round(41 * DefaultStyle.dp)
					style: ButtonStyle.noBackground
					onClicked: {
						mainItem.container.pop()
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
                    Layout.rightMargin: Math.round(34 * DefaultStyle.dp)
				}
				MediumButton {
					id: saveButton
					style: ButtonStyle.main
                    //: "Enregistrer"
                    text: qsTr("save")
                    Layout.rightMargin: Math.round(6 * DefaultStyle.dp)
					visible: mainItem.saveButtonVisible
					onClicked: {
						mainItem.save()
					}
				}
			}
			Rectangle {
				Layout.fillWidth: true
                height: Math.max(Math.round(1 * DefaultStyle.dp), 1)
				color: DefaultStyle.main2_500main
			}
		}
	}
	Control.ScrollView {
		id: scrollView
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.top: header.bottom
        anchors.topMargin: Math.round(16 * DefaultStyle.dp)
		// Workaround while the CI is made with Qt6.5.3
		// When updated to 6.8, remove this Item and
		// change the ScrollView with a Flickable
		Item{anchors.fill: parent}
		contentHeight: contentListView.contentHeight
		Control.ScrollBar.vertical: ScrollBar {
			active: contentListView.contentHeight > scrollView.height
			visible: contentListView.contentHeight > scrollView.height
			interactive: true
			policy: Control.ScrollBar.AsNeeded
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.right: parent.right
            anchors.rightMargin: Math.round(15 * DefaultStyle.dp)
		}
		Control.ScrollBar.horizontal: ScrollBar {
			active: false
		}
		ListView {
			id: contentListView
			model: mainItem.contentModel
			anchors.left: parent.left
			anchors.right: parent.right
            anchors.leftMargin: Math.round(45 * DefaultStyle.dp)
            anchors.rightMargin: Math.round(45 * DefaultStyle.dp)
			height: contentHeight
            spacing: Math.round(10 * DefaultStyle.dp)
			delegate: ColumnLayout {
                visible: modelData.visible != undefined ? modelData.visible: true
                Component.onCompleted: if (!visible) height = 0
                spacing: Math.round(16 * DefaultStyle.dp)
				width: contentListView.width
				Rectangle {
					visible: index !== 0
                    Layout.topMargin: Math.round((modelData.hideTopSeparator ? 0 : 16) * DefaultStyle.dp)
                    Layout.bottomMargin: Math.round(16 * DefaultStyle.dp)
					Layout.fillWidth: true
                    height: Math.max(Math.round(1 * DefaultStyle.dp), 1)
					color: modelData.hideTopSeparator ? 'transparent' : DefaultStyle.main2_500main
				}
				GridLayout {
					rows: 1
					columns: mainItem.useVerticalLayout ? 1 : 2
					Layout.fillWidth: true
					// Layout.preferredWidth: parent.width
                    rowSpacing: Math.round((modelData.title.length > 0 || modelData.subTitle.length > 0 ? 20 : 0) * DefaultStyle.dp)
                    columnSpacing: Math.round(47 * DefaultStyle.dp)
					ColumnLayout {
                        Layout.preferredWidth: Math.round(341 * DefaultStyle.dp)
                        Layout.maximumWidth: Math.round(341 * DefaultStyle.dp)
                        spacing: Math.round(3 * DefaultStyle.dp)
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
                        Layout.topMargin: Math.round((modelData.hideTopMargin ? 0 : (mainItem.useVerticalLayout ? 10 : 21)) * DefaultStyle.dp)
                        Layout.bottomMargin: Math.round(21 * DefaultStyle.dp)
                        Layout.leftMargin: mainItem.useVerticalLayout ? 0 : Math.round(17 * DefaultStyle.dp)
                        Layout.preferredWidth: Math.round((modelData.customWidth > 0 ? modelData.customWidth : 545) * DefaultStyle.dp)
						Layout.alignment: Qt.AlignRight
						Loader {
							id: contentLoader
							Layout.fillWidth: true
							sourceComponent: modelData.contentComponent
						}
						Item {
                            Layout.preferredWidth: Math.round((modelData.customRightMargin > 0 ? modelData.customRightMargin : 17) * DefaultStyle.dp)
						}
					}
				}
			}
		}
	}
}

