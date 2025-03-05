import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ColumnLayout {
	id: mainItem
	property CallGui call
	property ConferenceGui conference: call.core.conference
	property var desc: call.core.videoSourceDescriptor
	property bool isLocalScreenSharing : conference?.core.isLocalScreenSharing || false
	property bool screenSharingAvailable: !!conference && (!conference.core.isScreenSharingEnabled || isLocalScreenSharing)

    spacing: Math.round(12 * DefaultStyle.dp)

	onIsLocalScreenSharingChanged:  {if(isLocalScreenSharing) mainItem.call.core.videoSourceDescriptor = mainItem.desc }
	Text {
		Layout.fillWidth: true
        //: "Veuillez choisir l’écran ou la fenêtre que vous souihaitez partager au autres participants"
        text: qsTr("screencast_settings_choose_window_text")
        font.pixelSize: Math.round(14 * DefaultStyle.dp)
		color: DefaultStyle.main2_500main
	}
	TabBar {
		Layout.fillWidth: true
		id: bar
        pixelSize: Math.round(16 * DefaultStyle.dp)
        //: "Ecran entier"
        model: [qsTr("screencast_settings_all_screen_label"),
            //: "Fenêtre"
            qsTr("screencast_settings_one_window_label")]
	}
	component ScreenPreviewLayout: Control.Control {
		id: screenPreview
		signal clicked()
		property var screenSource
		property int screenIndex
		property bool selected: false
		property bool displayScreen:  true
        property real horizontalMargin: 0
        leftPadding: Math.round(18 * DefaultStyle.dp)
        rightPadding: Math.round(18 * DefaultStyle.dp)
        topPadding: Math.round(13 * DefaultStyle.dp)
        bottomPadding: Math.round(13 * DefaultStyle.dp)
		background: Rectangle {
			anchors.fill: parent
			anchors.leftMargin: screenPreview.horizontalMargin
			anchors.rightMargin: screenPreview.horizontalMargin
			color: screenPreview.selected ? DefaultStyle.main2_100 : DefaultStyle.grey_0
            border.width: Math.round(2 * DefaultStyle.dp)
			border.color: screenPreview.selected ? DefaultStyle.main2_400 : DefaultStyle.main2_200
            radius: Math.round(10 * DefaultStyle.dp)
			MouseArea {
				anchors.fill: parent
				onClicked: {
					screenPreview.clicked()
				}
			}
		}
		contentItem: ColumnLayout {
			spacing: 0				
			Item{
				Layout.fillWidth: true
				Layout.fillHeight: true
				Image {
					anchors.centerIn: parent
                    //Layout.preferredHeight: Math.round(170 * DefaultStyle.dp)
					source: $modelData?.windowId ? "image://window/"+ $modelData.windowId :  "image://screen/"+ $modelData.screenIndex
					sourceSize.width: parent.width
					sourceSize.height: parent.height
					cache: false
				}
			}
			RowLayout{
                Layout.topMargin: Math.round(6 * DefaultStyle.dp)
                spacing: Math.round(5 * DefaultStyle.dp)
				Image{
                    Layout.preferredHeight: Math.round(15 * DefaultStyle.dp)
                    Layout.preferredWidth: Math.round(15 * DefaultStyle.dp)
					visible: !!$modelData?.windowId
					source: visible ? "image://window_icon/"+ $modelData.windowId : ''
					sourceSize.width: width
					sourceSize.height: height
					cache: false
				}
				Text {
					Layout.fillWidth: true
                    //: "Ecran %1"
                    text: !!$modelData?.windowId ? $modelData.name : qsTr("screencast_settings_screen").arg(screenIndex+1)
					horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Math.round((displayScreen ? 14 : 10) * DefaultStyle.dp)
					elide: Text.ElideRight
					maximumLineCount: 1
				}
			}
		}
	}
	StackLayout {
		currentIndex: bar.currentIndex
		ListView{
			id: screensLayout
            spacing: Math.round(16 * DefaultStyle.dp)
			clip: true
			//property int selectedIndex
			model: ScreenProxy{
				id: screensList
				mode: ScreenList.SCREENS
			}
			onVisibleChanged: if(visible) screensList.update()
			delegate: ScreenPreviewLayout {
                    horizontalMargin: Math.round((28 - 20 ) * DefaultStyle.dp) // 20 coming from CallsWindow panel
					width: screensLayout.width
                    height: Math.round(219 * DefaultStyle.dp)
					screenIndex: index
					onClicked: {//screensLayout.selectedIndex = index
						screensLayout.currentIndex = index
						mainItem.desc.core.screenSharingIndex = index
						if( mainItem.conference.core.isLocalScreenSharing)
							mainItem.call.core.videoSourceDescriptor = mainItem.desc
					}
					selected: //screensLayout.selectedIndex === index
								mainItem.desc.core.screenSharingIndex === index
				}
		}

		GridView{
			id: windowsLayout
			//property int selectedIndex
			model: ScreenProxy{
				id: windowsList
				mode: ScreenList.WINDOWS
			}
			currentIndex: -1
			onVisibleChanged: if(visible) windowsList.update()
			cellWidth: width / 2
            cellHeight: Math.round((112 + 15) * DefaultStyle.dp)
			clip: true
			delegate: Item{
					width: windowsLayout.cellWidth
					height: windowsLayout.cellHeight
					ScreenPreviewLayout {
						anchors.fill: parent
                        anchors.margins:  Math.round(7 * DefaultStyle.dp)
						displayScreen: false
						screenIndex: index
						onClicked: {
							windowsLayout.currentIndex = index
							mainItem.desc.core.windowId = $modelData.windowId
							if( mainItem.conference.core.isLocalScreenSharing)
									mainItem.call.core.videoSourceDescriptor = mainItem.desc
						}
						selected: mainItem.desc.core.windowId == $modelData.windowId

						//onClicked: screensLayout.selectedIndex = index
						//selected: screensLayout.selectedIndex === index
					}
				}
		}
	}
	Button {
        visible: mainItem.screenSharingAvailable$
		enabled: windowsLayout.currentIndex !== -1 || screensLayout.currentIndex !== -1
		text:  mainItem.conference && mainItem.conference.core.isLocalScreenSharing
        //: "Stop
            ? qsTr("stop")
        //: "Partager"
            : qsTr("share")
		onClicked: mainItem.conference.core.lToggleScreenSharing()
		style: ButtonStyle.main
	}
}
