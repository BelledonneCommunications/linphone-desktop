import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts as Layout
import QtQuick.Effects
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.Popup {
	id: mainItem
	closePolicy: Control.Popup.CloseOnEscape
    leftPadding: Utils.getSizeWithScreenRatio(72)
    rightPadding: Utils.getSizeWithScreenRatio(72)
    topPadding: Utils.getSizeWithScreenRatio(41)
    bottomPadding: Utils.getSizeWithScreenRatio(18)
	property bool closeButtonVisible: true
	property bool roundedBottom: false
	property bool lastRowVisible: true
	property var currentCall
	onOpened: numPad.forceActiveFocus()
	signal buttonPressed(string text)
	signal keyPadKeyPressed(KeyEvent event)
	onKeyPadKeyPressed: (event) => {
		numPad.handleKeyPadEvent(event)
	}
	signal launchCall()
	signal wipe()

	background: Item {
		anchors.fill: parent
		Rectangle {
			id: numPadBackground
			width: parent.width
			height: parent.height
			color: DefaultStyle.grey_100
            radius: Utils.getSizeWithScreenRatio(20)
		}
		MultiEffect {
			id: effect
			anchors.fill: numPadBackground
			source: numPadBackground
			shadowEnabled: true
			shadowColor: DefaultStyle.grey_1000
			shadowOpacity: 0.1
			shadowBlur: 0.1
			z: -1
		}
		Rectangle {
			width: parent.width
			height: parent.height / 2
			anchors.bottom: parent.bottom
			color: DefaultStyle.grey_100
			visible: !mainItem.roundedBottom
		}
		MouseArea {
			anchors.fill: parent
			onClicked: numPad.forceActiveFocus()
		}
		BigButton {
			id: closeButton
			visible: mainItem.closeButtonVisible
			anchors.top: parent.top
			anchors.right: parent.right
            anchors.topMargin: Utils.getSizeWithScreenRatio(10)
            anchors.rightMargin: Utils.getSizeWithScreenRatio(10)
			icon.source: AppIcons.closeX
            icon.width: Utils.getSizeWithScreenRatio(24)
            icon.height: Utils.getSizeWithScreenRatio(24)
			style: ButtonStyle.noBackground
			onClicked: mainItem.close()
		}
	}
	contentItem: NumericPad{
		id: numPad
		lastRowVisible: mainItem.lastRowVisible
		currentCall: mainItem.currentCall
		onButtonPressed: (text) => {
			mainItem.buttonPressed(text)
		}
		onLaunchCall: mainItem.launchCall()
		onWipe: mainItem.wipe()
	}
}
