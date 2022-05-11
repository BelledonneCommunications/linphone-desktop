import QtQuick 2.7
import QtQuick.Layouts 1.3 

import Common 1.0
import Common.Styles 1.0
import Utils 1.0

Rectangle{
	id: mainItem
	
	property int fitHeight: visible && opacity > 0 ? 32 : 0
	property string noticeBannerText
	property int iconMode : 1	// 0=noIcons, 1=copy
	
	onNoticeBannerTextChanged: if(noticeBannerText!='') mainItem.state = "showed"
	
	color: MessageBannerStyle.color
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
			icon: if(iconMode == 1) MessageBannerStyle.copyTextIcon
			overwriteColor: MessageBannerStyle.textColor
			iconSize: 20
			visible: iconMode != 0
		}
		Text{
			Layout.fillHeight: true
			Layout.fillWidth: true
			text: mainItem.noticeBannerText
			font {
				pointSize: MessageBannerStyle.pointSize
			}
			color: MessageBannerStyle.textColor
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