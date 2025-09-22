
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
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
    property real minimumWidthForSwitchintToRowLayout: Utils.getSizeWithScreenRatio(981)
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
        leftPadding: Utils.getSizeWithScreenRatio(45)
        rightPadding: Utils.getSizeWithScreenRatio(45)
		z: 1
		background: Rectangle {
			anchors.fill: parent
			color: DefaultStyle.grey_0
		}
		contentItem: ColumnLayout {
			RowLayout {
				Layout.fillWidth: true
                Layout.topMargin: Utils.getSizeWithScreenRatio(20)
                spacing: Utils.getSizeWithScreenRatio(5)
                Layout.bottomMargin: Utils.getSizeWithScreenRatio(10)
				Button {
					id: backButton
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(30)
					icon.source: AppIcons.leftArrow
					focus: true
					visible: mainItem.container.depth > 1
                    Layout.rightMargin: Utils.getSizeWithScreenRatio(41)
					style: ButtonStyle.noBackground
					onClicked: {
						mainItem.container.pop()
					}
					//: Return
					Accessible.name: qsTr("return_accessible_name")
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
                    Layout.rightMargin: Utils.getSizeWithScreenRatio(34)
				}
				MediumButton {
					id: saveButton
					style: ButtonStyle.main
                    //: "Enregistrer"
                    text: qsTr("save")
                    Layout.rightMargin: Utils.getSizeWithScreenRatio(6)
					visible: mainItem.saveButtonVisible
					//: Save %1 settings
					Accessible.name: qsTr("save_settings_accessible_name").arg(mainItem.titleText)
					onClicked: {
						mainItem.save()
					}
				}
			}
			Rectangle {
				Layout.fillWidth: true
                height: Math.max(Utils.getSizeWithScreenRatio(1), 1)
				color: DefaultStyle.main2_500_main
			}
		}
	}
	Control.ScrollView {
		id: scrollView
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.top: header.bottom
        anchors.topMargin: Utils.getSizeWithScreenRatio(16)
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
            anchors.rightMargin: Utils.getSizeWithScreenRatio(15)
		}
		Control.ScrollBar.horizontal: ScrollBar {
			active: false
		}
		ListView {
			id: contentListView
			model: mainItem.contentModel
			anchors.left: parent.left
			anchors.right: parent.right
            anchors.leftMargin: Utils.getSizeWithScreenRatio(45)
            anchors.rightMargin: Utils.getSizeWithScreenRatio(45)
			height: contentHeight
            spacing: Utils.getSizeWithScreenRatio(10)
			delegate: ColumnLayout {
                visible: modelData.visible != undefined ? modelData.visible: true
                Component.onCompleted: if (!visible) height = 0
                spacing: Utils.getSizeWithScreenRatio(16)
				width: contentListView.width
				Rectangle {
					visible: index !== 0
                    Layout.topMargin: Math.round((modelData.hideTopSeparator ? 0 : 16) * DefaultStyle.dp)
                    Layout.bottomMargin: Utils.getSizeWithScreenRatio(16)
					Layout.fillWidth: true
                    height: Math.max(Utils.getSizeWithScreenRatio(1), 1)
					color: modelData.hideTopSeparator ? 'transparent' : DefaultStyle.main2_500_main
				}
				GridLayout {
					rows: 1
					columns: mainItem.useVerticalLayout ? 1 : 2
					Layout.fillWidth: true
					// Layout.preferredWidth: parent.width
                    rowSpacing: Math.round((modelData.title.length > 0 || modelData.subTitle.length > 0 ? 20 : 0) * DefaultStyle.dp)
                    columnSpacing: Utils.getSizeWithScreenRatio(47)
					ColumnLayout {
                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(341)
                        Layout.maximumWidth: Utils.getSizeWithScreenRatio(341)
                        spacing: Utils.getSizeWithScreenRatio(3)
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
                        Layout.bottomMargin: Utils.getSizeWithScreenRatio(21)
                        Layout.leftMargin: mainItem.useVerticalLayout ? 0 : Utils.getSizeWithScreenRatio(17)
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

