import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import UtilsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.Control {
	id: mainItem
	
	property string placeholderText
    property real placeholderPixelSize: Typography.p1.pixelSize
    property real placeholderWeight: Typography.p1.weight
	property color placeholderTextColor: color
	property alias color: textEdit.color
	property alias textFormat: textEdit.textFormat
	// property alias background: background.data
	hoverEnabled: true
    topPadding: Utils.getSizeWithScreenRatio(5)
    bottomPadding: Utils.getSizeWithScreenRatio(5)
    leftPadding: Utils.getSizeWithScreenRatio(5)
    rightPadding: Utils.getSizeWithScreenRatio(5)
	activeFocusOnTab: true
	KeyNavigation.priority: KeyNavigation.BeforeItem

	property bool displayAsRichText: false
	property var encodeTextObj: UtilsCpp.encodeTextToQmlRichFormat(text)
	property string richFormatText: encodeTextObj && encodeTextObj.value || ""
	property color textAreaColor
	property var wrapMode
	property alias cursorRectangle: textEdit.cursorRectangle

	property alias text: textEdit.text

	signal editingFinished()

	
	Component.onCompleted: {
		mainItem.textAreaColor = mainItem.color // backup original color
		if (displayAsRichText)
			mainItem.color = 'transparent'
	}

	onTextChanged: {
		encodeTextObj = UtilsCpp.encodeTextToQmlRichFormat(text)
	}

	MouseArea {
		id: mouseArea
		anchors.fill: parent
		enabled: mainItem.hoverEnabled
		hoverEnabled: mainItem.hoverEnabled
		acceptedButtons: Qt.NoButton
		cursorShape: mainItem.hovered ? Qt.IBeamCursor : Qt.ArrowCursor
	}

	background: Item {
		id: background
		anchors.fill: parent
		z: -1
	}
	contentItem: TextEdit {
		id: textEdit
		onEditingFinished: mainItem.editingFinished()
		Text {
			// anchors.verticalCenter: mainItem.verticalCenter
			text: mainItem.placeholderText
			color: mainItem.placeholderTextColor
			visible: mainItem.text.length == 0 && !textEdit.activeFocus
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
			width: mainItem.width - mainItem.leftPadding - mainItem.rightPadding
			elide: Text.ElideRight
			font: mainItem.font
			color: mainItem.textAreaColor
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
}
