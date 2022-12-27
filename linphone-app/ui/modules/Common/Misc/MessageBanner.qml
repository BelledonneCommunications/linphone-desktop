import QtQuick 2.7
import QtQuick.Layouts 1.3 

import Common 1.0
import Common.Styles 1.0
import Utils 1.0

Rectangle{
	id: mainItem
	
	property int fitHeight: visible && opacity > 0 ? 32 : 0
	property string noticeBannerText
	property bool showIcon: true
	property alias pointSize: textItem.font.pointSize
	property alias textColor: textItem.color
	property alias icon: iconItem.icon
	property alias iconColor: iconItem.overwriteColor	// = textColor by default
	
	onNoticeBannerTextChanged: if(noticeBannerText!='') mainItem.state = "showed"
	
	color: MessageBannerStyle.colorModel.color
	radius: 10
	state: "hidden"
	Timer{
		id: hideNoticeBanner
		interval: 4000
		repeat: false
		onTriggered: mainItem.state = "hidden"
	}
	RowLayout{
		anchors.centerIn: parent
		spacing: 5
		Icon{
			id: iconItem
			icon: mainItem.showIcon ? MessageBannerStyle.copyTextIcon : ''
			overwriteColor: textItem.color
			iconSize: 20
			visible: mainItem.showIcon
		}
		Text{
			id: textItem
			Layout.fillHeight: true
			Layout.fillWidth: true
			text: mainItem.noticeBannerText
			font {
				pointSize: MessageBannerStyle.pointSize
			}
			color: MessageBannerStyle.textColor.color
		}
	}
	states: [
		State {
			name: "hidden"
			PropertyChanges { target: mainItem; opacity: 0 }
		},
		State {
			name: "showed"
			PropertyChanges { target: mainItem; opacity: 1 }
		}
	]
	transitions: [
		Transition {
			from: "*"; to: "showed"
			SequentialAnimation{
				NumberAnimation{ properties: "opacity"; easing.type: Easing.OutBounce; duration: 500 }
				ScriptAction{ script: hideNoticeBanner.start()}	
			}
		},
		Transition {
			SequentialAnimation{
				NumberAnimation{ properties: "opacity"; duration: 1000 }
				ScriptAction{ script: mainItem.noticeBannerText = '' }
			}
		}
	]
}// mainItem