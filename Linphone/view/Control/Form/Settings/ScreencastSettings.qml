import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ColumnLayout {
	id: mainItem
	property CallGui call
	property ConferenceGui conference: call.core.conference
	property var desc: call.core.videoSourceDescriptor
	property bool isLocalScreenSharing : conference?.core.isLocalScreenSharing || false
	property bool screenSharingAvailable: !!conference && (!conference.core.isScreenSharingEnabled || isLocalScreenSharing)

	signal screenSharingToggled()

    spacing: Utils.getSizeWithScreenRatio(12)

	onIsLocalScreenSharingChanged:  {if(isLocalScreenSharing) mainItem.call.core.videoSourceDescriptor = mainItem.desc }
	Text {
		Layout.fillWidth: true
        //: "Veuillez choisir l’écran ou la fenêtre que vous souihaitez partager au autres participants"
        text: qsTr("screencast_settings_choose_window_text")
        font.pixelSize: Utils.getSizeWithScreenRatio(14)
		color: DefaultStyle.main2_500_main
	}
	TabBar {
		Layout.fillWidth: true
		id: bar
    	spacing: Utils.getSizeWithScreenRatio(40)
        pixelSize: Utils.getSizeWithScreenRatio(16)
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
        leftPadding: Utils.getSizeWithScreenRatio(18)
        rightPadding: Utils.getSizeWithScreenRatio(18)
        topPadding: Utils.getSizeWithScreenRatio(13)
        bottomPadding: Utils.getSizeWithScreenRatio(13)
		background: Rectangle {
			anchors.fill: parent
			anchors.leftMargin: screenPreview.horizontalMargin
			anchors.rightMargin: screenPreview.horizontalMargin
			color: screenPreview.selected ? DefaultStyle.main2_100 : DefaultStyle.grey_0
            border.width: Utils.getSizeWithScreenRatio(2)
			border.color: screenPreview.selected ? DefaultStyle.main2_400 : DefaultStyle.main2_200
            radius: Utils.getSizeWithScreenRatio(10)
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
                    //Layout.preferredHeight: Utils.getSizeWithScreenRatio(170)
					source: $modelData?.windowId ? "image://window/"+ $modelData.windowId :  "image://screen/"+ $modelData.screenIndex
					sourceSize.width: parent.width
					sourceSize.height: parent.height
					cache: false
				}
			}
			RowLayout{
                Layout.topMargin: Utils.getSizeWithScreenRatio(6)
                spacing: Utils.getSizeWithScreenRatio(5)
				Image{
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(15)
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(15)
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
                    font.pixelSize: Utils.getSizeWithScreenRatio(displayScreen ? 14 : 10)
					elide: Text.ElideRight
					maximumLineCount: 1
				}
			}
		}
	}
	StackLayout {
		id: stacklayout
		currentIndex: bar.currentIndex
		ListView{
			id: screensLayout
            spacing: Utils.getSizeWithScreenRatio(16)
			clip: true
			Layout.fillWidth: true
			height: visible ? contentHeight : 0
			currentIndex: -1
			model: ScreenProxy{
				id: screensList
				mode: ScreenList.SCREENS
			}
			onVisibleChanged: {
				if(visible) screensList.update()
				else currentIndex = -1
			}
			delegate: ScreenPreviewLayout {
				horizontalMargin: Utils.getSizeWithScreenRatio(28 - 20 ) // 20 coming from CallsWindow panel
				width: screensLayout.width
				height: Utils.getSizeWithScreenRatio(219)
				screenIndex: index
				onClicked: {//screensLayout.selectedIndex = index
					screensLayout.currentIndex = index
					mainItem.desc.core.screenSharingIndex = index
					if( mainItem.conference.core.isLocalScreenSharing)
							mainItem.call.core.videoSourceDescriptor = mainItem.desc
				}
				selected: mainItem.desc.core.screenSharingIndex === index
			}
		}

		GridView{
			id: windowsLayout
			//property int selectedIndex
			Layout.preferredHeight: visible ? contentHeight : 0
			Layout.fillWidth: true
			model: ScreenProxy{
				id: windowsList
				mode: ScreenList.WINDOWS
			}
			currentIndex: -1
			onVisibleChanged: {
				if(visible) windowsList.update()
				else currentIndex = -1
			}
			cellWidth: width / 2
            cellHeight: Utils.getSizeWithScreenRatio(112 + 15)
			clip: true
			delegate: Item {
				width: windowsLayout.cellWidth
				height: windowsLayout.cellHeight
				ScreenPreviewLayout {
					anchors.fill: parent
					anchors.margins: Utils.getSizeWithScreenRatio(7)
					displayScreen: false
					screenIndex: index
					onClicked: {
						windowsLayout.currentIndex = index
						mainItem.desc.core.windowId = $modelData.windowId
						if( mainItem.conference.core.isLocalScreenSharing)
							mainItem.call.core.videoSourceDescriptor = mainItem.desc
					}
					selected: mainItem.desc.core.windowId == $modelData.windowId
				}
			}
		}
	}
	BigButton {
		Layout.preferredHeight: height
		height: implicitHeight
        visible: mainItem.screenSharingAvailable$
		enabled: windowsLayout.currentIndex !== -1 || screensLayout.currentIndex !== -1
		text:  mainItem.conference && mainItem.conference.core.isLocalScreenSharing
        //: "Stop
            ? qsTr("stop")
        //: "Partager"
            : qsTr("share")
		onClicked: {
			mainItem.conference.core.lToggleScreenSharing()
			mainItem.screenSharingToggled()
		}
		style: ButtonStyle.main
	}
}
