import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import UtilsCpp

TextEdit {
	id: mainItem
	
	property string placeholderText
    property real placeholderPixelSize: Typography.p1.pixelSize
    property real placeholderWeight: Typography.p1.weight
	property color placeholderTextColor: color
	property alias background: background.data
	property bool hoverEnabled: false
	property bool hovered: mouseArea.hoverEnabled && mouseArea.containsMouse
    topPadding: Math.round(5 * DefaultStyle.dp)
    bottomPadding: Math.round(5 * DefaultStyle.dp)
	activeFocusOnTab: true

	property bool displayAsRichText: false
	property string richFormatText: UtilsCpp.encodeTextToQmlRichFormat(text)
	property color textAreaColor

	
	Component.onCompleted: {
		mainItem.textAreaColor = mainItem.color // backup original color
		if (displayAsRichText)
			mainItem.color = 'transparent'
	}

	onTextChanged: {
		richFormatText = UtilsCpp.encodeTextToQmlRichFormat(text)
	}

	MouseArea {
		id: mouseArea
		anchors.fill: parent
		hoverEnabled: mainItem.hoverEnabled
		// onPressed: mainItem.forceActiveFocus()
		acceptedButtons: Qt.NoButton
		cursorShape: mainItem.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
	}

	Item {
		id: background
		anchors.fill: parent
		z: -1
	}

	Text {
		anchors.verticalCenter: mainItem.verticalCenter
		text: mainItem.placeholderText
		color: mainItem.placeholderTextColor
		visible: mainItem.text.length == 0 && !mainItem.activeFocus
		x: mainItem.leftPadding
		font {
			pixelSize: mainItem.placeholderPixelSize
			weight: mainItem.placeholderWeight
		}
	}
 	Text {
		id: formattedText
		visible: mainItem.displayAsRichText && mainItem.richFormatText !== ""
		text: mainItem.richFormatText
		textFormat: Text.RichText
		wrapMode: mainItem.wrapMode
		font: mainItem.font
		color: mainItem.textAreaColor
		anchors.fill: parent
		focus: false
		onHoveredLinkChanged: {
			mainItem.hovered = mainItem.displayAsRichText && hoveredLink !== ""
		}
		onLinkActivated: {
			if (link.startsWith('sip'))
				UtilsCpp.createCall(link)
			else
				Qt.openUrlExternally(link)
		}
    }
}
