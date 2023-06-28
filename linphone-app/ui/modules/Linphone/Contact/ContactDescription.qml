import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone 1.0
import Linphone.Styles 1.0
import Common 1.0

import UtilsCpp 1.0
// =============================================================================

Column {
	id:mainItem
	property alias titleText: title.fullText
	property alias subtitleText: subtitle.fullText
	property string sipAddress
	
	property alias statusText : status.text
	
	property var contactDescriptionStyle : ContactDescriptionStyle
	
	property color subtitleColor: contactDescriptionStyle.subtitle.colorModel.color
	property color titleColor: contactDescriptionStyle.title.colorModel.color
	property int horizontalTextAlignment
	property int contentWidth : Math.max(titleImplicitWidthWorkaround.implicitWidth, subtitleImplicitWidthWorkaround.implicitWidth)
									+10
									+statusWidth
	property int contentHeight : Math.max(title.implicitHeight, subtitle.implicitHeight)+10
	
	readonly property int statusWidth : (status.visible ? status.width + 5 : 0)
	
	property bool titleClickable: false
	
	signal titleClicked()
	
	// ---------------------------------------------------------------------------
	Item{
		anchors.left: parent.left
		anchors.right: parent.right
		height: (parent.height-parent.topPadding-parent.bottomPadding)/parent.visibleChildren.length
		RowLayout{
			anchors.fill: parent
			TextEdit {
				id: title
				property string fullText
				Layout.fillWidth: true
				color: titleColor
				font.family: SettingsModel.textMessageFont.family
				font.weight: contactDescriptionStyle.title.weight
				font.pointSize: contactDescriptionStyle.title.pointSize
				textFormat: Text.RichText
				horizontalAlignment: horizontalTextAlignment
				verticalAlignment: (subtitle.visible?Text.AlignBottom:Text.AlignVCenter)
				text: UtilsCpp.encodeTextToQmlRichFormat(metrics.elidedText, {noLink:true})
				onActiveFocusChanged: deselect();
				readOnly: true
				selectByMouse: true
				Layout.preferredHeight: parent.height
				
				Text{// Workaround to get implicitWidth from text without eliding
						id: titleImplicitWidthWorkaround
						text: title.fullText
						font.family: SettingsModel.textMessageFont.family
						font.weight: title.font.weight
						font.pointSize: title.font.pointSize
						textFormat: Text.RichText
						visible: false
					}
				
				TextMetrics {
					id: metrics
					font: title.font
					text: title.fullText
					elideWidth: title.width
					elide: Qt.ElideRight
				}
			}
			Text{
				id:status
				Layout.alignment: Qt.AlignVCenter
				verticalAlignment: Text.AlignVCenter
				visible: text != ''
				text : ''
				color: contactDescriptionStyle.title.status.colorModel.color
				font.pointSize: contactDescriptionStyle.title.status.pointSize
				font.italic : true
			}
		}
		MouseArea{
			anchors.fill:parent
			visible: titleClickable
			onClicked: titleClicked()
		}
	}
	Item{
		anchors.left: parent.left
		anchors.right: parent.right
		height: (parent.height-parent.topPadding-parent.bottomPadding)/parent.visibleChildren.length
		visible: subtitle.fullText != '' && subtitle.fullText != title.fullText
		TextEdit {
			id:subtitle
			property string fullText
			anchors.fill: parent
			color: subtitleColor
			font.family: SettingsModel.textMessageFont.family
			font.weight: contactDescriptionStyle.subtitle.weight
			font.pointSize: contactDescriptionStyle.subtitle.pointSize
			textFormat: Text.RichText
			horizontalAlignment: horizontalTextAlignment
			verticalAlignment: (title.visible?Text.AlignTop:Text.AlignVCenter)
			
			text: UtilsCpp.encodeTextToQmlRichFormat(subtitleMetrics.elidedText, {noLink:true})
			
			onActiveFocusChanged: deselect();
			readOnly: true
			selectByMouse: true
			Text{// Workaround to get implicitWidth from text without eliding
				id: subtitleImplicitWidthWorkaround
				text: subtitle.fullText
				font.weight: subtitle.font.weight
				font.pointSize: subtitle.font.pointSize
				visible: false
				textFormat: Text.RichText
			}
			
			TextMetrics {
				id: subtitleMetrics
				font: subtitle.font
				text: subtitle.fullText
				elideWidth: subtitle.width
				elide: Qt.ElideRight
			}
		}
	}
}

