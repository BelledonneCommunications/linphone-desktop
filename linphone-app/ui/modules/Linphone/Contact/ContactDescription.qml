import QtQuick 2.7

import Linphone 1.0
import Linphone.Styles 1.0
import Common 1.0

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

	TextEdit {
		id: title
		property string fullText
		anchors.horizontalCenter: (horizontalTextAlignment == Text.AlignHCenter ? parent.horizontalCenter : undefined)
		color: titleColor
		font.weight: contactDescriptionStyle.title.weight
		font.pointSize: contactDescriptionStyle.title.pointSize
		horizontalAlignment: horizontalTextAlignment
		verticalAlignment: (subtitle.visible?Text.AlignBottom:Text.AlignVCenter)
		width: Math.min(parent.width-statusWidth, titleImplicitWidthWorkaround.implicitWidth)
		height: (parent.height-parent.topPadding-parent.bottomPadding)/parent.visibleChildren.length
		
		text: metrics.elidedText
		onActiveFocusChanged: deselect();
		readOnly: true
		selectByMouse: true
		
		Text{// Workaround to get implicitWidth from text without eliding
				id: titleImplicitWidthWorkaround
				text: title.fullText
				font.weight: title.font.weight
				font.pointSize: title.font.pointSize
				visible: false
			}
		
		TextMetrics {
			id: metrics
			font: title.font
			text: title.fullText
			elideWidth: title.width
			elide: Qt.ElideRight
		}
		Text{
			id:status
			anchors.top:parent.top
			anchors.bottom : parent.bottom
			anchors.left:parent.right
			anchors.leftMargin:5
			verticalAlignment: Text.AlignVCenter
			visible: text != ''
			text : ''
			color: contactDescriptionStyle.title.status.colorModel.color
			font.pointSize: contactDescriptionStyle.title.status.pointSize
			font.italic : true
		}
		MouseArea{
			anchors.fill:parent
			visible: titleClickable
			onClicked: titleClicked()
		}
	}
	
	TextEdit {
		id:subtitle
		property string fullText
		anchors.horizontalCenter: (horizontalTextAlignment == Text.AlignHCenter ? parent.horizontalCenter : undefined)
		color: subtitleColor
		font.weight: contactDescriptionStyle.subtitle.weight
		font.pointSize: contactDescriptionStyle.subtitle.pointSize
		horizontalAlignment: horizontalTextAlignment
		verticalAlignment: (title.visible?Text.AlignTop:Text.AlignVCenter)
		width: Math.min(parent.width-statusWidth, subtitleImplicitWidthWorkaround.implicitWidth)
		height: (parent.height-parent.topPadding-parent.bottomPadding)/parent.visibleChildren.length
		visible: text != ''
		
		text: subtitleMetrics.elidedText
		onActiveFocusChanged: deselect();
		readOnly: true
		selectByMouse: true
		Text{// Workaround to get implicitWidth from text without eliding
			id: subtitleImplicitWidthWorkaround
			text: subtitle.fullText
			font.weight: subtitle.font.weight
			font.pointSize: subtitle.font.pointSize
			visible: false
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
