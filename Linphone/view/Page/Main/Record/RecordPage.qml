import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

AbstractMainPage {
	id: mainItem

	property RecordingGui selectedRecording: recordList.selectedRecording
	property var selectedCore: selectedRecording ? selectedRecording.core : null
	property bool isPlaying: soundPlayer.core.playbackState === LinphoneEnums.PlaybackState.PlayingState
	property int playerDuration: selectedCore && selectedCore.duration > 0
		? selectedCore.duration
		: soundPlayer.core.duration
	property int playerPosition: 0

	//: "Aucun enregistrement"
	emptyListText: qsTr("record_list_empty")
	showDefaultItem: false
	rightPanelColor: DefaultStyle.grey_0

	onVisibleChanged: if (!visible) stopPlayback()

	Component.onDestruction: stopPlayback()

	function stopPlayback() {
		positionTimer.stop()
		soundPlayer.core.lStop(true)
		mainItem.playerPosition = 0
	}

	function togglePlayback() {
		if (!mainItem.selectedCore) return
		if (mainItem.isPlaying) soundPlayer.core.lPause()
		else soundPlayer.core.lPlay()
	}

	onSelectedCoreChanged: {
		stopPlayback()
		if (selectedCore) {
			soundPlayer.source = selectedCore.filePath
			if (rightPanelStackView.depth === 0)
				rightPanelStackView.replace(playerComponent, Control.StackView.Immediate)
		} else {
			soundPlayer.source = ""
			rightPanelStackView.clear()
		}
	}

	SoundPlayerGui {
		id: soundPlayer
		onSourceChanged: if (source != "") core.lOpen()
		onPositionChanged: mainItem.playerPosition = core.position
		onEofReached: {
			positionTimer.stop()
			mainItem.playerPosition = 0
		}
		onErrorChanged: (error) => {
			//: Error
			UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"), error, false)
		}
	}

	Connections {
		target: soundPlayer.core
		function onPlaybackStateChanged() {
			if (mainItem.isPlaying) positionTimer.start()
			else positionTimer.stop()
		}
	}

	Timer {
		id: positionTimer
		repeat: true
		interval: 200
		onTriggered: soundPlayer.core.lRefreshPosition()
	}

	FileDialog {
		id: exportDialog
		fileMode: FileDialog.SaveFile
		onAccepted: {
			if (mainItem.selectedCore)
				mainItem.selectedCore.exportTo(Utils.getSystemPathFromUri(selectedFile))
		}
	}

	leftPanelContent: ColumnLayout {
		Layout.fillWidth: true
		Layout.fillHeight: true
		Layout.leftMargin: Utils.getSizeWithScreenRatio(45)
		spacing: 0

		Text {
			Layout.fillWidth: true
			Layout.rightMargin: Utils.getSizeWithScreenRatio(38)
			//: "Records"
			text: qsTr("record_list_title")
			color: DefaultStyle.main2_700
			font.pixelSize: Typography.h2.pixelSize
			font.weight: Typography.h2.weight
		}

		SearchBar {
			id: searchBar
			Layout.topMargin: Utils.getSizeWithScreenRatio(18)
			Layout.rightMargin: Utils.getSizeWithScreenRatio(38)
			Layout.fillWidth: true
			visible: recordList.count !== 0 || searchBar.text.length !== 0
			//: "Rechercher un enregistrement"
			placeholderText: qsTr("record_list_search_hint")
			KeyNavigation.down: recordList
		}

		ColumnLayout {
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.rightMargin: Utils.getSizeWithScreenRatio(38)
			visible: recordList.count === 0 && !recordList.loading
			spacing: 0
			Image {
				Layout.alignment: Qt.AlignHCenter
				Layout.topMargin: Utils.getSizeWithScreenRatio(46)
				source: AppIcons.noRecordImage
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(359)
				Layout.preferredHeight: Utils.getSizeWithScreenRatio(314)
				fillMode: Image.PreserveAspectFit
			}
			Text {
				Layout.topMargin: Utils.getSizeWithScreenRatio(39)
				Layout.alignment: Qt.AlignHCenter
				//: "Aucun résultat…"
				text: searchBar.text.length !== 0
					? qsTr("list_filter_no_result_found")
					//: "Aucun enregistrement"
					: qsTr("record_list_empty")
				color: DefaultStyle.main2_700
				font {
					pixelSize: Typography.h4.pixelSize
					weight: Typography.h4.weight
				}
			}
			Item {
				Layout.fillHeight: true
			}
		}

		RecordListView {
			id: recordList
			Layout.topMargin: Utils.getSizeWithScreenRatio(38) - Utils.getSizeWithScreenRatio(24)
			Layout.fillWidth: true
			Layout.fillHeight: true
			visible: count !== 0 || loading
			searchBarText: searchBar.text
			playingFilePath: mainItem.selectedCore ? mainItem.selectedCore.filePath : ""
			playing: mainItem.isPlaying

			onPlayRequested: (recording) => mainItem.togglePlayback()

			Keys.onPressed: (event) => {
				if (event.key == Qt.Key_Escape) {
					searchBar.forceActiveFocus()
					event.accepted = true
				}
			}
		}
	}

	Component {
		id: playerComponent

		ColumnLayout {
			spacing: 0

			RowLayout {
				Layout.fillWidth: true
				Layout.leftMargin: Utils.getSizeWithScreenRatio(16)
				Layout.rightMargin: Utils.getSizeWithScreenRatio(16)
				Layout.topMargin: Utils.getSizeWithScreenRatio(10)
				Layout.bottomMargin: Utils.getSizeWithScreenRatio(10)
				spacing: Utils.getSizeWithScreenRatio(8)

				Button {
					style: ButtonStyle.noBackground
					icon.source: AppIcons.leftArrow
					icon.width: Utils.getSizeWithScreenRatio(24)
					icon.height: Utils.getSizeWithScreenRatio(24)
					Layout.preferredWidth: Utils.getSizeWithScreenRatio(30)
					Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
					onClicked: recordList.resetSelections()
					//: Back to previous menu
					Accessible.name: qsTr("back_previous_menu_accessible_name")
				}

				ColumnLayout {
					Layout.fillWidth: true
					spacing: Utils.getSizeWithScreenRatio(2)
					Text {
						Layout.fillWidth: true
						text: mainItem.selectedCore ? mainItem.selectedCore.displayName : ""
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
						text: mainItem.selectedCore
							? UtilsCpp.toDateString(mainItem.selectedCore.dateTime, "d MMMM")
								+ " · " + UtilsCpp.toDateHourString(mainItem.selectedCore.dateTime)
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

				Button {
					style: ButtonStyle.noBackground
					icon.source: AppIcons.download
					icon.width: Utils.getSizeWithScreenRatio(24)
					icon.height: Utils.getSizeWithScreenRatio(24)
					Layout.preferredWidth: Utils.getSizeWithScreenRatio(30)
					Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
					onClicked: {
						if (!mainItem.selectedCore) return
						exportDialog.currentFile = Utils.getUriFromSystemPath(mainItem.selectedCore.filePath)
						exportDialog.open()
					}
					//: Export the recording
					Accessible.name: qsTr("record_export_accessible_name")
				}

				Button {
					style: ButtonStyle.noBackground
					icon.source: AppIcons.trashCan
					icon.width: Utils.getSizeWithScreenRatio(24)
					icon.height: Utils.getSizeWithScreenRatio(24)
					Layout.preferredWidth: Utils.getSizeWithScreenRatio(30)
					Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
					onClicked: {
						if (!mainItem.selectedCore) return
						var mainWin = UtilsCpp.getMainWindow()
						mainWin.showConfirmationLambdaPopup("",
							//: "Supprimer cet enregistrement ?"
							qsTr("record_delete_confirmation_message"),
							"",
							function (confirmed) {
								if (!confirmed || !mainItem.selectedCore) return
								mainItem.stopPlayback()
								var core = mainItem.selectedCore
								recordList.resetSelections()
								core.removeFile()
							}
						)
					}
					//: Delete the recording
					Accessible.name: qsTr("record_delete_accessible_name")
				}
			}

			Rectangle {
				Layout.fillWidth: true
				Layout.fillHeight: true
				color: DefaultStyle.grey_1000

				EffectImage {
					anchors.centerIn: parent
					visible: !mainItem.selectedCore || !mainItem.selectedCore.isVideo
					width: Utils.getSizeWithScreenRatio(48)
					height: Utils.getSizeWithScreenRatio(48)
					imageSource: AppIcons.musicNotes
					colorizationColor: DefaultStyle.grey_0
				}

				Loader {
					id: videoLoader
					anchors.fill: parent
					anchors.bottomMargin: transportBar.height

					property bool reset: false
					property string sourcePath: mainItem.selectedCore ? mainItem.selectedCore.filePath : ""
					property bool playing: mainItem.isPlaying

					active: mainItem.selectedCore && mainItem.selectedCore.isVideo && !videoLoader.reset
					onSourcePathChanged: resetTimer.restart()
					onPlayingChanged: if (playing) resetTimer.restart()

					Timer {
						id: resetTimer
						interval: 1
						triggeredOnStart: true
						onTriggered: videoLoader.reset = !videoLoader.reset
					}

					sourceComponent: CameraGui {
						anchors.fill: parent
						qmlName: "recordPlayer"
						player: soundPlayer
						onRequestNewRenderer: if (mainItem.isPlaying && !isReady) resetTimer.restart()
					}
				}

				RowLayout {
					id: transportBar
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.bottom: parent.bottom
					anchors.leftMargin: Utils.getSizeWithScreenRatio(20)
					anchors.rightMargin: Utils.getSizeWithScreenRatio(20)
					anchors.bottomMargin: Utils.getSizeWithScreenRatio(20)
					spacing: Utils.getSizeWithScreenRatio(16)

					EffectImage {
						Layout.preferredWidth: Utils.getSizeWithScreenRatio(20)
						Layout.preferredHeight: Utils.getSizeWithScreenRatio(20)
						imageSource: mainItem.isPlaying ? AppIcons.pauseFill : AppIcons.playFill
						colorizationColor: DefaultStyle.grey_0
						MouseArea {
							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							onClicked: mainItem.togglePlayback()
						}
					}

					Item {
						Layout.fillWidth: true
						Layout.preferredHeight: Utils.getSizeWithScreenRatio(16)

						Rectangle {
							id: progressTrack
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.verticalCenter: parent.verticalCenter
							height: Utils.getSizeWithScreenRatio(3)
							radius: height / 2
							color: DefaultStyle.grey_0
							opacity: 0.4
						}
						Rectangle {
							anchors.left: progressTrack.left
							anchors.verticalCenter: progressTrack.verticalCenter
							height: progressTrack.height
							radius: progressTrack.radius
							width: mainItem.playerDuration > 0
								? progressTrack.width * Math.min(1, mainItem.playerPosition / mainItem.playerDuration)
								: 0
							color: DefaultStyle.main1_500_main
						}
						MouseArea {
							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							onClicked: (mouse) => {
								if (mainItem.playerDuration <= 0) return
								var ms = Math.round(mouse.x * mainItem.playerDuration / width)
								soundPlayer.core.lSeek(ms)
								mainItem.playerPosition = ms
							}
						}
					}

					Text {
						text: UtilsCpp.formatDuration(mainItem.playerPosition > 0
							? mainItem.playerPosition
							: mainItem.playerDuration)
						color: DefaultStyle.grey_0
						font {
							pixelSize: Typography.p1.pixelSize
							weight: Typography.p1.weight
						}
					}
				}
			}
		}
	}
}
