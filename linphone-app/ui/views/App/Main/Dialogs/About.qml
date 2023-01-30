import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import ConstantsCpp 1.0

import App.Styles 1.0

// =============================================================================

DialogPlus {
	buttons: [
		TextButtonB {
			text: qsTr('ok')
			
			onClicked: exit(0)
		}
	]
	
	buttonsAlignment: Qt.AlignCenter
	objectName: '__about'
	flat: true
	showMargins: true
	height: AboutStyle.height + 30
	width: AboutStyle.width
	
	Column {
		anchors.fill: parent
		spacing: AboutStyle.spacing
		
		RowLayout {
			id:versionsLayout
			spacing: AboutStyle.versionsBlock.spacing
			
			height: AboutStyle.versionsBlock.iconSize
			width: parent.width
			
			Icon {
				icon: 'linphone_logo'
				iconSize: parent.height
			}
			
			Column {
				id:versionsArea
				Layout.fillWidth: true
				Layout.preferredHeight: parent.height
				
				spacing: 0
				
				TextEdit {
					id: appVersion
					color: AboutStyle.versionsBlock.appVersion.colorModel.color
					selectByMouse: true
					font.pointSize: AboutStyle.versionsBlock.appVersion.pointSize
					text: 'Desktop ' + Qt.application.version + ' - Qt' + App.qtVersion +'\nCore ' + CoreManager.version
					
					height: parent.height
					width: parent.width   
					
					verticalAlignment: Text.AlignVCenter
					
					onActiveFocusChanged: deselect();
				}
			}
		}
		
		Column {
			spacing: AboutStyle.copyrightBlock.spacing
			width: parent.width
			
			Text {
				elide: Text.ElideRight
				font.pointSize: AboutStyle.copyrightBlock.url.pointSize
				linkColor: AboutStyle.copyrightBlock.url.colorModel.color
				text: '<a href="'+applicationUrl+'">'+applicationUrl+'</a>'
				
				width: parent.width
				visible: applicationUrl != ''
				horizontalAlignment: Text.AlignHCenter
				
				onLinkActivated: Qt.openUrlExternally(link)
				
				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.NoButton
					cursorShape: parent.hoveredLink
								 ? Qt.PointingHandCursor
								 : Qt.IBeamCursor
				}
			}
			
			Text {
				color: AboutStyle.copyrightBlock.license.colorModel.color
				elide: Text.ElideRight
				font.pointSize: AboutStyle.copyrightBlock.license.pointSize
				visible: applicationVendor || applicationLicence || copyrightRangeDate
				text: (applicationLicence? applicationLicence+'\n':'')
						+(copyrightRangeDate || applicationVendor ? '\u00A9 ': '')
						+ (copyrightRangeDate ? copyrightRangeDate : '')
						+ (applicationVendor ? ' ' + applicationVendor : '')
				
				width: parent.width
				
				horizontalAlignment: Text.AlignHCenter
			}
			Text {
				elide: Text.ElideRight
				font.pointSize: AboutStyle.copyrightBlock.url.pointSize
				color: AboutStyle.copyrightBlock.url.colorModel.color
				linkColor: AboutStyle.copyrightBlock.url.colorModel.color
				//: 'Help us translate %1' : %1 is the application name
				text: '<a href="'+ConstantsCpp.TranslationUrl+'" style="text-decoration:none;color:'+AboutStyle.copyrightBlock.url.colorModel.color+'">'+qsTr('aboutTranslation').arg(applicationName)+'</a>'
				textFormat: Text.RichText
				
				width: parent.width
				visible: ConstantsCpp.TranslationUrl != ''
				horizontalAlignment: Text.AlignHCenter
				
				onLinkActivated: Qt.openUrlExternally(link)
				
				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.NoButton
					cursorShape: parent.hoveredLink
								 ? Qt.PointingHandCursor
								 : Qt.IBeamCursor
				}
			}
		}
	}
	
}
