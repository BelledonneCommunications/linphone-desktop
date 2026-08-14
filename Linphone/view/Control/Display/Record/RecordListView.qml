import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Basic

import Linphone
import QtQml
import UtilsCpp

import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

ListView {
	id: mainItem

	property string searchBarText
	property bool hoverEnabled: true
	property RecordingGui selectedRecording
	property bool loading: recordingProxy.loading
	property real busyIndicatorSize: Utils.getSizeWithScreenRatio(60)
	property string playingFilePath
	property bool playing: false

	signal playRequested(RecordingGui recording)

	clip: true
	cacheBuffer: height / 2
	spacing: Utils.getSizeWithScreenRatio(8)
	highlightFollowsCurrentItem: false

	function selectIndex(index) {
		mainItem.currentIndex = index
	}

	function resetSelections() {
		mainItem.selectedRecording = null
		mainItem.currentIndex = -1
	}

	function reload() {
		recordingProxy.reload()
	}

	function moveToCurrentItem() {
		if (mainItem.currentIndex >= 0)
			mainItem.positionViewAtIndex(mainItem.currentIndex, ListView.Contain)
	}

	onCurrentItemChanged: {
		moveToCurrentItem()
		if (currentItem) {
			mainItem.selectedRecording = currentItem.itemGui
			currentItem.forceActiveFocus()
		}
	}

	onAtYEndChanged: if (atYEnd) recordingProxy.displayMore()

	Keys.onPressed: (event) => {
		if (event.key == Qt.Key_Up) {
			if (currentIndex > 0) selectIndex(mainItem.currentIndex - 1)
			else selectIndex(model.count - 1)
			event.accepted = true
		} else if (event.key == Qt.Key_Down) {
			if (currentIndex < model.count - 1) selectIndex(currentIndex + 1)
			else selectIndex(0)
			event.accepted = true
		}
	}

	footer: Item {
		height: Utils.getSizeWithScreenRatio(38)
	}

	model: RecordingProxy {
		id: recordingProxy
		filterText: mainItem.searchBarText
		initialDisplayItems: Math.max(20, Math.round(2 * mainItem.height / Utils.getSizeWithScreenRatio(63)))
		displayItemsStep: initialDisplayItems / 2
		onListAboutToBeReset: mainItem.resetSelections()
	}

	BusyIndicator {
		anchors.horizontalCenter: mainItem.horizontalCenter
		visible: mainItem.loading
		height: visible ? mainItem.busyIndicatorSize : 0
		width: mainItem.busyIndicatorSize
		indicatorHeight: mainItem.busyIndicatorSize
		indicatorWidth: mainItem.busyIndicatorSize
		indicatorColor: DefaultStyle.main1_500_main
	}

	ScrollBar.vertical: ScrollBar {
		id: scrollbar
		rightPadding: Utils.getSizeWithScreenRatio(8)
		active: true
		interactive: true
		policy: mainItem.contentHeight > mainItem.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
	}

	section {
		criteria: ViewSection.FullString
		property: '$sectionMonth'
		delegate: Text {
			topPadding: Utils.getSizeWithScreenRatio(24)
			bottomPadding: Utils.getSizeWithScreenRatio(16)
			text: section
			color: DefaultStyle.main2_700
			height: Utils.getSizeWithScreenRatio(29) + topPadding + bottomPadding
			wrapMode: Text.NoWrap
			font {
				pixelSize: Utils.getSizeWithScreenRatio(20)
				weight: Utils.getSizeWithScreenRatio(800)
				capitalization: Font.Capitalize
			}
		}
	}

	delegate: FocusScope {
		id: itemDelegate
		visible: !mainItem.loading
		height: Utils.getSizeWithScreenRatio(63)
		width: mainItem.width

		property var itemGui: $modelData
		property var recordingCore: itemGui ? itemGui.core : null
		property bool isSelected: recordingCore && mainItem.selectedRecording
			&& mainItem.selectedRecording.core === recordingCore
		property bool isPlaying: mainItem.playing && recordingCore
			&& mainItem.playingFilePath === recordingCore.filePath

		Item {
			anchors.fill: parent
			anchors.rightMargin: Utils.getSizeWithScreenRatio(38)

			Rectangle {
				id: recordingDelegate
				anchors.fill: parent
				anchors.rightMargin: Utils.getSizeWithScreenRatio(5)
				radius: Utils.getSizeWithScreenRatio(10)
				color: itemDelegate.isSelected ? DefaultStyle.main2_200 : DefaultStyle.grey_0

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: Utils.getSizeWithScreenRatio(16)
					anchors.rightMargin: Utils.getSizeWithScreenRatio(16)
					anchors.topMargin: Utils.getSizeWithScreenRatio(10)
					anchors.bottomMargin: Utils.getSizeWithScreenRatio(10)
					spacing: Utils.getSizeWithScreenRatio(8)

					EffectImage {
						Layout.alignment: Qt.AlignTop
						Layout.preferredWidth: Utils.getSizeWithScreenRatio(20)
						Layout.preferredHeight: Utils.getSizeWithScreenRatio(20)
						imageSource: itemDelegate.recordingCore && itemDelegate.recordingCore.isVideo
							? AppIcons.videoCamera
							: AppIcons.phone
						colorizationColor: DefaultStyle.main2_600
					}

					ColumnLayout {
						Layout.fillWidth: true
						spacing: Utils.getSizeWithScreenRatio(2)
						Text {
							Layout.fillWidth: true
							text: itemDelegate.recordingCore ? itemDelegate.recordingCore.displayName : ""
							color: DefaultStyle.main2_700
							elide: Text.ElideRight
							maximumLineCount: 1
							font {
								pixelSize: Typography.p2.pixelSize
								weight: Typography.p2.weight
							}
						}
						Text {
							Layout.fillWidth: true
							text: itemDelegate.recordingCore
								? UtilsCpp.toDateString(itemDelegate.recordingCore.dateTime, "d MMMM")
									+ " · " + UtilsCpp.toDateHourString(itemDelegate.recordingCore.dateTime)
								: ""
							color: DefaultStyle.main2_500_main
							elide: Text.ElideRight
							maximumLineCount: 1
							font {
								pixelSize: Typography.p1.pixelSize
								weight: Typography.p1.weight
							}
						}
					}

					ColumnLayout {
						Layout.alignment: Qt.AlignRight
						spacing: 0
						Item {
							Layout.fillWidth: true
							Layout.fillHeight: true
						}
						Text {
							Layout.alignment: Qt.AlignRight | Qt.AlignBottom
							text: itemDelegate.recordingCore ? itemDelegate.recordingCore.durationString : ""
							color: DefaultStyle.main2_500_main
							font {
								pixelSize: Typography.p1.pixelSize
								weight: Typography.p1.weight
							}
						}
					}

					EffectImage {
						id: playButton
						Layout.alignment: Qt.AlignVCenter
						Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
						Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
						imageSource: itemDelegate.isPlaying ? AppIcons.pauseFill : AppIcons.playFill
						colorizationColor: DefaultStyle.main1_500_main
						MouseArea {
							anchors.fill: parent
							hoverEnabled: mainItem.hoverEnabled
							cursorShape: Qt.PointingHandCursor
							onClicked: {
								mainItem.selectIndex(index)
								mainItem.playRequested(itemDelegate.itemGui)
							}
						}
					}
				}
			}

			MultiEffect {
				source: recordingDelegate
				anchors.fill: recordingDelegate
				shadowEnabled: true
				shadowBlur: 0.7
				shadowOpacity: 0.2
			}

			MouseArea {
				anchors.fill: parent
				anchors.rightMargin: playButton.width + Utils.getSizeWithScreenRatio(16)
				hoverEnabled: mainItem.hoverEnabled
				cursorShape: Qt.PointingHandCursor
				onClicked: mainItem.selectIndex(index)
			}
		}
	}
}
